Given(/^a waveform$/) do
  launcher = ApplicationLauncher.new
  app      = launcher.recycle 'WaveformApp'
  @win     = app.find_window 'Waveform'
end

When(/^I set the Waveform Type to "([^"]*)"$/) do |value|
  @win.method(:find).of(RadioButton)[value.downcase].select
end

Then(/^the Duty Cycle setting should be (.*)$/) do |state|
  want_enabled = (state == "enabled")

  duty_cycle = @win.method(:find).of(TextBox)['dutyCycle']
  is_enabled = duty_cycle.element.
    get_current_property_value(AutomationElement.IsEnabledProperty)

  is_enabled.should == want_enabled
end
