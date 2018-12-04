#!/usr/bin/env tclsh

proc remove0 {s} {
    while {([string length $s] > 1) && ([string range $s 0 0] == "0")} {
        set s [string range $s 1 end]
    }
    return $s
}

proc update_timetable {
    timetable_name
    guard
    y0 m0 d0 hh0 mm0
    y1 m1 d1 hh1 mm1
} {
    upvar 1 $timetable_name timetable
    if {$y0 != $y1} {
        return -code error "differing y"
    }
    if {$m0 != $m1} {
        return -code error "differing m"
    }
    if {$d0 != $d1} {
        return -code error "differing d"
    }
    if {$hh0 != $hh1} {
        return -code error "differing hh"
    }
    set i0 [remove0 $mm0]
    set i1 [remove0 $mm1]
    for {set i $i0} {$i < $i1} {incr i} {
        incr timetable($guard:$i)
    }
}

proc part1 {data} {
    array unset timetable
    array unset guards

    set re_guard {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] Guard #([0-9]+) begins shift$}
    set re_sleep {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] falls asleep$}
    set re_wake  {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] wakes up$}

    set guard {}
    set s_y   {}
    set s_m   {}
    set s_d   {}
    set s_hh  {}
    set s_mm  {}

    foreach line [lsort $data] {
        if {$line == {}} {
            continue
        }
        set y  {}
        set m  {}
        set d  {}
        set hh {}
        set mm {}
        if {[regexp $re_guard $line -> y m d hh mm guard]} {
            set guards($guard) $guard
            set s_y  {}
            set s_m  {}
            set s_d  {}
            set s_hh {}
            set s_mm {}
        } elseif {[regexp $re_sleep $line -> y m d hh mm]} {
            if {$guard == {}} {
                return -code error "No active guard"
            }
            if {$s_y != {}} {
                return -code error "Alreay asleep"
            }
            set s_y  $y
            set s_m  $m
            set s_d  $d
            set s_hh $hh
            set s_mm $mm

        } elseif {[regexp $re_wake $line -> y m d hh mm]} {
            if {$guard == {}} {
                return -code error "No active guard"
            }
            if {$s_y == {}} {
                return -code error "Not asleep"
            }
            update_timetable timetable $guard $s_y $s_m $s_d $s_hh $s_mm $y $m $d $hh $mm
            set s_y  {}
            set s_m  {}
            set s_d  {}
            set s_hh {}
            set s_mm {}
        } else {
            return -code error "Bad line: $line"
        }
    }

    set best_guard {}
    set best_guard_asleep 0
    foreach guard [array names guards] {
        set sum_asleep 0
        set max_asleep 0
        set max_asleep_minute {}
        foreach {key count} [array get timetable $guard:*] {
            incr sum_asleep $count
            if {$count > $max_asleep} {
                set max_asleep $count
                set max_asleep_minute [lindex [split $key :] 1]
            }
        }
        if {$sum_asleep > $best_guard_asleep} {
            set best_guard [expr {$guard * $max_asleep_minute}]
            set best_guard_asleep $sum_asleep
        }
    }

    return $best_guard
}

proc part2 {data} {
    array unset timetable
    array unset guards

    set re_guard {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] Guard #([0-9]+) begins shift$}
    set re_sleep {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] falls asleep$}
    set re_wake  {^\[([0-9]+)-([0-9]+)-([0-9]+) ([0-9]+):([0-9]+)\] wakes up$}

    set guard {}
    set s_y   {}
    set s_m   {}
    set s_d   {}
    set s_hh  {}
    set s_mm  {}

    foreach line [lsort $data] {
        if {$line == {}} {
            continue
        }
        set y  {}
        set m  {}
        set d  {}
        set hh {}
        set mm {}
        if {[regexp $re_guard $line -> y m d hh mm guard]} {
            set guards($guard) $guard
            set s_y  {}
            set s_m  {}
            set s_d  {}
            set s_hh {}
            set s_mm {}
        } elseif {[regexp $re_sleep $line -> y m d hh mm]} {
            if {$guard == {}} {
                return -code error "No active guard"
            }
            if {$s_y != {}} {
                return -code error "Alreay asleep"
            }
            set s_y  $y
            set s_m  $m
            set s_d  $d
            set s_hh $hh
            set s_mm $mm

        } elseif {[regexp $re_wake $line -> y m d hh mm]} {
            if {$guard == {}} {
                return -code error "No active guard"
            }
            if {$s_y == {}} {
                return -code error "Not asleep"
            }
            update_timetable timetable $guard $s_y $s_m $s_d $s_hh $s_mm $y $m $d $hh $mm
            set s_y  {}
            set s_m  {}
            set s_d  {}
            set s_hh {}
            set s_mm {}
        } else {
            return -code error "Bad line: $line"
        }
    }

    set best_guard {}
    set best_guard_asleep 0
    foreach guard [array names guards] {
        set max_asleep 0
        set max_asleep_minute {}
        foreach {key count} [array get timetable $guard:*] {
            incr sum_asleep $count
            if {$count > $max_asleep} {
                set max_asleep $count
                set max_asleep_minute [lindex [split $key :] 1]
            }
        }
        if {$max_asleep > $best_guard_asleep} {
            set best_guard [expr {$guard * $max_asleep_minute}]
            set best_guard_asleep $max_asleep
        }
    }

    return $best_guard
}

set file [open "input.txt"]
set data [split [read $file] "\n"]
close $file

puts "part1: [part1 $data]"
puts "part2: [part2 $data]"
