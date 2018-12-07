#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    foreach line [split [read $file] "\n"] {
        if {$line == ""} {
            continue
        }

        if {[regexp {^([0-9]+), ([0-9]+)$} $line -> x y]} {
            lappend data [list $x $y]
        } else {
            return -code error "Bad line: <$line>"
        }
    }
    close $file
    return $data
}

proc manhattan {x0 y0 x1 y1} {
    return [expr {abs($x0 - $x1) + abs($y0 - $y1)}]
}

proc part1 {data} {
    lassign [lindex $data 0] min_x min_y
    set max_x $min_x
    set max_y $min_y

    foreach xy $data {
        lassign $xy x y
        if {$x < $min_x} {
            set min_x $x
        } elseif {$x > $max_x} {
            set max_x $x
        }
        if {$y < $min_y} {
            set min_y $y
        } elseif {$y > $max_y} {
            set max_y $y
        }
    }
    set d_x [expr {$max_x - $min_x}]
    set d_y [expr {$max_y - $min_y}]
    set x0 [expr {$min_x - $d_x}]
    set x1 [expr {$max_x + $d_x}]
    set y0 [expr {$min_y - $d_y}]
    set y1 [expr {$max_y + $d_y}]

    array unset count
    array unset infinite
    for {set y $y0} {$y <= $y1} {incr y} {
        for {set x $x0} {$x <= $x1} {incr x} {
            set i 0
            set multiple 0
            set best_d 0
            set best_i 0
            foreach xy $data {
                incr i
                lassign $xy xi yi
                set d [manhattan $x $y $xi $yi]
                if {($best_i == 0) || ($d < $best_d)} {
                    set best_i $i
                    set best_d $d
                    set multiple 0
                } elseif {$d == $best_d} {
                    set multiple 1
                }

            }
            if {!$multiple} {
                incr count($best_i)
                if {($x == $x0) || ($x == $x1) || ($y == $y0) || ($y == $y1)} {
                    set infinite($best_i) 1
                }
            }
        }
    }

    set best_count 0
    foreach {i c} [array get count] {
        if {[info exists infinite($i)]} {
            continue
        } elseif {$c > $best_count} {
            set best_count $c
        }
    }

    return $best_count
}

proc part2 {max_sum data} {
    lassign [lindex $data 0] min_x min_y
    set max_x $min_x
    set max_y $min_y

    foreach xy $data {
        lassign $xy x y
        if {$x < $min_x} {
            set min_x $x
        } elseif {$x > $max_x} {
            set max_x $x
        }
        if {$y < $min_y} {
            set min_y $y
        } elseif {$y > $max_y} {
            set max_y $y
        }
    }
    set d_x [expr {$max_x - $min_x}]
    set d_y [expr {$max_y - $min_y}]
    set x0 [expr {$min_x - $d_x}]
    set x1 [expr {$max_x + $d_x}]
    set y0 [expr {$min_y - $d_y}]
    set y1 [expr {$max_y + $d_y}]

    set count 0
    for {set y $y0} {$y <= $y1} {incr y} {
        for {set x $x0} {$x <= $x1} {incr x} {
            set sum 0
            foreach xy $data {
                lassign $xy xi yi
                incr sum [manhattan $x $y $xi $yi]
                if {$sum >= $max_sum} {
                    break
                }
            }
            if {$sum < $max_sum} {
                incr count
            }
        }
    }

    return $count
}

set data [read_file "test.txt"]
puts "part1 (test, expected: 17): [part1 $data]"
puts "part2 (test, expected: 16): [part2 32 $data]"

set data [read_file "input.txt"]
puts "part1: [part1 $data]"
puts "part2: [part2 10000 $data]"
