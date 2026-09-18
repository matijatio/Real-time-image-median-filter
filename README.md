# Real-time-image-median-filter

A hardware image-processing pipeline written in VHDL that applies a **3×3 median filter** to a 256×256 grayscale image for noise reduction, with processed pixels streamed off-chip over UART.

## Overview

The design reads an image from on-chip block RAM, slides a 3×3 window across the frame using FIFO-based line buffering, computes the median of each neighborhood through a dedicated sorting network, writes the result back to RAM, and transmits the filtered image serially over UART. The full read–process–write–transmit flow is coordinated by custom FSM/control logic.

## Architecture

| Module | Description |
|--------|-------------|
| `masina` | Top-level entity; instantiates all components and holds the control logic. |
| `im_ram` | Configurable block-RAM frame buffer (8-bit width, 256×256 depth). |
| `fifo` | Line buffers that delay pixel rows to assemble the 3×3 neighborhood. |
| `medijan_mreza` | Median sorting network — computes the median of the 9-pixel window. |
| `uart_tx` | UART transmitter (115200 baud) for streaming processed pixels off-chip. |
| `edge_detector` | Detects the rising edge of the external start signal for clean synchronization. |

## Data Flow

1. **Load** — Image pixels are stored in block RAM.
2. **Window assembly** — A shift-register matrix fed by two FIFO line buffers builds the 3×3 pixel neighborhood as data streams through.
3. **Filter** — The median network computes the output pixel each cycle.
4. **Write-back** — Filtered pixels are written back to RAM at the appropriate address.
5. **Transmit** — Once processing completes, the frame is streamed out over UART.

## Configuration

Top-level generics (`masina`):

| Generic | Default | Description |
|---------|---------|-------------|
| `G_RAM_WIDTH` | `8` | Pixel/data width in bits. |
| `G_RAM_DEPTH` | `256*256` | Number of RAM entries (image size). |
| `G_RAM_PERFORMANCE` | `"LOW_LATENCY"` | RAM output timing mode. |

UART generics (`uart_tx`):

| Generic | Default | Description |
|---------|---------|-------------|
| `CLK_FREQ` | `125` | System clock frequency (MHz). |
| `SER_FREQ` | `115200` | Baud rate (bps). |

## Ports (Top-Level)

| Port | Direction | Description |
|------|-----------|-------------|
| `clk` | in | System clock. |
| `reset` | in | Synchronous reset. |
| `start_in_ex` | in | External start trigger (edge-detected). |
| `d_out` | out | Serial UART output. |

## Requirements

- A VHDL toolchain / FPGA synthesis environment (e.g., Xilinx Vivado).
- The `RAM_definitions_PK` package (provides `clogb2` and related definitions).

## Notes

Signal and process names use Serbian terms:
- `masina` → machine (top level)
- `medijan_mreza` → median network
- `obrada` / `obradjeno` → processing / processed
- `slika` → image
