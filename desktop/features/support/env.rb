require File.dirname(__FILE__) + '/WiPFlash.dll'

require 'UIAutomationClient,
         Version=3.0.0.0,
         Culture=neutral,
         PublicKeyToken=31bf3856ad364e35'

require 'UIAutomationTypes,
         Version=3.0.0.0,
         Culture=neutral,
         PublicKeyToken=31bf3856ad364e35'

include WiPFlash
include WiPFlash::Components
include System::Windows::Automation
