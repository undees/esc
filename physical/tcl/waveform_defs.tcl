package require Expect

set timeout 3
spawn telnet 127.0.0.1 54321
expect "Escape character"

proc pushButton {name} {
    send "PUSH:BUTTON $name\n"
    expect 1
}

proc editEnabled {name} {
    send "EDIT:ENABLED? $name\n"
    expect \[01\]
    return $expect_out(0,string)
}

pushButton SINE
editEnabled DUTY_CYCLE
pushButton SQUARE
editEnabled DUTY_CYCLE
