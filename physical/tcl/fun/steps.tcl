package require Expect

# test harness

proc pass {} {
    # no-op
}

proc fail {} {
    error "Test step failed"
}

proc noproc args {
    foreach name $args {
        proc $name args {
            # no-op
        }
    }
}

noproc Feature: Scenario: In As I

# tests

set timeout 3
spawn telnet 127.0.0.1 54321
expect "Escape character"

proc Given args {
    # no-op
}

proc When {I set the Waveform Type to _value} {
    send "PUSH:BUTTON [string toupper $_value]\n"
    expect 1
}

proc Then {the Duty Cycle setting should be _state} {
    set expected   [string equal $_state enabled]
    set unexpected [expr 1 - $expected]
    send "EDIT:ENABLED? DUTY_CYCLE\n"
    expect {
        $expected   pass
        $unexpected fail
    }
}
