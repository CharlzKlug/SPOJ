# Эта хитроумная процедура получает
# координаты из stdin.
# Примечание: подразумевается, что форматирование ввода
# координат крайне отвратительное. Могут быть пустые строки,
# могут быть много лишних пробелов, в одной строке может
# быть одна координата, а в другой строке - другая.
proc get_values {values_number} {
    set numbers_list {}

    while {[llength $numbers_list] < $values_number} {
	gets stdin some_string
	lappend numbers_list \
	    {*}[regsub -all {\s+} \
		    [string trim $some_string] " "]
    }

    return $numbers_list
}

proc get_farthest_planet_index {planets_number} {
    set coords_list [get_values [expr {$planets_number * 2}]]

    return [get_index $coords_list]
}

proc get_index {coords_list} {
    set farthest_distance 0
    set farthest_planet_index 0
    
    for {set i 0} {$i < [llength $coords_list]} {incr i 2} {
	set x_coord [lindex $coords_list $i]
	set y_coord [lindex $coords_list [expr {$i + 1}]]
	set new_distance [expr {$x_coord**2 + $y_coord**2}]

	if {$new_distance > $farthest_distance} {
	    set farthest_distance $new_distance
	    set farthest_planet_index $i
	} else {}
    }

    return [expr {[expr {$farthest_planet_index / 2}] + 1}]
}

proc proceed_cases {cases_number} {
    for {set i 1} {$i <= $cases_number} {incr i} {
	gets stdin string_with_planets_number
	set planets_number 0
	if {[scan $string_with_planets_number "%d" planets_number] == 1} {
	    puts "Case $i: [get_farthest_planet_index $planets_number]"
	} else {
	    error "Wrong planets number!"
	}
    }
}

proc main {} {
    gets stdin cases_quantity_string
    set cases_quantity 0

    if {[scan $cases_quantity_string "%d" cases_quantity] == 1} {

	if {$cases_quantity > 0} {
	    proceed_cases $cases_quantity
	    exit 0
	} else {
	    error "Wrong cases number!"
	    exit -1
	}
    } else {
	error "Wrong cases string!"
	exit -2
    }
}

main
