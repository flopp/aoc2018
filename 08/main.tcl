#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    set data [split [string trim [read $file]] " "]
    close $file
    return $data
}

proc sum_up_metadata {data position} {
    set child_count [lindex $data $position]
    incr position

    set metadata_count [lindex $data $position]
    incr position

    set sum 0
    for {set i 0} {$i < $child_count} {incr i} {
        lassign [sum_up_metadata $data $position] sum position
    }

    for {set i 0} {$i < $metadata_count} {incr i ; incr position} {
        incr sum [lindex $data $position]
    }

    return [list $sum $position]
}

proc part1 {data} {
    lassign [sum_up_metadata $data 0] sum position
    return $sum
}

proc compute_node_value {data position} {
    set child_count [lindex $data $position]
    incr position

    set metadata_count [lindex $data $position]
    incr position

    set child_values {}
    for {set i 0} {$i < $child_count} {incr i} {
        lassign [compute_node_value $data $position] value position
        lappend child_values $value
    }

    set value 0
    if {$child_count == 0} {
        for {set i 0} {$i < $metadata_count} {incr i ; incr position} {
            incr value [lindex $data $position]
        }
    } else {
        for {set i 0} {$i < $metadata_count} {incr i ; incr position} {
            set child_index [expr {[lindex $data $position] - 1}]
            if {($child_index >= 0) && ($child_index < $child_count)} {
                incr value [lindex $child_values $child_index]
            }
        }
    }

    return [list $value $position]
}

proc part2 {data} {
    lassign [compute_node_value $data 0] value position
    return $value
}

set data [read_file "test.txt"]
puts "part1 (test, expected: 138): [part1 $data]"
puts "part2 (test, expected: 66): [part2 $data]"

set data [read_file "input.txt"]
puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
