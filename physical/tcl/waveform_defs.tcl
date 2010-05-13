namespace import suspect::*

proc pass {} {}

set app [Spawn telnet 127.0.0.1 54321]
Expect $app -timeout 3 {"Escape character" {pass}}

proc pushButton {name} {
    global app

    Send $app "PUSH:BUTTON $name\n"
    Expect $app -timeout 3 {
        1 {pass}
    }
}

proc editEnabled {name} {
    global app

    Send $app "EDIT:ENABLED? $name\n"
    Expect $app -timeout 3 {
        0 {return 0}
        1 {return 1}
    }
}
