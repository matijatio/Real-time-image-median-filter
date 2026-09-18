library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;

entity fifo is
    port (
        clk : in std_logic;
        reset : in std_logic;
        din : in std_logic_vector(7 downto 0);
        dout : out std_logic_vector(7 downto 0);
        we: in std_logic
    );
end fifo;

architecture Behavioral of fifo is

type data_array is array(252 downto 0)of std_logic_vector(7 downto 0);
signal data:data_array:=(others=>(others=>'0')); 

begin
    shift:process(clk)is
    begin
        if(rising_edge(clk))then
            if(reset='1')then
                data<=(others=>(others=>'0'));
                
            elsif(we='1')then
                data(0)<=din;
                loop1: for i in 1 to 252 loop
                    data(i)<=data(i-1);
                end loop loop1;
            end if;
        end if;
    end process;
    
    dout<=data(252);
    

end Behavioral;
