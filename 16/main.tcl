#!/usr/bin/env tclsh

proc read_file {file_name} {
    set data {}
    set file [open $file_name]
    set re_before      {^Before:\s*\[([0-9]+), ([0-9]+), ([0-9]+), ([0-9]+)\]$}
    set re_after       {^After:\s*\[([0-9]+), ([0-9]+), ([0-9]+), ([0-9]+)\]$}
    set re_instruction {^([0-9]+) ([0-9]+) ([0-9]+) ([0-9]+)$}

    set samples {}
    set sample {}
    set test_program {}
    foreach line [split [read $file] "\n"] {
        if {$line == {}} {
            #
        } elseif {[regexp $re_before $line -> r0 r1 r2 r3]} {
            lappend sample [list $r0 $r1 $r2 $r3]
        } elseif {[regexp $re_after $line -> r0 r1 r2 r3]} {
            lappend sample [list $r0 $r1 $r2 $r3]
            lappend samples $sample
            set sample {}
        } elseif {[regexp $re_instruction $line -> opcode A B C]} {
            if {$sample != {}} {
                lappend sample [list $opcode $A $B $C]
            } else {
                lappend test_program [list $opcode $A $B $C]
            }
        } else {
            error "bad line: $line"
        }
    }
    close $file
    return [list $samples $test_program]
}

proc addr {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) + $r($B)}]
}

proc addi {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) + $B}]
}

proc mulr {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) * $r($B)}]
}

proc muli {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) * $B}]
}

proc banr {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) & $r($B)}]
}

proc bani {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) & $B}]
}

proc borr {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) | $r($B)}]
}

proc bori {registers A B C} {
    upvar 1 $registers r
    set r($C) [expr {$r($A) | $B}]
}

proc setr {registers A B C} {
    upvar 1 $registers r
    set r($C) $r($A)
}

proc seti {registers A B C} {
    upvar 1 $registers r
    set r($C) $A
}

proc gtir {registers A B C} {
    upvar 1 $registers r
    if {$A > $r($B)} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc gtri {registers A B C} {
    upvar 1 $registers r
    if {$r($A) > $B} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc gtrr {registers A B C} {
    upvar 1 $registers r
    if {$r($A) > $r($B)} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc eqir {registers A B C} {
    upvar 1 $registers r
    if {$A == $r($B)} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc eqri {registers A B C} {
    upvar 1 $registers r
    if {$r($A) == $B} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc eqrr {registers A B C} {
    upvar 1 $registers r
    if {$r($A) == $r($B)} {
        set r($C) 1
    } else {
        set r($C) 0
    }
}

proc check_sample {operation sample} {
    lassign $sample      before instruction after
    lassign $instruction opcode A B C

    array unset r
    for {set i 0} {$i < 4} {incr i} {
        set r($i) [lindex $before $i]
    }

    $operation r $A $B $C

    for {set i 0} {$i < 4} {incr i} {
        if {$r($i) != [lindex $after $i]} {
            return 0
        }
    }
    return 1
}

proc part1 {data} {
    set count_ge_3 0
    set samples [lindex $data 0]
    foreach sample $samples {
        set count 0
        foreach operation {addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr} {
            if {[check_sample $operation $sample]} {
                incr count
            }
        }
        if {$count >= 3} {
            incr count_ge_3
        }
    }
    return $count_ge_3
}


proc intersect {list0 list1} {
    array unset list0_set
    foreach i $list0 {
        set list0_set($i) {}
    }

    set intersection {}
    foreach i $list1 {
        if {[info exists list0_set($i)]} {
            lappend intersection $i
        }
    }

    return $intersection
}

proc setminus {list0 item} {
    set result {}
    foreach i $list0 {
        if {$i != $item} {
            lappend result $i
        }
    }
    return $result
}


proc part2 {data} {
    array unset possible_operations
    for {set opcode 0} {$opcode < 16} {incr opcode} {
        set possible_operations($opcode) {
            addr addi mulr muli banr bani borr bori
            setr seti gtir gtri gtrr eqir eqri eqrr
        }
    }

    foreach sample [lindex $data 0] {
        set opcode [lindex [lindex $sample 1] 0]
        set matching_operations {}
        foreach operation {addr addi mulr muli banr bani borr bori setr seti gtir gtri gtrr eqir eqri eqrr} {
            if {[check_sample $operation $sample]} {
                lappend matching_operations $operation
            }
        }
        set possible_operations($opcode) \
            [intersect $matching_operations $possible_operations($opcode)]
    }

    array unset opcode_map
    while {1} {
        set only_opcode {}
        set only_operation {}
        foreach {opcode operations} [array get possible_operations] {
            if {[llength $operations] == 1} {
                set only_opcode $opcode
                set only_operation [lindex $operations 0]
                break
            }
        }
        if {$only_opcode == {}} {
            error "no single opcode left :("
        }

        set opcode_map($only_opcode) $only_operation
        for {set opcode 0} {$opcode < 16} {incr opcode} {
            set possible_operations($i) \
                [setminus $possible_operations($i) $only_operation]
        }
        if {[array size opcode_map] == 16} {
            break
        }
    }

    array set registers {0 0   1 0   2 0   3 0}
    foreach instruction [lindex $data 1] {
        lassign $instruction opcode A B C
        $opcode_map($opcode) registers $A $B $C
    }

    return $registers(0)
}


set data [read_file "test.txt"]
puts "part1 (test, expected=1): [part1 $data]"
set data [read_file "input.txt"]
puts "part1:                    [part1 $data]"
puts "part2:                    [part2 $data]"
