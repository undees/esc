Given(/^a waveform$/) do
  @win = get('/FindWindow?title=Waveform').to_i
end

When(/^I set the Waveform Type to "([^"]*)"$/) do |value|
  control = self.class.const_get "IDC_#{value.upcase}"
  result  = get("/ClickControl?parent=#{@win}&control=#{control}").to_i
  result.to_i.should == 1
end

Then(/^the Duty Cycle setting should be (.*)$/) do |state|
  expected = (state == 'enabled' ? 1 : 0)
  control  = self.class.const_get :IDC_DUTY_CYCLE
  actual   = get("/IsControlEnabled?parent=#{@win}&control=#{control}").to_i

  actual.should == expected
end
