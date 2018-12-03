#!/usr/bin/env tclsh

proc part1 {data} {
    array unset grid
    set re {^#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)$}
    foreach line $data {
        set id {}
        set x {}
        set y {}
        set w {}
        set h {}
        regexp $re $line -> id x y w h
        for {set i 0} {$i < $w} {incr i} {
            for {set j 0} {$j < $h} {incr j} {
                incr grid([expr {$x + $i}]:[expr {$y + $j}])
            }
        }
    }
    set count 0
    foreach {x:y c} [array get grid] {
        if {$c >= 2} {
            incr count
        }
    }
    return $count
}

proc part2 {data} {
    array unset grid
    set re {^#([0-9]+) @ ([0-9]+),([0-9]+): ([0-9]+)x([0-9]+)$}
    foreach line $data {
        regexp $re $line -> id x y w h
        for {set i 0} {$i < $w} {incr i} {
            for {set j 0} {$j < $h} {incr j} {
                incr grid([expr {$x + $i}]:[expr {$y + $j}])
            }
        }
    }
    foreach line $data {
        regexp $re $line -> id x y w h
        set ok 1
        for {set i 0} {$i < $w} {incr i} {
            for {set j 0} {$j < $h} {incr j} {
                if {$grid([expr {$x + $i}]:[expr {$y + $j}]) != 1} {
                    set ok 0
                    break
                }
            }
        }
        if {$ok} {
            return $id
        }
    }
    return {}
}

set file [open "input.txt"]
set data [split [read $file] "\n"]
close $file

puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
