#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    foreach line [split [read $file] "\n"] {
        if {$line == ""} {
            continue
        }

        if {[regexp {^Step (.) must be finished before step (.) can begin\.$} $line -> x y]} {
            lappend data [list $x $y]
        } else {
            return -code error "Bad line: <$line>"
        }
    }
    close $file
    return $data
}

proc part1 {data} {
    array set open    {}
    array set pre     {}
    array set post    {}

    foreach xy $data {
        lassign $xy x y
        set pre($x)  {}
        set post($x) {}
        set pre($y)  {}
        set post($y) {}
    }

    foreach xy $data {
        lassign $xy x y
        lappend pre($y)  $x
        lappend post($x) $y
    }

    foreach x [array names pre] {
        if {$pre($x) == {}} {
            set open($x) $x
        }
    }

    set order {}
    while {[array size open] > 0} {
        set x [lindex [lsort [array names open]] 0]
        array unset open $x
        lappend order $x

        foreach y $post($x) {
            set pre_y $pre($y)
            set p [lsearch $pre_y $x]
            set pre_y [lreplace $pre_y $p $p]
            if {[llength $pre_y] == 0} {
                set open($y) $y
            }
            set pre($y) $pre_y
        }
        set post($x) {}
    }

    return [join $order ""]
}

proc part2 {data workers offset} {
    array set open    {}
    array set pre     {}
    array set post    {}

    foreach xy $data {
        lassign $xy x y
        set pre($x)  {}
        set post($x) {}
        set pre($y)  {}
        set post($y) {}
    }

    foreach xy $data {
        lassign $xy x y
        lappend pre($y)  $x
        lappend post($x) $y
    }

    foreach x [array names pre] {
        if {$pre($x) == {}} {
            set open($x) $x
        }
    }

    set work {}
    for {set i 0} {$i < $workers} {incr i} {
        lappend work {. 0}
    }

    for {set time 0} {1} {incr time} {
        set available_workers {}
        set new_work {}
        for {set i 0} {$i < $workers} {incr i} {
            set x_w [lindex $work $i]
            lassign $x_w x w
            if {$w == 0} {
                lappend available_workers $i
                lappend new_work {. 0}
            } else {
                incr w -1
                if {$w == 0} {
                    lappend available_workers $i
                    lappend new_work {. 0}

                    foreach y $post($x) {
                        set pre_y $pre($y)
                        set p [lsearch $pre_y $x]
                        set pre_y [lreplace $pre_y $p $p]
                        if {[llength $pre_y] == 0} {
                            set open($y) $y
                        }
                        set pre($y) $pre_y
                    }
                    set post($x) {}
                } else {
                    lappend new_work [list $x $w]
                }
            }
        }
        set work $new_work

        if {$available_workers == {}} {
            continue
        }
        if {[array size open] == 0} {
            if {[llength $available_workers] == $workers} {
                break
            }
            continue
        }

        foreach w $available_workers {
            if {[array size open] == 0} {
                break
            }
            set x [lindex [lsort [array names open]] 0]
            array unset open $x
            scan $x %c xx
            set xx [expr {$xx - 64 + $offset}]
            set work [lreplace $work $w $w [list $x $xx]]
        }
    }

    return $time
}

set data [read_file "test.txt"]
puts "part1 (test, expected: CABDFE): [part1 $data]"
puts "part2 (test, expected: 15): [part2 $data 2 0]"

set data [read_file "input.txt"]
puts "part1: [part1 $data]"
puts "part2: [part2 $data 5 60]"
