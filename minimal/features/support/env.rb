require 'serialport'

class MoodWorld
  @@port = nil

  Emotions = %w(furious unhappy neutral happy ecstatic)

  def int_for(emotion)
    Emotions.index emotion
  end

  def port
    return @@port if @@port

    @@port = SerialPort.new(ENV['MOOD_HAT'], 9600, 8, 1, SerialPort::NONE)
    @@port.read_timeout    = 2000
    @@port.wait_after_send = 1000 if @port.methods.include? :wait_after_send=

    @@port.putc('?') until (@@port.read =~ /\d/ rescue nil)
    @@port
  end

  def self.close
    @@port.close if @@port
  end
end

World   { MoodWorld.new   }
at_exit { MoodWorld.close }
