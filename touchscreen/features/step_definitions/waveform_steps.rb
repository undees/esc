Given(/^a waveform$/) do
  @win = get('/FindWindow?title=Waveform').to_i
end

When(/^I set the Waveform Type to "([^"]*)"$/) do |value|
  control = const_get "IDC_#{value.upcase}" #<1>
  result  = get("/ClickControl?parent=#{@win}&control=#{control}").to_i
  result.should == 1
end

Then(/^the Duty Cycle setting should be (.*)$/) do |state|
  control  = IDC_DUTY_CYCLE
  actual   = get("/IsControlEnabled?parent=#{@win}&control=#{control}").to_i
  expected = (state == 'enabled' ? 1 : 0)

  actual.should == expected
end
