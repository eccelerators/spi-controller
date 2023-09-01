library std;
use std.textio.all;

library ieee;
use ieee.std_logic_1164.all;
use ieee.numeric_std.all;

use work.tb_pkg.all;
use work.tb_pkg_bus.all;
use work.tb_pkg_signals.all;

entity tb_fileio is
    generic(
        stimulus_path : in string;
        stimulus_file : in string
    );
    port(
        clk : in std_logic;
        rst : in std_logic;
        simdone : out std_logic;
        executing_line : out integer;
        executing_file : out text_line;
        marker : out std_logic_vector(15 downto 0);
        signals_out : out t_signals_out;
        signals_in : in t_signals_in := signals_in_init;
        bus_down : out t_bus_down;
        bus_up : in t_bus_up := bus_up_init
    );
end tb_fileio;

architecture behavioural of tb_fileio is
    signal rstneg : std_logic;

    function ld(m : integer) return natural is
    begin
        if m < 0 then
            return 31;
        end if;
        for n in 0 to integer'high loop
            if (2 ** n >= m) then
                return n;
            end if;
        end loop;
    end function ld;

begin
    rstneg <= not rst;
    --------------------------------------------------------------------------------
    --! Read_file Process:

    --! This process is the main process of the testbench.  This process reads
    --! the stimulus file, parses it, creates lists of records, then uses these
    --! lists to execute user instructions.  There are two passes through the
    --! script.  Pass one reads in the stimulus text file, checks it, creates
    --! lists of valid instructions, valid list of variables and finally a list
    --! of user instructions(the sequence).  The second pass through the file,
    --! records are drawn from the user instruction list, variables are converted
    --! to integers and put through the elsif structure for exicution.

    read_file : process
        variable inst_list : inst_def_ptr; -- the instruction list
        variable defined_vars : var_field_ptr; -- defined variables
        variable inst_sequ : stim_line_ptr; -- the instruction sequence
        variable file_list : file_def_ptr; -- pointer to the list of file names
        variable last_sequ_num : integer;
        variable last_sequ_ptr : stim_line_ptr;

        variable instruction : text_field; -- instruction field
        variable par1 : integer; -- parameter 1
        variable par2 : integer; -- parameter 2
        variable par3 : integer; -- parameter 3
        variable par4 : integer; -- parameter 4
        variable par5 : integer; -- parameter 5
        variable par6 : integer; -- parameter 6
        variable txt : stm_text_ptr;
        variable len : integer; -- length of the instruction field
        variable file_line : integer; -- line number in the stimulus file
        variable file_name : text_line; -- the file name the line came from
        variable v_line : integer := 0; -- sequence number
        variable stack : stack_register; -- call stack
        variable stack_ptr : integer := 0; -- call stack pointer
        variable act_loop_num : integer := 0;
        variable act_curr_loop_count : integer := 0;
        variable act_term_loop_count : integer := 0;
        variable stack_loop_num : int_array := (others => 0);
        variable stack_curr_loop_count : int_array_array := (others => (others => 0));
        variable stack_term_loop_count : int_array_array := (others => (others => 0));
        variable stack_loop_line : int_array_array := (others => (others => 0));
        variable stack_loop_if_enter_level : int_array := (others => 0);

        variable loglevel : integer := 0;
        variable exit_on_verify_error : boolean := true;
        variable error_count : integer := 0;
        variable if_level : integer := 0;
        variable loop_if_enter_level : integer := 0;
        variable if_state : boolean_array := (others => false);
        variable num_of_if_in_false_if_leave : int_array := (others => 0);
        variable valid : integer;
        variable interrupt_entered : boolean := false;
        variable interrupt_entry_call_stack_ptr : integer := 0;
        variable successfull : boolean := false;

        -- random generator seed variables
        variable seed1 : positive := 1;
        variable seed2 : positive := 1;

        --  scratchpad variables
        variable tempaddress : std_logic_vector(31 downto 0);
        variable tempdata : std_logic_vector(31 downto 0);
        variable temp_int : integer;

        variable temp_stdvec_a : std_logic_vector(31 downto 0);
        variable temp_stdvec_b : std_logic_vector(31 downto 0);
        variable temp_stdvec_c : std_logic_vector(31 downto 0);

        variable interrupt_in_service : boolean := false;

        variable trc_on : boolean := false;
        variable trc_temp_str : string(1 to file_name'length);

        file stimulus : text; -- file main file
        variable v_stat : file_open_status;

        -- Bus
        type bus_timeout_array is array (0 to 127) of time;
        variable bus_timeouts : bus_timeout_array := (others => 1 sec);

        -- Array
        variable var_array : array_ptr;

        -- File
        variable var_file_ptr : file_ptr;
        file var_file : text; -- file main file
        variable var_file_line : LINE;

    begin -- process read_file
        simdone <= '0';
        marker <= (others => '0');

        signals_out <= signals_out_init;
        bus_down <= bus_down_init;

        -----------------------------------------------------------------------
        --           stimulus file instruction definition
        --  this is where the instructions used in the stimulus file are defined.
        --  syntax is
        --     define_instruction(inst_def_ptr, instruction, paramiters)
        --           inst_def_ptr: is a record pointer defined in tb_pkg_header
        --           instruction:  the text instruction name  ie. "define_var"
        --           paramiters:   the number of fields or paramiters passed
        --
        --  some basic instruction are created here, the user should create new
        --  instructions below the standard ones.
        ------------------------------------------------------------------------

        -- basic
        define_instruction(inst_list, "abort", 0);
        define_instruction(inst_list, "const", 2);
        define_instruction(inst_list, "else", 0);
        define_instruction(inst_list, "elsif", 3);
        define_instruction(inst_list, "end_if", 0);
        define_instruction(inst_list, "end_loop", 0);
        define_instruction(inst_list, "finish", 0);
        define_instruction(inst_list, "if", 3);
        define_instruction(inst_list, "include", 1);
        define_instruction(inst_list, "loop", 1);
        define_instruction(inst_list, "var", 2);

        -- variables
        define_instruction(inst_list, "add", 2);
        define_instruction(inst_list, "and", 2);
        define_instruction(inst_list, "div", 2);
        define_instruction(inst_list, "equ", 2);
        define_instruction(inst_list, "mul", 2);
        define_instruction(inst_list, "shl", 2);
        define_instruction(inst_list, "shr", 2);
        define_instruction(inst_list, "inv", 1);
        define_instruction(inst_list, "or", 2);
        define_instruction(inst_list, "sub", 2);
        define_instruction(inst_list, "xor", 2);
        define_instruction(inst_list, "ld", 1);

        -- signals
        define_instruction(inst_list, "signal_read", 2);
        define_instruction(inst_list, "signal_verify", 4);
        define_instruction(inst_list, "signal_write", 2);

        -- bus
        define_instruction(inst_list, "bus_read", 4);
        define_instruction(inst_list, "bus_verify", 6);
        define_instruction(inst_list, "bus_write", 4);
        define_instruction(inst_list, "bus_timeout", 2);

        -- file
        define_instruction(inst_list, "file", 2);
        define_instruction(inst_list, "line_pos", 2);
        define_instruction(inst_list, "line_read", 2); -- read to an variable or array
        define_instruction(inst_list, "line_seek", 2);
        define_instruction(inst_list, "line_write", 2); -- write an variable, array, const or string
        define_instruction(inst_list, "line_size", 2);

        -- array
        define_instruction(inst_list, "array", 2);
        define_instruction(inst_list, "array_get", 3);
        define_instruction(inst_list, "array_set", 3);
        define_instruction(inst_list, "array_size", 2);
        define_instruction(inst_list, "array_pointer", 2);

        -- others
        define_instruction(inst_list, "proc", 0);
        define_instruction(inst_list, "call", 1);
        define_instruction(inst_list, "interrupt", 1);
        define_instruction(inst_list, "end_proc", 0);
        define_instruction(inst_list, "end_interrupt", 0);
        define_instruction(inst_list, "error", 0);
        define_instruction(inst_list, "random", 3);
        define_instruction(inst_list, "jump", 1);
        define_instruction(inst_list, "label", 1);
        define_instruction(inst_list, "log", 1);
        define_instruction(inst_list, "return", 0);
        define_instruction(inst_list, "resume", 1);
        define_instruction(inst_list, "marker", 2);
        define_instruction(inst_list, "verbosity", 1);
        define_instruction(inst_list, "seeds", 2);
        define_instruction(inst_list, "trace", 1);
        define_instruction(inst_list, "wait", 1);

        file_open(v_stat, stimulus, stimulus_path & stimulus_file, read_mode);
        assert (v_stat = open_ok)
        report lf & "error: unable to open stimulus_file " & stimulus_path & stimulus_file
        severity failure;
        file_close(stimulus);

        ------------------------------------------------------------------------
        -- read, test, and load the stimulus file
        read_instruction_file(stimulus_path, stimulus_file, inst_list, defined_vars, inst_sequ, file_list);

        -- initialize last info
        last_sequ_num := 0;
        last_sequ_ptr := inst_sequ;

        ------------------------------------------------------------------------
        -- using the instruction record list, get the instruction and implement
        -- it as per the statements in the elsif tree.
        while (v_line < inst_sequ.num_of_lines) loop

            v_line := v_line + 1;
            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                             last_sequ_num, last_sequ_ptr);

            Executing_Line <= file_line;
            Executing_File <= file_name;
            wait for 100 ps;

            if (trc_on) then
                for i in 1 to file_name'length loop
                    trc_temp_str(i) := nul;
                end loop;
                for i in 1 to file_name'length loop
                    if (file_name(i) = nul) then
                        exit;
                    end if;
                    trc_temp_str(i) := file_name(i);
                end loop;
                report "exec line " & (integer'image(file_line)) & " " & instruction(1 to len) & " file " & file_name;
            end if;

            --------------------------------------------------------------------------
            if (instruction(1 to len) = "var" or instruction(1 to len) = "const") then
                null; -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "label") then
                null; -- Not used

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "include") then
                null; -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "abort") then
                simdone <= '1';
                assert (false)
                report "the test has aborted due to an error!!"
                severity failure;
                wait;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "finish") then
                simdone <= '1';
                if (error_count = 0) then
                    assert (false)
                    report "test finished with no errors!!"
                    severity note;
                else
                    assert (false)
                    report "test finished with " & (integer'image(error_count)) & " errors!!"
                    severity error;
                end if;
                wait;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "equ") then
                update_variable(defined_vars, par1, par2, valid);
                assert (valid /= 0)
                report " line " & (integer'image(file_line)) & " equ error: vabiable are constant??"
                severity failure;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "add") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := temp_int + par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " add error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & " add error: not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "sub") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := temp_int - par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " sub error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & " sub error: not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "call") or (instruction(1 to len) = "interrupt") then
                if (stack_ptr >= 31) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & " call error: stack over run, calls to deeply nested!!"
                    severity failure;
                end if;
                if (instruction(1 to len) = "interrupt") then
                    interrupt_entered := true;
                    interrupt_entry_call_stack_ptr := stack_ptr;
                end if;
                stack(stack_ptr) := v_line;
                stack_ptr := stack_ptr + 1;
                -- report " line " & (integer'image(file_line)) & "call stack_ptr incremented to = " & integer'image(stack_ptr);
                v_line := par1 - 1;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "return" or instruction(1 to len) = "end_proc" or instruction(1 to len) = "end_interrupt") then
                act_loop_num := stack_loop_num(stack_ptr);
                if act_loop_num > 0 then
                    if_level := stack_loop_if_enter_level(stack_ptr);
                end if;
                if (stack_ptr <= 0) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & " call error: stack under run??"
                    severity failure;
                end if;
                stack_ptr := stack_ptr - 1;
                if interrupt_entered then
                    if interrupt_entry_call_stack_ptr = stack_ptr then
                        interrupt_in_service := false; -- no nested interrupts are supported!
                    end if;
                end if;
                -- report " line " & (integer'image(file_line)) & "return_call stack_ptr decremented to = " & integer'image(stack_ptr);
                v_line := stack(stack_ptr);

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "proc") then
            -- no action necessary

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "jump") then
                v_line := par1 - 1;
                stack := (others => 0);
                stack_ptr := 0;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "loop") then
                stack_loop_if_enter_level(stack_ptr + 1) := if_level;
                act_loop_num := stack_loop_num(stack_ptr + 1);
                act_loop_num := act_loop_num + 1;
                stack_loop_num(stack_ptr + 1) := act_loop_num;
                stack_loop_line(stack_ptr + 1)(act_loop_num) := v_line;
                stack_curr_loop_count(stack_ptr + 1)(act_loop_num) := 0;
                stack_term_loop_count(stack_ptr + 1)(act_loop_num) := par1;

            -- assert (false)
            -- report " line " & (integer'image(file_line)) & " executing loop command" & lf & "  nested loop:" & ht & integer'image(act_loop_num) & lf & "  loop length:" & ht & integer'image(par1)
            -- severity note;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "end_loop") then
                act_loop_num := stack_loop_num(stack_ptr + 1);
                act_curr_loop_count := stack_curr_loop_count(stack_ptr + 1)(act_loop_num);
                act_curr_loop_count := act_curr_loop_count + 1;
                stack_curr_loop_count(stack_ptr + 1)(act_loop_num) := act_curr_loop_count;
                act_term_loop_count := stack_term_loop_count(stack_ptr + 1)(act_loop_num);
                if (act_curr_loop_count = act_term_loop_count) then
                    act_loop_num := act_loop_num - 1;
                    stack_loop_num(stack_ptr + 1) := act_loop_num;
                else
                    v_line := stack_loop_line(stack_ptr + 1)(act_loop_num);
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "if") then
                if_level := if_level + 1;
                --    assert (false)
                --    report " line " & (integer'image(file_line)) & " executing if command" & lf & "  if_level incremented to " & ht & integer'image(if_level)
                --    severity note;
                if_state(if_level) := false;
                case par2 is
                    when 0 => if (par1 = par3) then
                            if_state(if_level) := true;
                        end if;
                    when 1 => if (par1 > par3) then
                            if_state(if_level) := true;
                        end if;
                    when 2 => if (par1 < par3) then
                            if_state(if_level) := true;
                        end if;
                    when 3 => if (par1 /= par3) then
                            if_state(if_level) := true;
                        end if;
                    when 4 => if (par1 >= par3) then
                            if_state(if_level) := true;
                        end if;
                    when 5 => if (par1 <= par3) then
                            if_state(if_level) := true;
                        end if;
                    when others =>
                        assert (false)
                        report " line " & (integer'image(file_line)) & " error:  if instruction got an unexpected value" & lf & "  in parameter 2!" & lf & "found on line " & (ew_to_str(file_line, dec)) & " in file " & file_name
                        severity failure;
                end case;

                if (if_state(if_level) = false) then
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                     par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                     last_sequ_num, last_sequ_ptr);
                    num_of_if_in_false_if_leave(if_level) := 0;
                    while (num_of_if_in_false_if_leave(if_level) /= 0 or (instruction(1 to len) /= "else" and instruction(1 to len) /= "elsif" and instruction(1 to len) /= "end_if")) loop

                        if (instruction(1 to len) = "if") then
                            num_of_if_in_false_if_leave(if_level) := num_of_if_in_false_if_leave(if_level) + 1;
                        end if;

                        if (instruction(1 to len) = "end_if") then
                            num_of_if_in_false_if_leave(if_level) := num_of_if_in_false_if_leave(if_level) - 1;
                        end if;

                        if (v_line < inst_sequ.num_of_lines) then
                            v_line := v_line + 1;
                            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                             last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " line " & (integer'image(file_line)) & " error:  if instruction unable to find terminating" & lf & "    else, elsif or end_if statement."
                            severity failure;
                        end if;
                    end loop;
                    v_line := v_line - 1; -- re-align so it will be operated on.
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "elsif") then
                if (if_state(if_level) = true) then -- if the if_state is true then skip to the end
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                     par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                     last_sequ_num, last_sequ_ptr);
                    while (instruction(1 to len) /= "if") and instruction(1 to len) /= "end_if" loop
                        if (v_line < inst_sequ.num_of_lines) then
                            v_line := v_line + 1;
                            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                             last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " line " & (integer'image(file_line)) & " error:  if instruction unable to find terminating" & lf & "    else, elsif or end_if statement."
                            severity failure;
                        end if;
                    end loop;
                    v_line := v_line - 1; -- re-align so it will be operated on.

                else
                    case par2 is
                        when 0 => if (par1 = par3) then
                                if_state(if_level) := true;
                            end if;
                        when 1 => if (par1 > par3) then
                                if_state(if_level) := true;
                            end if;
                        when 2 => if (par1 < par3) then
                                if_state(if_level) := true;
                            end if;
                        when 3 => if (par1 /= par3) then
                                if_state(if_level) := true;
                            end if;
                        when 4 => if (par1 >= par3) then
                                if_state(if_level) := true;
                            end if;
                        when 5 => if (par1 <= par3) then
                                if_state(if_level) := true;
                            end if;
                        when others =>
                            assert (false)
                            report " line " & (integer'image(file_line)) & " error:  elsif instruction got an unexpected value" & lf & "  in parameter 2!" & lf & "found on line " & (ew_to_str(file_line, dec)) & " in file " & file_name
                            severity failure;
                    end case;

                    if (if_state(if_level) = false) then
                        v_line := v_line + 1;
                        access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                         par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                         last_sequ_num, last_sequ_ptr);
                        num_of_if_in_false_if_leave(if_level) := 0;
                        while (num_of_if_in_false_if_leave(if_level) /= 0 or (instruction(1 to len) /= "else" and instruction(1 to len) /= "elsif" and instruction(1 to len) /= "end_if")) loop
                            if (instruction(1 to len) = "if") then
                                num_of_if_in_false_if_leave(if_level) := num_of_if_in_false_if_leave(if_level) + 1;
                            end if;
                            if (instruction(1 to len) = "end_if") then
                                num_of_if_in_false_if_leave(if_level) := num_of_if_in_false_if_leave(if_level) - 1;
                            end if;
                            if (v_line < inst_sequ.num_of_lines) then
                                v_line := v_line + 1;
                                access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                                 par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                                 last_sequ_num, last_sequ_ptr);
                            else
                                assert (false)
                                report " line " & (integer'image(file_line)) & " error:  elsif instruction unable to find terminating" & lf & "    else, elsif or end_if statement."
                                severity failure;
                            end if;
                        end loop;
                        v_line := v_line - 1; -- re-align so it will be operated on.
                    end if;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "else") then
                if (if_state(if_level) = true) then -- if the if_state is true then skip the else
                    v_line := v_line + 1;
                    access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                     par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                     last_sequ_num, last_sequ_ptr);
                    while (instruction(1 to len) /= "if") and instruction(1 to len) /= "end_if" loop
                        if (v_line < inst_sequ.num_of_lines) then
                            v_line := v_line + 1;
                            access_inst_sequ(inst_sequ, defined_vars, file_list, v_line, instruction,
                                             par1, par2, par3, par4, par5, par6, txt, len, file_name, file_line,
                                             last_sequ_num, last_sequ_ptr);
                        else
                            assert (false)
                            report " line " & (integer'image(file_line)) & " error:  if instruction unable to find terminating" & lf & "    else, elsif or end_if statement."
                            severity failure;
                        end if;
                    end loop;
                    v_line := v_line - 1; -- re-align so it will be operated on.
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "end_if") then
                if_level := if_level - 1;
            -- assert (false)
            -- report " line " & (integer'image(file_line)) & " executing end_if command" & lf & "  if_level decremented to " & ht & integer'image(if_level)
            -- severity note;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "trace") then
                if par1 /= 0 then
                    trc_on := true;
                else
                    trc_on := false;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "verbosity") then
                loglevel := par1;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "resume") then
                if (par1 = 0) then
                    exit_on_verify_error := true;
                else
                    exit_on_verify_error := false;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "seeds") then
                if (par1 > 0 and par2 > 0) then
                    temp_int := 0;
                    seed1 := par1;
                    seed2 := par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " random_seed error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": seeds must allow only positive values"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "random") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := 0;
                    getrandint(seed1, seed2, par2, par3, temp_int);
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " random error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "mul") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := temp_int * par2;
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " mul error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "shl") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := to_integer(shift_left(to_signed(temp_int, 32), par2));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " mul error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "shr") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := to_integer(shift_right(to_signed(temp_int, 32), par2));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " mul error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "div") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    if (temp_int < 0) then
                        temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                        temp_stdvec_c := not temp_stdvec_a;
                        temp_int := to_integer(signed(temp_stdvec_c));
                        temp_int := temp_int / par2;
                        temp_stdvec_a := std_logic_vector(to_signed((temp_int), 32));
                        temp_stdvec_c := not temp_stdvec_a;
                        temp_int := to_integer(signed(temp_stdvec_c));
                    else
                        temp_int := temp_int / par2;
                    end if;

                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " div error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "inv") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_c := not temp_stdvec_a;
                    temp_int := to_integer(signed(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " inv error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "and") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_b := std_logic_vector(to_signed(par2, 32));
                    temp_stdvec_c := temp_stdvec_a and temp_stdvec_b;
                    temp_int := to_integer(signed(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " and error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "or") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_b := std_logic_vector(to_signed(par2, 32));
                    temp_stdvec_c := temp_stdvec_a or temp_stdvec_b;
                    temp_int := to_integer(signed(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " or error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            elsif (instruction(1 to len) = "xor") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_b := std_logic_vector(to_signed(par2, 32));
                    temp_stdvec_c := temp_stdvec_a xor temp_stdvec_b;
                    temp_int := to_integer(signed(temp_stdvec_c));
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " xor error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "ld") then
                index_variable(defined_vars, par1, temp_int, valid);
                if (valid /= 0) then
                    temp_int := ld(temp_int);
                    update_variable(defined_vars, par1, temp_int, valid);
                    assert (valid /= 0)
                    report " line " & (integer'image(file_line)) & " ld error: vabiable are constant??"
                    severity failure;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            -- error
            elsif (instruction(1 to len) = "error") then
                txt_print_wvar(defined_vars, txt, hex);
                assert (false)
                report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": stop with error"
                severity failure;

            --------------------------------------------------------------------------------
            -- log
            elsif (instruction(1 to len) = "log") then
                if (par1 <= loglevel) then
                    txt_print_wvar(defined_vars, txt, hex);
                end if;
            --------------------------------------------------------------------------------
            --  wait
            --  par1  ns value
            elsif (instruction(1 to len) = "wait") then
                wait for par1 * 1 ns;

            --------------------------------------------------------------------------------
            --  marker
            --  set value of a signal
            --  par1  0  marker number
            --  par2  1  marker value
            elsif (instruction(1 to len) = "marker") then
                if (par1 < 16) then
                    for i in 0 to 15 loop
                        if (par1 = i) then
                            if (par2 = 0) then
                                marker(i) <= '0';
                            else
                                marker(i) <= '1';
                            end if;
                        end if;
                    end loop;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": 16 markers are provided only"
                    severity failure;
                end if;
                wait for 0 ns;

            --------------------------------------------------------------------------------
            --  signal_write
            --  set value of a signal
            --  par1  0  signal number
            --  par2  1  signal value
            elsif (instruction(1 to len) = "signal_write") then

                signal_write(signals_out, par1, par2, valid);

                if (valid = 0) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": signal not defined"
                    severity failure;
                end if;
                wait for 0 ns;

            --------------------------------------------------------------------------------
            --  signal_read or signal_verify
            --  get value of a signal
            --  par1  0  signal number
            --  par2  1  signal value
            --  (par3  data read) expected data for verify
            --  (par4  data read) mask data for verify ( (and read data) and (and expected) data with mask before compare)
            elsif (instruction(1 to len) = "signal_verify" or instruction(1 to len) = "signal_read") then
                temp_int := 0;

                signal_read(signals_in, par1, temp_int, valid);

                if (valid = 0) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": signal not defined"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "get_sig error: not a valid variable??"
                    severity failure;
                end if;

                if (instruction(1 to len) = "signal_verify") then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_b := std_logic_vector(to_signed(par3, 32));
                    temp_stdvec_c := std_logic_vector(to_signed(par4, 32));

                    if (temp_stdvec_c and temp_stdvec_a) /= (temp_stdvec_c and temp_stdvec_b) then
                        assert (false)
                        report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":" & ", read=0x" & to_hstring(temp_stdvec_a) & ", expected=0x" & to_hstring(temp_stdvec_b) & ", mask=0x" & to_hstring(temp_stdvec_c) & " file " & file_name
                        severity failure;
                    end if;
                end if;
                wait for 0 ns;

            --------------------------------------------------------------------------------
            --  bus read (verify_single)
            --  read form the selected bus (and verify)
            --   par1  num    bus number
            --   par2  num    width
            --   par3  adr    address
            --   par4  var    variale to store read data
            --  (par5  data ) expected data for verify
            --  (par6  mask ) mask data for verify
            elsif (instruction(1 to len) = "bus_read" or instruction(1 to len) = "bus_verify") then
                temp_stdvec_a := std_logic_vector(to_signed(par3, tempaddress'length));
                temp_stdvec_b := (others => '0');

                bus_read(clk, bus_down, bus_up, temp_stdvec_a, temp_stdvec_b, par2, par1, valid, successfull, bus_timeouts(par1));

                if (valid = 0) then
                    assert (false)
                    report "Bus number not avalible"
                    severity failure;
                end if;

                if (not successfull) then
                    assert (false)
                    report "Bus Read timeout"
                    severity failure;
                end if;

                temp_int := to_integer(signed(temp_stdvec_b));
                update_variable(defined_vars, par4, temp_int, valid);

                if (valid = 0) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ": not a valid variable??"
                    severity failure;
                end if;

                if (instruction(1 to len) = "bus_verify") then
                    temp_stdvec_a := std_logic_vector(to_signed(temp_int, 32));
                    temp_stdvec_b := std_logic_vector(to_signed(par5, 32));
                    temp_stdvec_c := std_logic_vector(to_signed(par6, 32));

                    if (temp_stdvec_c and temp_stdvec_a) /= (temp_stdvec_c and temp_stdvec_b) then
                        if exit_on_verify_error then
                            assert (false)
                            report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":" & " address=0x" & to_hstring(tempaddress) & ", read=0x" & to_hstring(temp_stdvec_a) & ", expected=0x" & to_hstring(temp_stdvec_b) & ", mask=0x" & to_hstring(temp_stdvec_c)
                            severity failure;
                        else
                            assert (false)
                            report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & ":" & " address=0x" & to_hstring(tempaddress) & ", read=0x" & to_hstring(temp_stdvec_a) & ", expected=0x" & to_hstring(temp_stdvec_b) & ", mask=0x" & to_hstring(temp_stdvec_c)
                            severity error;
                            error_count := error_count + 1;
                        end if;
                    end if;
                end if;
                wait for 0 ns;

            --------------------------------------------------------------------------------
            --  bus write
            --  write date to the selected bus
            --  par1  num   bus number
            --  par2  num   width
            --  par3  adr   address
            --  par4  data  write data
            elsif (instruction(1 to len) = "bus_write") then
                tempaddress := std_logic_vector(to_signed(par3, tempaddress'length));
                tempdata := std_logic_vector(to_signed(par4, tempdata'length));

                bus_write(clk, bus_down, bus_up, tempaddress, tempdata, par2, par1, valid, successfull, bus_timeouts(par1));

                if (valid = 0) then
                    assert (false)
                    report "Bus number not avalible"
                    severity failure;
                end if;

                if (not successfull) then
                    assert (false)
                    report "Bus Read timeout"
                    severity failure;
                end if;

                wait for 0 ns;

            -------------------------------------------------------------------------------
            --  bus_timeout
            --  set the timeout in ns for the bus
            --  par1  num   bus number
            --  par2  num   timeout
            elsif (instruction(1 to len) = "bus_timeout") then
                bus_timeouts(par1) := par2 * 1 ns;

            --------------------------------------------------------------------------------
            --         #     ######   ######      #     #     #
            --        # #    #     #  #     #    # #     #   #
            --       #   #   #     #  #     #   #   #     # #
            --      #     #  ######   ######   #     #     #
            --      #######  #   #    #   #    #######     #
            --      #     #  #    #   #    #   #     #     #
            --      #     #  #     #  #     #  #     #     #
            --------------------------------------------------------------------------------

            --------------------------------------------------------------------------------
            --  array
            --  set value from array
            --  par1  num  array name
            --  par2  num  array size
            elsif (instruction(1 to len) = "array") then
                null; -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------------
            --  array_set
            --  set value from array
            --  par1  num  array number
            --  par2  num  array position
            --  par3  num  value
            elsif (instruction(1 to len) = "array_set") then
                index_array(defined_vars, par1, var_array, valid);

                if (valid = 1) then
                    if (var_array'length > par2) then
                        var_array(par2) := par3;
                    else
                        assert (false)
                        report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: index is out of array size"
                        severity failure;
                    end if;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            --  array_get
            --  get value from array
            --  par1  num  array number
            --  par2  num  array position
            --  par3  num  variable name
            elsif (instruction(1 to len) = "array_get") then
                temp_int := 0;

                index_array(defined_vars, par1, var_array, valid);

                if (valid = 1) then
                    if (var_array'length > par2) then
                        temp_int := var_array(par2);
                    else
                        assert (false)
                        report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: index is out of array size"
                        severity failure;
                    end if;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_variable(defined_vars, par3, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "array_get error: not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            --  array_size
            --  get the size from array
            --  par1  num  array number
            --  par2  num  variable name
            elsif (instruction(1 to len) = "array_size") then
                temp_int := 0;
                index_array(defined_vars, par1, var_array, valid);

                if (valid = 1) then
                    temp_int := var_array'length;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "array_get error: not a valid variable??"
                    severity failure;
                end if;
                
            
            --------------------------------------------------------------------------------
            --  array_pointer
            --  create an pointer from src to destination array
            --  par1  num  destination array
            --  par2  num  source array

            elsif (instruction(1 to len) = "array_pointer") then
                temp_int := 0;
                index_array(defined_vars, par2, var_array, valid);
                if (valid = 0) then
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_array(defined_vars, par1, var_array, valid);
                if (valid = 0) then
                    assert (false)
                    report "array_pointer error: not a array name??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------------
            --     FILE
            --------------------------------------------------------------------------------

            elsif (instruction(1 to len) = "file") then
                null; -- This instruction was implemented while reading the file

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "line_pos") then
                temp_int := 0;
                index_file(defined_vars, par1, var_file_ptr, valid);

                if (valid = 1) then
                    temp_int := var_file_ptr.pos;
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "line_pos error: not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "line_read") then
                temp_int := 0;
                index_file(defined_vars, par1, var_file_ptr, valid);

                if (valid = 1) then
                    file_open(v_stat, var_file, stimulus_path & var_file_ptr.name, read_mode);
                    assert (v_stat = open_ok)
                    report lf & "error: unable to open file " & stimulus_path & var_file_ptr.name
                    severity failure;

                    while not endfile(var_file) loop
                        readline(var_file, var_file_line);
                        temp_int := temp_int + 1;

                        if temp_int = var_file_ptr.pos then
                            read(var_file_line, temp_int);
                            exit; -- Exit the loop after reading the target line
                        end if;

                    end loop;
                    file_close(stimulus);
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "line_read error: not a valid variable??"
                    severity failure;
                end if;

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "line_seek") then
            -- TODO: implement

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "line_write") then
            -- TODO: implement

            --------------------------------------------------------------------------
            elsif (instruction(1 to len) = "line_size") then
                temp_int := 0;
                index_file(defined_vars, par1, var_file_ptr, valid);

                if (valid = 1) then
                    file_open(v_stat, var_file, stimulus_path & var_file_ptr.name, read_mode);
                    assert (v_stat = open_ok)
                    report lf & "error: unable to open file " & stimulus_path & var_file_ptr.name
                    severity failure;

                    while not endfile(var_file) loop
                        readline(var_file, var_file_line);
                        temp_int := temp_int + 1;
                    end loop;

                    file_close(stimulus);
                else
                    assert (false)
                    report " line " & (integer'image(file_line)) & ", " & instruction(1 to len) & " error: array not found"
                    severity failure;
                end if;

                update_variable(defined_vars, par2, temp_int, valid);
                if (valid = 0) then
                    assert (false)
                    report "line_size error: not a valid variable??"
                    severity failure;
                end if;


            --------------------------------------------------------------------------------
            --      #######  #     #  ######
            --      #        ##    #  #     #
            --      #        # #   #  #     #
            --      #####    #  #  #  #     #
            --      #        #   # #  #     #
            --      #        #    ##  #     #
            --      #######  #     #  ######
            --------------------------------------------------------------------------------

            --------------------------------------------------------------------------
            -- catch those little mistakes
            else
                assert (false)
                report " line " & (integer'image(file_line)) & " error:  seems the command  " & ", " & instruction(1 to len) & " was defined but" & lf & "was not found in the elsif chain, please check spelling."
                severity failure;
            end if; -- else if structure end

            -- after the instruction is finished print out any txt and sub vars
            -- txt_print_wvar(defined_vars, txt, hex);

        end loop; -- main loop end

        assert (false)
        report lf & "the end of the simulation! it was not terminated as expected." & lf
        severity failure;

    end process;
end;
