
library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

-- Uncomment the following library declaration if instantiating
-- any Xilinx leaf cells in this code.
--library UNISIM;
--use UNISIM.VComponents.all;

entity project_reti_logiche is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_start : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        o_done : out std_logic;
        o_en : out std_logic;
        o_we : out std_logic;
        o_data : out std_logic_vector (7 downto 0)
    );
end project_reti_logiche;

architecture Behavioral of project_reti_logiche is
component pixel_calculator is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        num_pixel_load : in std_logic;
        num_pixel_sel : in std_logic;
        molt_load : in std_logic;
        molt_sel : in std_logic;
        prod_end : out std_logic;
        pixel_out : out std_logic_vector(15 downto 0)
    );
end component;
signal r1_load : STD_LOGIC;
signal r2_load : STD_LOGIC;
signal num_pixel_load : STD_LOGIC;
signal num_pixel_sel : STD_LOGIC;
signal molt_load : STD_LOGIC;
signal molt_sel : STD_LOGIC;
signal prod_end : STD_LOGIC;
signal pixel_out : STD_LOGIC_VECTOR (15 downto 0);

component address_calculator is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        pixel_in : in std_logic_vector(15 downto 0);
        temp1_sel : in std_logic;
        temp1_load : in std_logic;
        temp2_sel : in std_logic;
        temp2_load : in std_logic;
        address_sel : in std_logic_vector(1 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        last_addr : out std_logic
    );
end component;
signal pixel_in : STD_LOGIC_VECTOR (15 downto 0);
signal temp1_sel : STD_LOGIC;
signal temp1_load : STD_LOGIC;
signal temp2_sel : STD_LOGIC;
signal temp2_load : STD_LOGIC;
signal address_sel : STD_LOGIC_VECTOR (1 downto 0);
signal last_addr : STD_LOGIC;

component maxmin_calculator is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r3_load : in std_logic;
        max_sel : in std_logic;
        min_sel : in std_logic;
        max_load : in std_logic;
        min_load : in std_logic;
        max_out : out std_logic_vector(7 downto 0);
        min_out : out std_logic_vector(7 downto 0)
    );
end component;
signal r3_load : STD_LOGIC;
signal max_sel : STD_LOGIC;
signal min_sel : STD_LOGIC;
signal max_load : STD_LOGIC;
signal min_load : STD_LOGIC;
signal max_out : STD_LOGIC_VECTOR (7 downto 0);
signal min_out : STD_LOGIC_VECTOR (7 downto 0);

component shift_level_calculator is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        max_in : in std_logic_vector (7 downto 0);
        min_in : in std_logic_vector (7 downto 0);
        combined_reg_load : in std_logic;
        shift_level_load : in std_logic;
        shift_counter_sel : in std_logic;
        shift_counter_load : in std_logic;
        shift_end : out std_logic
    );
end component;
signal max_in : STD_LOGIC_VECTOR (7 downto 0);
signal min_in : STD_LOGIC_VECTOR (7 downto 0);
signal combined_reg_load : STD_LOGIC;
signal shift_level_load : STD_LOGIC;
signal shift_counter_sel : STD_LOGIC;
signal shift_counter_load : STD_LOGIC;
signal shift_end : STD_LOGIC;

component pixel_writer is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        min_in : in std_logic_vector(7 downto 0);
        r4_load : in std_logic;
        result_reg_sel : in std_logic;
        result_reg_load : in std_logic;

        o_data : out std_logic_vector(7 downto 0)
    );
end component;
signal r4_load : STD_LOGIC;
signal result_reg_sel : STD_LOGIC;
signal result_reg_load : STD_LOGIC;

type S is (S0,Spre1,S1,S2,S3,Spost3,S4,S4calc,S5,S6,S7,S8,S8calc,Spre9,S9,S10,S11,S12,S13,S14,S15,S15calc,S16,S17,S17post,S18,S19,S20,S21,S21calc,S22,S23);
signal cur_state, next_state : S;

begin

PIXEL_CAL: pixel_calculator
    port map (
        i_clk, i_rst, i_data, r1_load, r2_load, num_pixel_load, num_pixel_sel, molt_load,
        molt_sel, prod_end, pixel_out);
        
ADDR_CALC: address_calculator
    port map (
        i_clk, i_rst, pixel_in, temp1_sel, temp1_load, temp2_sel, temp2_load,
        address_sel, o_address, last_addr);

MAX_MIN: maxmin_calculator
    port map (
        i_clk, i_rst, i_data, r3_load, max_sel, min_sel, max_load, min_load, 
        max_out, min_out);

SHIFT: shift_level_calculator
    port map (
        i_clk, i_rst, max_in, min_in, combined_reg_load, shift_level_load, 
        shift_counter_sel, shift_counter_load, shift_end);

WRITER: pixel_writer
    port map (
        i_clk, i_rst, i_data, min_in, r4_load, result_reg_sel, result_reg_load,
        o_data);
        
    -- associating in and out signals between components
    pixel_in <= pixel_out;
    max_in <= max_out;
    min_in <= min_out;     
    
    -- clock event going to next state
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            cur_state <= S0;
        elsif i_clk'event and i_clk = '1' then
            cur_state <= next_state;
        end if;
    end process;

   -- next state process
   process(cur_state, i_start, prod_end, last_addr, shift_end)
    begin
        next_state <= cur_state;
        case cur_state is
            when S0 =>
                if i_start = '1' then
                    next_state <= Spre1;
                end if;
            when Spre1 =>
                next_state <= S1;
            when S1 =>
                next_state <= S2;
            when S2 =>
                next_state <= S3;
            when S3 =>
                next_state <= Spost3;
            when Spost3 =>
                if prod_end = '1' then
                    next_state <= S5;
                elsif prod_end = '0' then
                    next_state <= S4;
                end if;
            when S4 =>
                next_state <= S4calc;
            when S4calc =>
                if prod_end = '1' then
                    next_state <= S5;
                elsif prod_end = '0' then
                    next_state <= S4;
                end if;
            when S5 =>
                if last_addr = '0' then
                    next_state <= S6;
                elsif last_addr = '1' then
                    next_state <= S23;
                end if;
            when S6 =>
                next_state <= S7;
            when S7 =>
                if last_addr = '1' then
                    next_state <= Spre9;
                elsif last_addr = '0' then
                    next_state <= S8;
                end if;
            when S8 =>
                next_state <= S8calc;
            when S8calc =>
                if last_addr = '0' then
                    next_state <= S8;
                elsif last_addr = '1' then
                    next_state <= Spre9;
                end if;
            when Spre9 =>
                next_state <= S9;
            when S9 =>
                next_state <= S10;
            when S10 =>
                next_state <= S11;
            when S11 =>
                if last_addr = '1' then
                    next_state <= S18;
                elsif last_addr = '0' then
                    next_state <= S12;
                end if;
            when S12 =>
                next_state <= S13;
            when S13 =>
                next_state <= S14;
            when S14 =>
                next_state <= S15;
            when S15 =>
                if shift_end = '0' then
                    next_state <= S15calc;
                elsif shift_end = '1' then
                    next_state <= S16;
                end if;
            when S15calc =>
                next_state <= S15;
            when S16 =>
                next_state <= S17;
            when S17 =>
                next_state <= S17post;
            when S17post =>
                if last_addr = '0' then
                    next_state <= S12;
                elsif last_addr = '1' then
                    next_state <= S18;
                end if;
            when S18 =>
                next_state <= S19;
            when S19 =>
                next_state <= S20;
            when S20 =>
                next_state <= S21;
            when S21 =>
                if shift_end = '0' then
                    next_state <= S21calc;
                elsif shift_end = '1' then
                    next_state <= S22;
                end if;
            when S21calc =>
                next_state <= S21;
            when S22 =>
                next_state <= S23;
            when S23 =>
                if i_start = '0' then
                    next_state <= S0;
                end if;
        end case;
    end process;
          
    process (cur_state)
    begin
        
        --initialization
        o_en <= '0';
        o_we <= '0'; 
        o_done <= '0';
        
        r1_load <= '0';
        r2_load <= '0';
        num_pixel_sel <= '0';
        num_pixel_load <= '0';
        molt_sel <= '0';
        molt_load <= '0';
        
        temp1_sel <= '0';
        temp1_load <= '0';
        temp2_sel <= '0';
        temp2_load <= '0';
        address_sel <= "00";
        
        r3_load <= '0';
        min_sel <= '0';
        min_load <= '0';
        max_sel <= '0';
        max_load <= '0';
        
        combined_reg_load <= '0';
        shift_level_load <= '0';
        shift_counter_sel <= '0';
        shift_counter_load <= '0';
        r4_load <= '0';
        result_reg_sel <= '0';
        result_reg_load <= '0';
        
        case cur_state is
            when S0 =>
                o_done <= '0';
            when Spre1 =>
                o_en <= '1';
                address_sel <= "00";
            when S1 =>
                o_en <= '1';
                address_sel <= "01";
                r1_load <= '1';
                num_pixel_load <= '1';
                num_pixel_sel <= '0';
            when S2 =>
                r1_load <= '0';
                r2_load <= '1';
                num_pixel_load <= '1';
                num_pixel_sel <= '0';
            when S3 =>
                o_en <= '0';
                r2_load <= '0';
                molt_sel <= '0';
                molt_load <= '1';
            when Spost3 =>
                temp1_sel <= '0';
                temp1_load <= '1';
            when S4 =>
                molt_sel <= '1';
                molt_load <= '1';
                num_pixel_sel <= '1';
                num_pixel_load <= '1';
            when S4calc =>
                molt_load <= '0';
                num_pixel_load <= '0';
            when S5 =>
            when S6 =>
                temp1_sel <= '1';
                temp1_load <= '1';
            when S7 =>
                o_en <= '1';
                address_sel <= "10";
                max_sel <= '0';
                max_load <= '1';
                min_sel <= '0';
                min_load <= '1';
            when S8 =>
                r3_load <= '1';
                temp1_sel <= '1';
                temp1_load <= '1';
                o_en <= '0';
            when S8calc =>
                o_en <= '1';
                address_sel <= "10";
                max_sel <= '1';
                max_load <= '1';
                min_sel <= '1';
                min_load <= '1';
                temp1_load <= '0';
            when Spre9 =>
                r3_load <= '1';
                o_en <= '0';
            when S9 =>
                max_sel <= '1';
                max_load <= '1';
                min_sel <= '1';
                min_load <= '1';
                r3_load <= '0';
                temp1_sel <= '0';
                temp1_load <= '1';
            when S10 =>
                temp1_sel <= '1';
                temp1_load <= '1';
                temp2_sel <= '0';
                temp2_load <= '1';
                combined_reg_load <= '1';
                max_load <= '0';
                min_load <= '0';
            when S11 =>
                shift_level_load <= '1';
            when S12 =>
                address_sel <= "10";
                o_en <= '1';
                shift_counter_load <= '1';
                shift_counter_sel <= '0';
            when S13 =>
                r4_load <= '1';
            when S14 =>
                result_reg_load <= '1';
                result_reg_sel <= '0';
            when S15 =>
            when S15calc =>
                shift_counter_sel <= '1';
                shift_counter_load <= '1';
                result_reg_sel <= '1';
                result_reg_load <= '1';
            when S16 =>
                o_en <= '1';
                o_we <= '1';
                address_sel <= "11";
            when S17 =>
                temp1_sel <= '1';
                temp1_load <= '1';
                temp2_sel <= '1';
                temp2_load <= '1';
            when S17post =>
            when S18 =>
                address_sel <= "10";
                o_en <= '1';
                shift_counter_load <= '1';
                shift_counter_sel <= '0';
            when S19 =>
                r4_load <= '1';
            when S20 =>
                result_reg_load <= '1';
                result_reg_sel <= '0';
            when S21 =>
            when S21calc =>
                shift_counter_sel <= '1';
                shift_counter_load <= '1';
                result_reg_sel <= '1';
                result_reg_load <= '1';
            when S22 =>
                o_en <= '1';
                o_we <= '1';
                address_sel <= "11";
            when S23 =>
                o_done <= '1';
        end case;
    end process;
       

                        

end Behavioral;



library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pixel_calculator is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r1_load : in std_logic;
        r2_load : in std_logic;
        num_pixel_load : in std_logic;
        num_pixel_sel : in std_logic;
        molt_load : in std_logic;
        molt_sel : in std_logic;
        prod_end : out std_logic;
        pixel_out : out std_logic_vector(15 downto 0)
    );
end pixel_calculator;

architecture Behavioral of pixel_calculator is
signal o_reg1 : STD_LOGIC_VECTOR (7 downto 0);
signal sum : STD_LOGIC_VECTOR(15 downto 0);
signal mux_num_pixel : STD_LOGIC_VECTOR(15 downto 0);
signal o_num_pixel : STD_LOGIC_VECTOR(15 downto 0);
signal o_reg2 : STD_LOGIC_VECTOR (7 downto 0);
signal mux_molt : STD_LOGIC_VECTOR(7 downto 0);
signal o_molt : STD_LOGIC_VECTOR (7 downto 0);
signal sub : STD_LOGIC_VECTOR (7 downto 0);

begin
-- loading r1
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg1 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r1_load = '1') then
                o_reg1 <= i_data;
            end if;
        end if;
    end process;
    
-- sum of r1 and num_pixel    
    sum <= ("00000000" & o_reg1) + o_num_pixel;
    
-- mux of num_pixel_sel    
    with num_pixel_sel select
        mux_num_pixel <= "0000000000000000" when '0',
                    sum when '1',
                    "XXXXXXXXXXXXXXXX" when others;
    
-- loading num_pixel    
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_num_pixel <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(num_pixel_load = '1') then
                o_num_pixel <= mux_num_pixel;
            end if;
        end if;
    end process;
    
-- loading r2
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_reg2 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(r2_load = '1') then
                o_reg2 <= i_data;
            end if;
        end if;
    end process;
    
-- mux of molt_sel    
    with molt_sel select
        mux_molt <= o_reg2 when '0',
                    sub when '1',
                    "XXXXXXXX" when others;
                    
-- loading molt  
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_molt <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if(molt_load = '1') then
                o_molt <= mux_molt;
            end if;
        end if;
    end process;
    
-- subtraction of molt and 1    
    sub <= o_molt - "00000001";
    
-- end signal
    prod_end <= '1' when (o_molt = "00000000") else '0';
    
-- pixel out signal    
    pixel_out <= o_num_pixel; 

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL; 
        

entity address_calculator is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        pixel_in : in std_logic_vector(15 downto 0);
        temp1_sel : in std_logic;
        temp1_load : in std_logic;
        temp2_sel : in std_logic;
        temp2_load : in std_logic;
        address_sel : in std_logic_vector(1 downto 0);
        o_address : out std_logic_vector(15 downto 0);
        last_addr : out std_logic
    );
end address_calculator;

architecture Behavioral of address_calculator is
signal last_pixel_address : STD_LOGIC_VECTOR(15 downto 0);
signal sum1 : STD_LOGIC_VECTOR(15 downto 0);
signal mux_temp1 : STD_LOGIC_VECTOR(15 downto 0);
signal o_temp1 : STD_LOGIC_VECTOR(15 downto 0);
signal first_pixel_equalized : STD_LOGIC_VECTOR(15 downto 0);
signal sum2 : STD_LOGIC_VECTOR(15 downto 0);
signal mux_temp2 : STD_LOGIC_VECTOR(15 downto 0);
signal o_temp2 : STD_LOGIC_VECTOR(15 downto 0);

begin
-- sum of pixel_in and 1
    last_pixel_address <= pixel_in + "0000000000000001";
    
-- sum of 1 and temp1
    sum1 <= o_temp1 + "0000000000000001";
    
-- mux of temp1_sel
    with temp1_sel select
        mux_temp1 <= "0000000000000001" when '0',
                    sum1 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

-- loading temp1
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_temp1 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(temp1_load = '1') then
                o_temp1 <= mux_temp1;
            end if;
        end if;
    end process;
    
-- sum of pixel_in and 2
    first_pixel_equalized <= pixel_in + "0000000000000010";
    
-- sum of 1 and temp2
    sum2 <= o_temp2 + "0000000000000001";
    
-- mux of temp2_sel
    with temp2_sel select
        mux_temp2 <= first_pixel_equalized when '0',
                    sum2 when '1',
                    "XXXXXXXXXXXXXXXX" when others;

-- loading temp2
    process(i_clk, i_rst)
    begin
        if(i_rst = '1') then
            o_temp2 <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if(temp2_load = '1') then
                o_temp2 <= mux_temp2;
            end if;
        end if;
    end process;
    
-- last_addr signal
    last_addr <= '1' when (last_pixel_address = o_temp1) else '0';
    
-- mux o_address
    with address_sel select
        o_address <= "0000000000000000" when "00",
                    "0000000000000001" when "01",
                    o_temp1 when "10",
                    o_temp2 when "11",
                    "XXXXXXXXXXXXXXXX" when others;

end Behavioral;


library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;


entity maxmin_calculator is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        r3_load : in std_logic;
        max_sel : in std_logic;
        min_sel : in std_logic;
        max_load : in std_logic;
        min_load : in std_logic;
        max_out : out std_logic_vector(7 downto 0);
        min_out : out std_logic_vector(7 downto 0)
    );
end maxmin_calculator;

architecture Behavioral of maxmin_calculator is
    signal o_reg3 : STD_LOGIC_VECTOR (7 downto 0);
    signal sel_greater : STD_LOGIC;
    signal sel_lesser : STD_LOGIC;
    signal mux_greater : STD_LOGIC_VECTOR (7 downto 0);
    signal mux_lesser : STD_LOGIC_VECTOR (7 downto 0);
    signal mux_greater_second : STD_LOGIC_VECTOR (7 downto 0);
    signal mux_lesser_second : STD_LOGIC_VECTOR (7 downto 0);
    signal o_max : STD_LOGIC_VECTOR (7 downto 0);
    signal o_min : STD_LOGIC_VECTOR (7 downto 0);
    
    begin
    -- loading r3
        process(i_clk, i_rst)
        begin 
            if (i_rst = '1') then
                o_reg3 <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if (r3_load = '1') then
                    o_reg3 <= i_data;
                end if;
            end if;
        end process;

        --top part of the component
        sel_greater <= '1' when (o_reg3 > o_max) else '0';

        --first top mux
        with sel_greater select
            mux_greater <= o_reg3 when '1',
                            o_max when '0',
                            "XXXXXXXX" when others;

        --second top mux
        with max_sel select
            mux_greater_second <= "00000000" when '0',
                                    mux_greater when '1',
                                    "XXXXXXXX" when others;

    -- loading max
        process(i_clk, i_rst)
        begin
            if (i_rst = '1') then
                o_max <= "00000000";
            elsif i_clk'event and i_clk = '1' then
                if (max_load = '1') then
                    o_max <= mux_greater_second;
                end if;
            end if;
        end process;
        

        --bottom part of the component
        sel_lesser <= '1' when (o_reg3 < o_min) else '0';

        --first bottom mux
        with sel_lesser select
            mux_lesser <= o_reg3 when '1',
                          o_min when '0',
                          "XXXXXXXX" when others;
    
        --second bottom mux
        with min_sel select
            mux_lesser_second <= "11111111" when '0',
                                   mux_lesser when '1',
                                   "XXXXXXXX" when others;

    -- loading min
        process(i_clk, i_rst)
        begin
            if (i_rst = '1') then
                o_min <= "11111111";
            elsif i_clk'event and i_clk = '1' then
                if (min_load = '1') then
                    o_min <= mux_lesser_second;
                end if;
            end if;
        end process;

    -- updating out signals
        max_out <= o_max;

        min_out <= o_min;

end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity shift_level_calculator is
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        max_in : in std_logic_vector (7 downto 0);
        min_in : in std_logic_vector (7 downto 0);
        combined_reg_load : in std_logic;
        shift_level_load : in std_logic;
        shift_counter_sel : in std_logic;
        shift_counter_load : in std_logic;
        shift_end : out std_logic
    );
end shift_level_calculator;

architecture Behavioral of shift_level_calculator is
signal delta : STD_LOGIC_VECTOR (7 downto 0);
signal plus1 : STD_LOGIC_VECTOR (8 downto 0);
signal l1 : STD_LOGIC;
signal l2 : STD_LOGIC;
signal l3 : STD_LOGIC;
signal l4 : STD_LOGIC;
signal l5 : STD_LOGIC;
signal l6 : STD_LOGIC;
signal l7 : STD_LOGIC;
signal l8 : STD_LOGIC;
signal o_combined_reg : STD_LOGIC_VECTOR (7 downto 0);
signal decoder : STD_LOGIC_VECTOR (3 downto 0);
signal value : STD_LOGIC_VECTOR (3 downto 0);
signal o_shift_level : STD_LOGIC_VECTOR (3 downto 0);
signal mux_shift_counter : STD_LOGIC_VECTOR (3 downto 0);
signal o_shift_counter : STD_LOGIC_VECTOR (3 downto 0);
signal minus_counter : STD_LOGIC_VECTOR (3 downto 0);

begin

-- delta calculation (max-min)
    delta <= max_in - min_in;

-- plus1 = delta + 1
    plus1 <= ('0' & delta) + "000000001";

-- l1 = (plus1 < 2) ?
    l1 <= '1' when (plus1 < "000000010") else '0';

-- l2 = (plus1 < 4) ?
    l2 <= '1' when (plus1 < "000000100") else '0';

-- l3 = (plus1 < 8) ?
    l3 <= '1' when (plus1 < "000001000") else '0';
    
-- l4 = (plus1 < 16) ?
    l4 <= '1' when (plus1 < "000010000") else '0';
    
-- l5 = (plus1 < 32) ?
    l5 <= '1' when (plus1 < "000100000") else '0';
    
-- l6 = (plus1 < 64) ?
    l6 <= '1' when (plus1 < "001000000") else '0';
    
-- l7 = (plus1 < 128) ?
    l7 <= '1' when (plus1 < "010000000") else '0';
    
-- l8 = (plus1 < 256) ?
    l8 <= '1' when (plus1 < "100000000") else '0';
    
-- loading combined_reg
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_combined_reg <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if (combined_reg_load = '1') then
                o_combined_reg <= (l1 & l2 & l3 & l4 & l5 & l6 & l7 & l8);
            end if;
        end if;
    end process;
    
-- decoder
    with o_combined_reg select
        decoder <= "0000" when "11111111",
                    "0001" when "01111111",
                    "0010" when "00111111",
                    "0011" when "00011111",
                    "0100" when "00001111",
                    "0101" when "00000111",
                    "0110" when "00000011",
                    "0111" when "00000001",
                    "1000" when "00000000",
                    "XXXX" when others;

-- value = 8 - decoder
    value <= "1000" - decoder;
    
-- loading shift_level
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_shift_level <= "0000";
        elsif i_clk'event and i_clk = '1' then
            if (shift_level_load = '1') then
                o_shift_level <= value;
            end if;
        end if;
    end process;
    
-- mux shift_counter
    with shift_counter_sel select
        mux_shift_counter <= o_shift_level when '0',
                            minus_counter when '1',
                            "XXXX" when others;

-- loading shift_counter
    process(i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_shift_counter <= "0000";
        elsif i_clk'event and i_clk = '1' then
            if (shift_counter_load = '1') then
                o_shift_counter <= mux_shift_counter;
            end if;
        end if;
    end process;
    
-- minus counter = o_shift_counter - 1
    minus_counter <= o_shift_counter - "0001";
    
-- shift end logic      
    shift_end <= '1' when (o_shift_counter = "0000") else '0';
    
end Behavioral;

library IEEE;
use IEEE.STD_LOGIC_1164.ALL;
use IEEE.STD_LOGIC_UNSIGNED.ALL;

entity pixel_writer is 
    port (
        i_clk : in std_logic;
        i_rst : in std_logic;
        i_data : in std_logic_vector(7 downto 0);
        min_in : in std_logic_vector(7 downto 0);
        r4_load : in std_logic;
        result_reg_sel : in std_logic;
        result_reg_load : in std_logic;

        o_data : out std_logic_vector(7 downto 0)
    );
end pixel_writer;

architecture Behavioral of pixel_writer is 
signal o_reg4 : STD_LOGIC_VECTOR (7 downto 0);
signal sub : STD_LOGIC_VECTOR (15 downto 0);
signal mux_res : STD_LOGIC_VECTOR (15 downto 0);
signal o_result_reg : STD_LOGIC_VECTOR (15 downto 0);
signal shifted : STD_LOGIC_VECTOR (15 downto 0);
signal sel_lesser : STD_LOGIC;

begin
-- loading r4
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_reg4 <= "00000000";
        elsif i_clk'event and i_clk = '1' then
            if (r4_load = '1') then
                o_reg4 <= i_data;
            end if;
        end if;
    end process;

-- sub = r4 - min
    sub <= ("00000000" & o_reg4) - ("00000000" & min_in);

-- mux result_reg
    with result_reg_sel select
        mux_res <= sub when '0',
                    shifted when '1',
                    "XXXXXXXXXXXXXXXX" when others;

-- loading result_reg
    process (i_clk, i_rst)
    begin
        if (i_rst = '1') then
            o_result_reg <= "0000000000000000";
        elsif i_clk'event and i_clk = '1' then
            if (result_reg_load = '1') then
                o_result_reg <= mux_res;
            end if;
        end if;
    end process; 

-- shifted = o_result_reg << 1
    shifted <= o_result_reg(14 downto 0) & '0';

-- comparator
    sel_lesser <= '1' when (o_result_reg < "0000000011111111") else '0';

-- o_data logic
    with sel_lesser select
        o_data <= o_result_reg(7 downto 0) when '1',
                    "11111111" when '0',
                    "XXXXXXXX" when others;

end Behavioral;
