require 'mono-curses.dll'
require 'gserver'

class WaveformApp < GServer
  include Mono::Terminal

  def initialize
    super 54321

    Application.init false

    @container = Container.new 0, 0,
      Application.cols, Application.lines

    types  = Frame.new 10, 0, 30, 15, 'Waveform Type'
    types.add(@sine = CheckBox.new(2, 2, 'Sine'))
    types.add(@square = CheckBox.new(2, 8, 'Square'))

    params = Frame.new 40, 0, 30, 15, 'Parameters'
    params.add Label.new(2, 2, 'Frequency (MHz)')
    params.add Label.new(2, 5, 'Amplitude (dBm)')
    params.add Label.new(2, 8, 'Duty Cycle  (%)')
    params.add(@frequency = Entry.new(20, 2, 6, '500'))
    params.add(@amplitude = Entry.new(20, 5, 6, '-30'))
    params.add(@duty_cycle = Entry.new(20, 8, 6, '50'))

    @square.checked = true
    @sine.toggled.add   method(:sine_pushed).to_proc
    @square.toggled.add method(:square_pushed).to_proc

    @container.add types
    @container.add params
  end

  def serve(io)
    loop do
      if IO.select([io], nil, nil, 0.5)
        line = io.gets

        case line.strip
        when /^PUSH:BUTTON (.+)$/
          begin
            send "#{$1.downcase}_pushed"
            io.puts '1'
          rescue
            io.puts '0'
          end
        when /^EDIT:ENABLED\? (.+)$/
          begin
            enabled = edit_enabled? $1.downcase
            io.puts enabled ? '1' : '0'
          rescue
            io.puts '-1'
          end
        end
      end
    end
  end

  def sine_pushed(*args)
    switch_to :sine
  end

  def square_pushed(*args)
    switch_to :square
  end

  def switch_to(type)
    @sine.checked = (type == :sine)
    @sine.redraw
    @square.checked = (type != :sine)
    @square.redraw

    @duty_cycle.can_focus = (type == :square)
  end

  def edit_enabled?(name)
    instance_variable_get("@#{name}").can_focus
  end

  def run
    self.start
    Application.timeout = 100
    Application.run @container
  end
end

WaveformApp.new.run
