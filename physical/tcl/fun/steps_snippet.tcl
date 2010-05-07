proc When {I set the Waveform Type to _value} {
    send "PUSH:BUTTON [string toupper $_value]\n"
    expect 1
}
