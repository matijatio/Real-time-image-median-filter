library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;
use std.textio.all;
library work;
use work.RAM_definitions_PK.all;


entity masina is
    generic (
        G_RAM_WIDTH : integer := 8;
        G_RAM_DEPTH : integer := 256*256; 
        G_RAM_PERFORMANCE : string := "LOW_LATENCY" 
    );
    port(
        clk:in std_logic;
        reset: in std_logic;  
        d_out: out std_logic;
        start_in_ex:in std_logic
        
    );
end masina;

architecture Behavioral of masina is

component fifo is
    port(
        clk : in std_logic;
        reset : in std_logic;
        din : in std_logic_vector(7 downto 0);
        dout : out std_logic_vector(7 downto 0);
        we: in std_logic
    );
end component;

component edge_detector is
    port(        
        clk : in std_logic;
        reset : in std_logic;
        in_signal : in std_logic;
        edge : out std_logic
        );
end component;

component im_ram is
    generic (
        G_RAM_WIDTH : integer := 8;            		    -- Specify RAM data width
        G_RAM_DEPTH : integer := 256*256; 				        -- Specify RAM depth (number of entries)
        G_RAM_PERFORMANCE : string := "LOW_LATENCY"   -- Select "HIGH_PERFORMANCE" or "LOW_LATENCY" 
    );
    port (
        addra : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Write address bus, width determined from RAM_DEPTH
        addrb : in std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0);     -- Read address bus, width determined from RAM_DEPTH
        dina  : in std_logic_vector(G_RAM_WIDTH-1 downto 0);		  -- RAM input data
        clka  : in std_logic;                       			  -- Clock
        wea   : in std_logic;                       			  -- Write enable
        enb   : in std_logic;                       			  -- RAM Enable, for additional power savings, disable port when not in use
        rstb  : in std_logic;                       			  -- Output reset (does not affect memory contents)
        regceb: in std_logic;                       			  -- Output register enable
        doutb : out std_logic_vector(G_RAM_WIDTH-1 downto 0) 		  -- RAM output data
    );
end component;

component uart_tx is
    generic (
        CLK_FREQ	: integer := 125;		-- Main frequency (MHz)
        SER_FREQ	: integer := 115200		-- Baud rate (bps)
    );
    port (
        -- Control
        clk			: in	std_logic;		-- Main clock
        rst			: in	std_logic;		-- Main reset
        -- External Interface
        tx			: out	std_logic;		-- RS232 transmitted serial data
        -- RS232/UART Configuration
        par_en		: in	std_logic;		-- Parity bit enable
        -- uPC Interface
        tx_dvalid   : in	std_logic;						-- Indicates that tx_data is valid and should be sent
        tx_data		: in	std_logic_vector(7 downto 0);	-- Data to transmit
        tx_busy     : out   std_logic                       -- Active while UART is busy and cannot receive data
    );
end component;


component medijan_mreza is
    port(
        clk:in std_logic;
        din:in std_logic_vector(71 downto 0);
        dout:out std_logic_vector(7 downto 0)
    );
end component;
type fifo_array is array(8 downto 0)of std_logic_vector(G_RAM_WIDTH-1 downto 0);
signal prepared: std_logic:='0';
signal start_in: std_logic:='0';
signal valid: std_logic:='0';
signal pd_start:std_logic:='0';
signal busy: std_logic:='0';
signal counter:integer:=0;
signal addra: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0):="0000000100000001";
signal dina:std_logic_vector(G_RAM_WIDTH-1 downto 0);
signal inn_addrb: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0):=(others=>'0');
signal obrada: std_logic;
signal fifo_counter:integer range 0 to 550:=0;
signal fifo_reg: fifo_array:=(others=>(others=>'0'));
signal medijan_reg: fifo_array:=(others=>(others=>'0'));
signal fifo_we:std_logic;
signal medijan_din:std_logic_vector(71 downto 0);
signal obradjeno:std_logic:='0';
signal inn_addra: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0):=(others=>'0');
begin

    dut2: im_ram port map(addra=>addra,addrb=>inn_addrb,dina=>dina,clka=>clk,wea=>obrada,enb=>'1',rstb=>reset,regceb=>'0',doutb=>fifo_reg(0));
    
    dut1: uart_tx port map(clk=>clk,rst=>reset,tx=>d_out,par_en=>'0',tx_dvalid=>valid,tx_data=>fifo_reg(0),tx_busy=>busy);
    
    dut3: edge_detector port map(clk=>clk,reset=>reset,in_signal=>start_in_ex,edge=>start_in);
    
    dut4: fifo port map(clk=>clk,reset=>reset,din=>medijan_reg(2),dout=>fifo_reg(3),we=>fifo_we);
    
    dut5: fifo port map(clk=>clk,reset=>reset,din=>medijan_reg(5),dout=>fifo_reg(6),we=>fifo_we);
    
    dut6: medijan_mreza port map(clk=>clk,din=>medijan_din,dout=>dina);
    
    medijan_din_logic:process(medijan_reg)is
    begin
        medijan_din<=medijan_reg(8)&medijan_reg(7)&medijan_reg(6)&medijan_reg(5)&medijan_reg(4)&medijan_reg(3)&medijan_reg(2)&medijan_reg(1)&medijan_reg(0);
    end process medijan_din_logic;
    
    
    FIFO_LOGIC:process(clk)is           --matrica piksela
    begin
        prepared<=prepared;
        if(rising_edge(clk))then
            if(fifo_we='1')then
                medijan_reg(0)<=fifo_reg(0);
                medijan_reg(1)<=medijan_reg(0);
                medijan_reg(2)<=medijan_reg(1);
                medijan_reg(3)<=fifo_reg(3);
                medijan_reg(4)<=medijan_reg(3);
                medijan_reg(5)<=medijan_reg(4);
                medijan_reg(6)<=fifo_reg(6);
                medijan_reg(7)<=medijan_reg(6);
                medijan_reg(8)<=medijan_reg(7);
                fifo_counter<=fifo_counter+1;
                if(fifo_counter=525)then
                    prepared<='1';
                end if;
                if(obrada='1' or obradjeno='1')then
                    prepared<='0';
                    fifo_counter<=0;
                end if;
            end if;
        end if;
    end process FIFO_LOGIC;
    
    VALID_LOGIC:process(obradjeno,counter,reset)is
    begin
        valid<=valid;
        if(rising_edge(obradjeno) or reset='1')then
            valid<='1';
        end if;
        if(counter=65535)then
            valid<='0';
        end if;
    end process VALID_LOGIC;
    
    
    OBRADA_SLIKE:process(clk)is        
    variable checker: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0) :="1111110111111110" ;
    begin
        obradjeno<=obradjeno;
        if(addra=checker)then
            obradjeno<='1';
        end if;
    end process OBRADA_SLIKE;
    
    COUNTER_LOGIC:process(inn_addrb,reset)is
    variable checker: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0) := (others=>'0');
    begin
        if(reset='1')then
            counter<=0;
        elsif(inn_addrb=checker)then
            counter<=0;
        elsif(obradjeno='1')then
            counter<=counter+1;            
        end if;
        
    end process COUNTER_LOGIC;
    
    
    START_lOGIC:process(clk)is
    begin
        obrada<=obrada;
        fifo_we<=fifo_we;
        if(rising_edge(clk))then
            if(prepared='1')then
                obrada<='1';
            elsif(obradjeno='1')then
                obrada<='0';
                fifo_we<='0';
            end if;
            if(obradjeno='0' and start_in='1')then
                fifo_we<='1';
            end if;
        end if;
    end process START_LOGIC;
    
    ADDRESS_A_LOGIC:process(clk)is
    begin
        if(rising_edge(clk) and obrada='1')then
            addra<=std_logic_vector( unsigned(addra) + 1 );
        end if;
    end process ADDRESS_A_LOGIC;
    
    ADDRESS_B_LOGIC: process(busy,reset,clk,obradjeno)is
    variable addrb_reset: std_logic_vector((clogb2(G_RAM_DEPTH)-1) downto 0) := (others=>'0');
    begin
            inn_addrb<=inn_addrb;
            if(rising_edge(clk) and obradjeno='0' and fifo_we='1'  )then
                inn_addrb<=std_logic_vector( unsigned(inn_addrb) + 1 );
            end if;
            if(rising_edge(obradjeno))then
                inn_addrb<="0000000000000000";
            end if;
            if(reset='1')then
                inn_addrb<=addrb_reset;
            elsif(busy'event and busy = '1' and obradjeno='1')then
                inn_addrb<=std_logic_vector( unsigned(inn_addrb) + 1 );
            end if;
    end process ADDRESS_B_LOGIC;
end Behavioral;