Given(/^a waveform$/) do
  # no-op
end

When(/^I set the Waveform Type to "([^"]*)"$/) do |value|
  tcl.eval "pushButton #{value.upcase}"
end

Then(/^the Duty Cycle setting should be (.*)$/) do |state|
  expected = (state == 'enabled' ? 1 : 0)
  actual = tcl.eval("editEnabled DUTY_CYCLE").to_i
  actual.should == expected
end
