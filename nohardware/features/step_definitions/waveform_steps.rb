Given(/^a waveform$/) do
  launcher = ApplicationLauncher.new
  app      = launcher.recycle 'WaveformApp'
  @win     = app.find_window  'Waveform'
end

When(/^I set the Waveform Type to "([^\"]*)"$/) do
  |value|

  radio_buttons = @win.method(:find).of(RadioButton)
  waveform_type = radio_buttons[value.downcase]
  waveform_type.select
end

Then(/^the Duty Cycle setting should be (.*)$/) do
  |state|

  text_boxes = @win.method(:find).of(TextBox)
  duty_cycle = text_boxes['dutyCycle']

  is_enabled = duty_cycle.element.
    get_current_property_value(
      AutomationElement.IsEnabledProperty)

  want_enabled = (state == "enabled")

  is_enabled.should == want_enabled
end
