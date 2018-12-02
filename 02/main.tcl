#!/usr/bin/env tclsh

proc part1 {data} {
    set count2 0
    set count3 0
    foreach line $data {
        array unset count
        foreach c [split $line ""] {
            incr count($c)
        }
        set c2 0
        set c3 0
        foreach {k v} [array get count] {
            if {$v == 2} {
                incr c2
            } elseif {$v == 3} {
                incr c3
            }
        }
        if {$c2 > 0} {
            incr count2
        }
        if {$c3 > 0} {
            incr count3
        }
    }
    return [expr {$count2 * $count3}]
}

proc diff1 {a b} {
    set diff -1
    set length [string length $a]
    for {set i 0} {$i < $length} {incr i} {
        if {[string range $a $i $i] != [string range $b $i $i]} {
            if {$diff < 0} {
                set diff $i
            } else {
                return {}
            }
        }
    }
    if {$diff < 0} {
        return {}
    }
    if {$diff == 0} {
        return [string range $a 1 end]
    }
    return [string range $a 0 [expr {$diff - 1}]][string range $a [expr {$diff + 1}] end]
}

proc part2 {data} {
    foreach line1 $data {
        foreach line2 $data {
            set common [diff1 $line1 $line2]
            if {$common != {}} {
                return $common
            }
        }
    }
    return {}
}

set file [open "input.txt"]
set data [split [read $file] "\n"]
close $file

puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
