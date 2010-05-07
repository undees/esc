require 'mono-curses.dll'

class WaveformApp
  include Mono::Terminal

  def initialize
    Application.init false

    @container = Container.new 0, 0,
      Application.cols, Application.lines

    types  = Frame.new 10, 0, 30, 15, 'Waveform Type'
    types.add(@sine = CheckBox.new(2, 2, 'Sine'))
    types.add(@square = CheckBox.new(2, 8, 'Square'))
    @square.checked = true
    @sine.toggled.add   lambda { uncheck @square }
    @square.toggled.add lambda { uncheck @sine   }

    params = Frame.new 40, 0, 30, 15, 'Parameters'
    params.add Label.new(2, 2, 'Frequency (MHz)')
    params.add Label.new(2, 5, 'Amplitude (dBm)')
    params.add Label.new(2, 8, 'Duty Cycle  (%)')
    params.add(@frequency = Entry.new(20, 2, 6, '500'))
    params.add(@amplitude = Entry.new(20, 5, 6, '-30'))
    params.add(@duty_cycle = Entry.new(20, 8, 6, '50'))

    @container.add types
    @container.add params
  end

  def uncheck(control)
    control.checked = false
    control.redraw

    @duty_cycle.can_focus = (control == @sine)
  end

  def run
    Application.run @container
  end
end

WaveformApp.new.run
