library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.NUMERIC_STD.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity medijan_mreza is
    Port (
        reset:in std_logic;
        clk:in std_logic;
        din:in std_logic_vector(71 downto 0);
        dout:out std_logic_vector(7 downto 0);
        start_in:in std_logic;
        valid_out:out std_logic
     );
end medijan_mreza;

architecture Behavioral of medijan_mreza is

type pixel_array is array(8 downto 0)of std_logic_vector(7 downto 0);
signal pixels : pixel_array := (others=>(others=>'0'));
signal pixels_out : pixel_array := (others=>(others=>'0'));
type State_t is (stIdle,stInput, stSort, stOut);
signal state_reg,next_state:State_t;
signal reg1:pixel_array;
signal reg2:pixel_array;
signal reg3:pixel_array;
signal reg4:pixel_array;
signal reg5:pixel_array;
signal reg6:pixel_array;
signal reg7:pixel_array;
signal reg8:pixel_array;
signal dreg1:pixel_array;
signal dreg2:pixel_array;
signal dreg3:pixel_array;
signal dreg4:pixel_array;
signal dreg5:pixel_array;
signal dreg6:pixel_array;
signal dreg7:pixel_array;
signal dreg8:pixel_array;
component comparator_8bit is
    port(
    	a: in std_logic_vector(7 downto 0);
        b: in std_logic_vector(7 downto 0);
        min : out std_logic_vector(7 downto 0);
        max:out std_logic_vector(7 downto 0)
    );
end component;





begin
    
    cmp0:comparator_8bit port map(a=>pixels(0),b=>pixels(1),min=>reg1(0),max=>reg1(1));
    cmp1:comparator_8bit port map(a=>pixels(2),b=>pixels(3),min=>reg1(2),max=>reg1(3));
    cmp2:comparator_8bit port map(a=>pixels(4),b=>pixels(5),min=>reg1(4),max=>reg1(5));
    cmp3:comparator_8bit port map(a=>pixels(6),b=>pixels(7),min=>reg1(6),max=>reg1(7));
    
    cmp4:comparator_8bit port map(a=>reg1(0),b=>reg1(2),min=>reg2(0),max=>reg2(2));
    cmp5:comparator_8bit port map(a=>reg1(1),b=>reg1(3),min=>reg2(1),max=>reg2(3));
    cmp6:comparator_8bit port map(a=>reg1(4),b=>reg1(6),min=>reg2(4),max=>reg2(6));
    cmp7:comparator_8bit port map(a=>reg1(5),b=>reg1(7),min=>reg2(5),max=>reg2(7));
   
    cmp8:comparator_8bit port map(a=>reg2(1),b=>reg2(2),min=>reg3(1),max=>reg3(2));
    cmp9:comparator_8bit port map(a=>reg2(5),b=>reg2(6),min=>reg3(5),max=>reg3(6));
    
    cmp10:comparator_8bit port map(a=>reg2(0),b=>reg2(4),min=>reg4(0),max=>reg4(4));
    cmp11:comparator_8bit port map(a=>reg3(1),b=>reg3(5),min=>reg4(1),max=>reg4(5));
    cmp12:comparator_8bit port map(a=>reg3(2),b=>reg3(6),min=>reg4(2),max=>reg4(6));
    cmp13:comparator_8bit port map(a=>reg2(3),b=>reg2(7),min=>reg4(3),max=>reg4(7));
    
    cmp14:comparator_8bit port map(a=>reg4(2),b=>reg4(4),min=>reg5(2),max=>reg5(4));
    cmp15:comparator_8bit port map(a=>reg4(3),b=>reg4(5),min=>reg5(3),max=>reg5(5));
    
    cmp16:comparator_8bit port map(a=>reg4(1),b=>reg5(2),min=>reg6(1),max=>reg6(2));
    cmp17:comparator_8bit port map(a=>reg5(3),b=>reg5(4),min=>reg6(3),max=>reg6(4));
    cmp18:comparator_8bit port map(a=>reg5(5),b=>reg4(6),min=>reg6(5),max=>reg6(6));
    cmp19:comparator_8bit port map(a=>reg4(0),b=>pixels(8),min=>reg6(0),max=>reg6(8));
    
    cmp20:comparator_8bit port map(a=>reg6(4),b=>reg6(8),min=>reg7(4),max=>reg7(8));
    
    cmp21:comparator_8bit port map(a=>reg6(2),b=>reg7(4),min=>reg8(2),max=>reg8(4));
    cmp22:comparator_8bit port map(a=>reg6(3),b=>reg6(5),min=>reg8(3),max=>reg8(5));
    
    cmp23:comparator_8bit port map(a=>reg8(3),b=>reg8(4),min=>pixels_out(3),max=>pixels_out(4));
    
    
    SORT:process(clk)is
    begin
        if(rising_edge(clk))then
            pixels(8)<=din(71 downto 64);
            pixels(7)<=din(63 downto 56);
            pixels(6)<=din(55 downto 48);
            pixels(5)<=din(47 downto 40);
            pixels(4)<=din(39 downto 32);
            pixels(3)<=din(31 downto 24);
            pixels(2)<=din(23 downto 16);
            pixels(1)<=din(15 downto 8);
            pixels(0)<=din(7 downto 0);
            --dreg1<=reg1;
            --dreg2<=reg2;
            --dreg3<=reg3;
            --dreg4<=reg4;
            --dreg5<=reg5;
            --dreg6<=reg6;
            --dreg7<=reg7;
            --dreg8<=reg8;
            dout<=pixels_out(4);
        end if;
    end process SORT;
    

end Behavioral;
