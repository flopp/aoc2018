#!/usr/bin/env tclsh

proc part1 {data} {
    set value 0
    foreach d $data {
        incr value $d
    }
    return $value
}

proc part2 {data} {
    array set seen {}
    set value 0
    while {1} {
        foreach d $data {
            incr value $d
            if {[info exists seen($value)]} {
                return $value
            }
            set seen($value) 1
        }
    }
    return {}
}

set file [open "input.txt"]
set data [split [read $file] "\n"]
close $file

puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
