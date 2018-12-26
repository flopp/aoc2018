#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    foreach line [split [read $file] "\n"] {
        if {$line == {}} {
            #
        } elseif {[regexp {^\s*(-?[0-9]+)\s*,\s*(-?[0-9]+)\s*,\s*(-?[0-9]+)\s*,\s*(-?[0-9]+)\s*$} $line -> a b c d]} {
            lappend data [list $a $b $c $d]
        } else {
            error "bad line: $line"
        }
    }
    close $file
    return $data
}


proc manhattan_dist {abcd ABCD} {
    lassign $abcd a b c d
    lassign $ABCD A B C D
    return [expr {abs($a - $A) + abs($b - $B) + abs($c - $C) + abs($d - $D)}]
}

proc part1 {data} {
    set constellations 0
    array unset abcd2constellation

    foreach abcd $data {
        array unset cons
        foreach {ABCD con} [array get abcd2constellation] {
            set dist [manhattan_dist $abcd $ABCD]
            if {$dist <= 3} {
                set cons($con) $con
            }
        }
        if {[array size cons] == 0} {
            incr constellations
            set abcd2constellation($abcd) $constellations
        } elseif {[array size cons] == 1} {
            set master_con [lindex [array names cons] 0]
            set abcd2constellation($abcd) $master_con
        } else {
            set master_con [lindex [array names cons] 0]
            array unset new
            foreach {ABCD con} [array get abcd2constellation] {
                if {[info exists cons($con)]} {
                    set new($ABCD) $master_con
                } else {
                    set new($ABCD) $con
                }
            }
            set new($abcd) $master_con
            array set abcd2constellation [array get new]
        }
    }

    array unset cons
    foreach {ABCD con} [array get abcd2constellation] {
        set cons($con) $con
    }
    return [array size cons]
}

puts "part1 (test1, expected=2):  [part1 [read_file "test1.txt"]]"
puts "part1 (test2, expected=4):  [part1 [read_file "test2.txt"]]"
puts "part1 (test3, expected=3):  [part1 [read_file "test3.txt"]]"
puts "part1 (test4, expected=8):  [part1 [read_file "test4.txt"]]"

puts "part1:                      [part1 [read_file "input.txt"]]"
