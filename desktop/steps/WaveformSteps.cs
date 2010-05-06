using Cuke4Nuke.Framework;
using System;
using System.Collections.Generic;
using System.Linq;
using System.Text;
using System.Windows.Automation;
using WiPFlash;
using WiPFlash.Components;

namespace WaveformSteps
{
    public class WaveformSteps
    {
        private Application app = null;
        private Window win = null;

        [Given("^a waveform$")]
        public void AWaveform()
        {
            var launcher = new ApplicationLauncher();
            app = launcher.Recycle("WaveformApp");
            win = app.FindWindow("Waveform");

        }

        [When("^I set the Waveform Type to \"([^\"]*)\"$")]
        public void ISetTheWaveformTypeTo(string value)
        {
            win.Find<RadioButton>(value.ToLower()).Select();
        }

        [Then("^the Duty Cycle setting should be (.+)$")]
        public void TheDutyCycleSettingShouldBe(string state)
        {
            var wantEnabled = (state == "enabled");
            var dutyCycle   = win.Find<TextBox>("dutyCycle");
            var isEnabled   = (bool)dutyCycle.Element.GetCurrentPropertyValue(AutomationElement.IsEnabledProperty);

            if (isEnabled != wantEnabled)
            {
                throw new Exception("Expected duty cycle to be " + state);
            }
        }
    }
}
    