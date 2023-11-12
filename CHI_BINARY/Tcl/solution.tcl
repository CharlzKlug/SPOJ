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

proc mul_naive {arg1 arg2} {
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

proc get-values-list-stdin {} {
    gets stdin some_string
    return [regsub -all {\s+} \
		[string trim $some_string] " "]
}

variable values_list {}

proc get-value {} {
    upvar #0 values_list val_list
    while {[llength $val_list] == 0} {
	set val_list [get-values-list-stdin]
    }
    set list_head_element [lindex $val_list 0]
    set val_list [lreplace $val_list 0 0]
    return $list_head_element
}

proc main {} {
    set tests_quantity [get-value]
    # array set operations { 0 is_greater 1 add 10 minus 11 mul_naive 100 div_bool }
    array set operations {
	0 is_greater
	1 add
	10 minus
	11 mul_naive
	100 div_bool
    }
    while {$tests_quantity != 0} {
	set operation [get-value]
	puts "[$operations($operation) [get-value] [get-value]]"
	set tests_quantity [minus $tests_quantity 1]
    }
}

main
