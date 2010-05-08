require 'serialport'

class MoodWorld
  Emotions = %w(furious unhappy neutral happy ecstatic)

  def int_for(emotion)
    Emotions.index emotion
  end

  def port
    return @port if @port

    @port = SerialPort.new(ENV['MOOD_HAT'], 9600, 8, 1, SerialPort::NONE)
    @port.read_timeout = 1000
    @port.putc '?' until @port.read =~ /\d/
    @port
  end
end

World { MoodWorld.new }
