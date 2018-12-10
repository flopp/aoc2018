#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    set re {^position=<(.*),(.*)> velocity=<(.*),(.*)>$}
    foreach line [split [read $file] "\n"] {
        if {$line == {}} {
            #
        } elseif {[regexp $re $line -> x y dx dy]} {
            lappend data [string trim $x] [string trim $y] [string trim $dx] [string trim $dy]
        } else {
            error "bad line: $line"
        }
    }
    close $file
    return $data
}


proc print {data} {
    array unset grid
    set min_x {}
    set max_x {}
    set min_y {}
    set max_y {}
    foreach {x y dx dy} $data {
        set grid($x:$y) 1
        if {$min_x == {}} {
            set min_x $x
            set max_x $x
            set min_y $y
            set max_y $y
        } else {
            set min_x [expr min($x, $min_x)]
            set max_x [expr max($x, $max_x)]
            set min_y [expr min($y, $min_y)]
            set max_y [expr max($y, $max_y)]
        }
    }
    for {set y $min_y} {$y <= $max_y} {incr y} {
        for {set x $min_x} {$x <= $max_x} {incr x} {
            if {[info exists grid($x:$y)]} {
                puts -nonewline #
            } else {
                puts -nonewline .
            }
        }
        puts ""
    }
}


proc part1 {data} {
    for {set loop 1} {1} {incr loop} {
        set data2 {}
        set min_x {}
        set max_x {}
        foreach {x y dx dy} $data {
            incr x $dx
            incr y $dy
            lappend data2 $x $y $dx $dy
            if {$min_x == {}} {
                set min_x $x
                set max_x $x
            } else {
                set min_x [expr min($x, $min_x)]
                set max_x [expr max($x, $max_x)]
            }
        }
        set data $data2
        if {[expr {$max_x - $min_x}] < [llength $data]} {
            set score 0
            array unset grid
            foreach {x y dx dy} $data {
                set grid($x:$y) 1
            }
            foreach xy [array names grid] {
                lassign [split $xy ":"] x y
                set x0 $x ; incr x0 -1
                set x1 $x ; incr x1 1
                set y0 $y ; incr y0 -1
                set y1 $y ; incr y1 1
                if {[info exists grid($x0:$y0)] ||
                    [info exists grid($x0:$y)] ||
                    [info exists grid($x0:$y1)] ||
                    [info exists grid($x:$y0)] ||
                    [info exists grid($x:$y1)] ||
                    [info exists grid($x1:$y0)] ||
                    [info exists grid($x1:$y)] ||
                    [info exists grid($x1:$y1)]} {
                    #
                } else {
                    incr score
                }
            }
            if {$score == 0} {
                print $data
                return $loop
            }
        }
    }
    return {}
}


proc part2 {data} {
    return {}
}


set data [read_file "test.txt"]
puts "part12 (test, expected=3): [part1 $data]"

set data [read_file "input.txt"]
puts "part12: [part1 $data]"
