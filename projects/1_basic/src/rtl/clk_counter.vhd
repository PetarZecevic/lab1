-------------------------------------------------------------------------------
--  Odsek za racunarsku tehniku i medjuracunarske komunikacije
--  Autor: LPRS2  <lprs2@rt-rk.com>                                           
--                                                                             
--  Ime modula: timer_counter                                                          
--                                                                             
--  Opis:                                                               
--                                                                             
--    Modul odogvaran za indikaciju o proteku sekunde
--                                                                             
-------------------------------------------------------------------------------
LIBRARY IEEE;
USE IEEE.STD_LOGIC_1164.ALL;
USE IEEE.STD_LOGIC_ARITH.ALL;
USE IEEE.STD_LOGIC_UNSIGNED.ALL;

ENTITY clk_counter IS GENERIC(
                              -- maksimalna vrednost broja do kojeg brojac broji
                              max_cnt : STD_LOGIC_VECTOR(25 DOWNTO 0) := "10111110101111000010000000" -- 50 000 000
									  );
                      PORT   (
                               clk_i     : IN  STD_LOGIC; -- ulazni takt
                               rst_i     : IN  STD_LOGIC; -- reset signal
                               cnt_en_i  : IN  STD_LOGIC; -- signal dozvole brojanja
                               cnt_rst_i : IN  STD_LOGIC; -- signal resetovanja brojaca (clear signal)
                               one_sec_o : OUT STD_LOGIC  -- izlaz koji predstavlja proteklu jednu sekundu vremena
                             );
END clk_counter;

ARCHITECTURE rtl OF clk_counter IS

	component reg is
		generic(
			WIDTH    : positive := 1;
			RST_INIT : integer := 0
		);
		port(
			i_clk  : in  std_logic;
			in_rst : in  std_logic;
			i_d    : in  std_logic_vector(WIDTH-1 downto 0);
			o_q    : out std_logic_vector(WIDTH-1 downto 0)
		);
	end component reg;

	SIGNAL	counter_r : STD_LOGIC_VECTOR(25 DOWNTO 0);
	signal	next_counter_r : std_logic_vector(25 downto 0);
	signal	max_ind	: std_logic;
	
BEGIN

-- DODATI:
-- brojac koji kada izbroji dovoljan broj taktova generise SIGNAL one_sec_o koji
-- predstavlja jednu proteklu sekundu, brojac se nulira nakon toga
	reg_counter : reg
		generic map(
			WIDTH => 26,
			RST_INIT => 0
		)
		port map(
			i_clk => clk_i,
			in_rst => not rst_i,
			i_d => next_counter_r,
			o_q => counter_r
		);
	
	max_ind <= '0' when counter_r /= max_cnt else
				  '1';
	
	next_counter_r <= conv_std_logic_vector(0, 26) when max_ind = '1' or cnt_rst_i = '1' else
						 counter_r + 1 when cnt_en_i = '1' else
						 counter_r;
	
	one_sec_o <= max_ind;
	
END rtl;