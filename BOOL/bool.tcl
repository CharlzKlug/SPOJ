proc not {input_value} {
    string map {0 1 1 0} $input_value
}

proc is_empty {str} {
    return [string equal $str ""]
}

proc trim_leading_zero {arg} {
    return [regexp -all -inline {[1-9]{1,}[0-9]*|0$} $arg]
}

proc binary_function {table arg1 arg2} {
    return [lindex [lindex $table $arg1] $arg2]
}

proc and {arg1 arg2} {
    return [binary_function {{0 0} {0 1}} $arg1 $arg2]
}

proc or {arg1 arg2} {
    return [binary_function {{0 1} {1 1}} $arg1 $arg2]
}

proc xor {arg1 arg2} {
    return [binary_function {{0 1} {1 0}} $arg1 $arg2]
}

proc >> {inputval} {
    set result [string range $inputval 0 end-1]
    if [is_empty $result] {set result 0}
    return $result
}

proc << {inputval} {
    if {$inputval != 0} {
	return ${inputval}0
    }
    return 0
}


proc get_last_num {input_val} {
    if [is_empty $input_val] {
	return 0
    }
    return [string index $input_val end]
}

proc add_bit {arg1 arg2} {
    return [binary_function {{{0 0} {0 1}} {{0 1} {1 0}}} $arg1 $arg2]
}

proc add {arg1 arg2} {
    set register 0
    set result ""
    while {$arg1 != "" || $arg2 != ""} {
	if {$arg1 == ""} {
	    set arg1 0
	}
	if {$arg2 == ""} {
	    set arg2 0
	}
	set result_bit [add_bit [get_last_num $arg1] [get_last_num $arg2]]
	set result_register [add_bit $register [lindex $result_bit 1]]
	set register_new_val [add_bit [lindex $result_bit 0] [lindex $result_register 0]]
	set result [lindex ${result_register} 1]$result
	set register [lindex $register_new_val 1]
	set arg1 [string range $arg1 0 end-1]
	set arg2 [string range $arg2 0 end-1]
    }
    if {$register == 0} {set register ""}
    return $register$result
}

proc is_greater {arg1 arg2} {
    if {[string length $arg1] > [string length $arg2]} {
	return 1
    }
    if {[string length $arg1] < [string length $arg2]} {
	return 0
    }
    set greater_flag 0
    while {![is_empty $arg1] && $greater_flag == 0} {
	set head1 [string index $arg1 0]
	set head2 [string index $arg2 0]
		
	if [xor $head1 $head2] {
	    if [and $head1 1] {
		return 1
	    } else {
		return 0
	    }
	}
	set arg1 [string range $arg1 1 end]
	set arg2 [string range $arg2 1 end]
    }
    return 0
}

proc is_equal {arg1 arg2} {
    if {[is_empty $arg1] && [is_empty $arg2]} {
	return 1
    }
    if {[is_empty $arg1] && ![is_empty $arg2]} {
	return 0
    }
    if {![is_empty $arg1] && [is_empty $arg2]} {
	return 0
    }
    while {![is_empty $arg1] && ![is_empty $arg2]} {
	set last_bit1 [get_last_num $arg1]
	set last_bit2 [get_last_num $arg2]
	if {[xor $last_bit1 $last_bit2]} {
	    return 0
	}
	set arg1 [string range $arg1 0 end-1]
	set arg2 [string range $arg2 0 end-1]
    }
    tailcall is_equal $arg1 $arg2
}

proc minus {arg1 arg2} {
    set register 0 ;# Регистр, обозначающий есть ли заём единицы
    set result ""
    while {![is_empty $arg2] || ![is_empty $arg1]} {
	set last_bit1 [get_last_num $arg1]
	if [is_empty $last_bit1] {set last_bit1 0}
	if {$register == 1} {
	    if {$last_bit1 == 1} {
		set last_bit1 0
		set register 0
	    } else {
		set last_bit1 1
	    }
	}
	set last_bit2 [get_last_num $arg2]
	if [is_empty $last_bit2] {set last_bit2 0}
	if ![xor $last_bit1 $last_bit2] {
	    set result 0$result
	    set arg1 [string range $arg1 0 end-1]
	    set arg2 [string range $arg2 0 end-1]
	    continue
	}
	if {[or $last_bit1 $last_bit2] && [and $last_bit1 1]} {
	    set result 1$result
	    set arg1 [string range $arg1 0 end-1]
	    set arg2 [string range $arg2 0 end-1]
	    continue
	}
	# Здесь обработка случая, когда $arg1 = 0 и $arg2 = 1.
	set result 1$result
	set register 1
	set arg1 [string range $arg1 0 end-1]
	set arg2 [string range $arg2 0 end-1]
    }
    return [trim_leading_zero $result]
}

proc mul-naive {arg1 arg2} {
    set result "0"
    while {![is_empty $arg2]} {
	if {[get_last_num $arg2] == 1} {
	    set result [add $arg1 $result]
	}
	set arg2 [string range $arg2 0 end-1]
	set arg1 ${arg1}0
    }
    return [trim_leading_zero $result]
}

proc mul-karacuba {arg1 arg2 length_threshold} {
    set arg1_length [string length $arg1]
    set arg2_length [string length $arg2]
    set min_length [::tcl::mathfunc::min $arg1_length $arg2_length]
    if {$min_length <= $length_threshold} {
	return [mul-naive $arg1 $arg2]
    }
    set half [::tcl::mathop::/ $min_length 2]
    # a*x + b
    # c*x + d
    set arg_a [string range $arg1 0 end-$half]
    set arg_b [string range $arg1 end-[::tcl::mathop::- $half 1] end]
    set arg_c [string range $arg2 0 end-$half]
    set arg_d [string range $arg2 end-[::tcl::mathop::- $half 1] end]

    set amc [mul-karacuba $arg_a $arg_c $length_threshold]
    set apb [add $arg_a $arg_b]
    set cpd [add $arg_c $arg_d]
    set bmd [mul-karacuba $arg_b $arg_d $length_threshold]
    
    set sp [mul-karacuba $apb $cpd $length_threshold]
    
    set mid [minus [minus $sp $amc] $bmd]
    
    return [add [add $amc[string repeat 0 [::tcl::mathop::* $half 2]] $mid[string repeat 0 $half]] $bmd]
}

# Max: 1606938044258990275541962092341162602522202993782792835301375

proc bin2decimal {arg} {
    set result 0
    set power 0
    while {$arg != ""} {
	set ln [get_last_num $arg]
	set result [expr {$ln * (2 ** $power) + $result}]
	set power [expr {$power + 1}]
	set arg [string range $arg 0 end-1]
    }
    return $result
}

set input_max_val 1606938044258990275541962092341162602522202993782792835301375
#set input_max_val 20

proc genval {} {
    upvar #0 input_max_val inner_max
    return [::tcl::mathfunc::round [::tcl::mathop::* [::tcl::mathfunc::rand] $inner_max]]
}

proc dec2bin i {
    #returns a string, e.g. dec2bin 10 => 1010 
    set res {} 
    while {$i>0} {
        set res [expr {$i%2}]$res
        set i [expr {$i/2}]
    }
    if {$res == {}} {set res 0}
    return $res
}

proc test_mul_naive {tests_number} {
    for {set i 0} {$i < $tests_number} {incr i} {
	set a [genval]
	set b [genval]
	set result [expr {$a * $b}]
	if {[mul-naive [dec2bin $a] [dec2bin $b]] != [dec2bin $result]} {
	    error "Error! $a * $b != $result"
	}
	puts "Test $i --- passed."
    }
    return "All tests passed!"
}

proc test_mul_karacuba {tests_number} {
    for {set i 0} {$i < $tests_number} {incr i} {
	set a [genval]
	set b [genval]
	set result [expr {$a * $b}]
	if {[mul-karacuba [dec2bin $a] [dec2bin $b] 20] != [dec2bin $result]} {
	    error "Error! $a * $b != $result"
	}
	puts "Test $i --- passed."
    }
    return "All tests passed!"
}

proc div_bool {numerator denumerator} {
    if {[is_empty $numerator] ||
	[is_empty $denumerator] ||
	$denumerator == 0
    } {
	return {0 0}
    }
    set quotient 0
    set remainder 0

    while {![is_empty $numerator]} {
	set remainder [trim_leading_zero $remainder[string index $numerator 0]]
	if {[is_greater $remainder $denumerator] ||
	    [is_equal $remainder $denumerator]} {
	    set quotient ${quotient}1
	    set remainder [minus $remainder $denumerator]
	} else {
	    set quotient ${quotient}0
	}
	set numerator [string range $numerator 1 end]
    }
    return [list [trim_leading_zero $quotient] $remainder]
}

proc test_uni {tests_number condition} {
    for {set i 0} {$i < $tests_number} {incr i} {
	set a [genval]
	set b [genval]
	if [eval $condition] {
	    puts "Test $i --- passed."
	} else {
	    error "Error! $a, $b"
	}
    }
    puts "All tests passed!"
}

proc test_add {tests_number} {
    test_uni $tests_number {expr {[dec2bin [expr {$a + $b}]] == \
				      [add [dec2bin $a] [dec2bin $b]]}}
}

proc test_is_greater {tests_number} {
    test_uni $tests_number {expr {$a > $b == [is_greater [dec2bin $a] [dec2bin $b]]}}
}

proc test_div_bool {tests_number} {
    test_uni $tests_number {expr {[div_bool [dec2bin $a] [dec2bin $b]] ==
				  [apply {{x y} {list [dec2bin [expr {$x / $y}]] \
						     [dec2bin [expr {$x % $y}]]}} \
				   $a $b]}}}

proc enlarge {input_a input_b} {
    set addition 2
    while {$addition <= $input_b} {
	set addition [expr {$addition * 2}]
    }
    return [expr {$addition + $input_a}]
}

proc dec_minus {input_a input_b} {
    if {$input_a < $input_b} {
	set input_a [enlarge $input_a $input_b]
    }
    return [expr {$input_a - $input_b}]
}

proc test_minus {tests_number} {
    test_uni $tests_number {expr {[dec2bin [dec_minus $a $b]] == \
				      [minus [dec2bin $a] [dec2bin $b]]}}
}
