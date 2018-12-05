#!/usr/bin/env tclsh

proc opposite {c0 c1} {
    if {[string compare -nocase $c0 $c1] != 0} {
        return 0
    }
    return [expr {$c0 == $c1}] {
        return 0
    }
    return 1
}

proc part1 {data} {
    set i 0
    set length [llength $data]
    while {$i < $length} {
        set j $i
        incr j
        if {[opposite [lindex $data $i] [lindex $data $j]]} {
            set data [lreplace $data $i $j]
            incr i -1
            if {$i < 0} {
                set i 0
            }
            incr length -2
        } else {
            incr i
        }
    }
    return [llength $data]
}

proc part2 {data} {
    array unset used
    set best_length [llength $data]

    foreach override $data {
        set override [string tolower $override]
        if {[info exists used($override)]} {
            continue
        }
        set used($override) 1

        set d {}
        for {set i 0} {$i < [llength $data]} {incr i} {
            set c [lindex $data $i]
            if {[string compare -nocase $c $override] != 0} {
                lappend d $c
            }
        }

        set length [part1 $d]
        if {$length < $best_length} {
            set best_length $length
        }
    }

    return $best_length
}

set file [open "test.txt"]
set data [split [string trim [read $file]] ""]
close $file

puts "part1 (test): [part1 $data]"
puts "part2 (test): [part2 $data]"

set file [open "input.txt"]
set data [split [string trim [read $file]] ""]
close $file

puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
