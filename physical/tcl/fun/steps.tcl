package require Expect

set timeout 3
spawn telnet 127.0.0.1 54321
expect "Escape character"

proc pass {} {
    # no-op
}

proc fail {} {
    error "Test step failed"
}

proc Feature: args {
    # no-op
}

proc In args {
    # no-op
}

proc As args {
    # no-op
}

proc I args {
    # no-op
}

proc Scenario: args {
    # no-op
}

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
