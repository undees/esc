require 'serialport'

module MoodHelper
  Emotions = %w(furious unhappy neutral happy ecstatic)

  attr_reader :port

  def int_for(emotion)
    Emotions.index emotion
  end

  def open_port
    @port = SerialPort.new(ENV['MOOD_HAT'], 9600, 8, 1, SerialPort::NONE)
    @port.read_timeout    = 500
    @port.wait_after_send = 500 if @port.respond_to?(:wait_after_send=)

    @port.putc('?') until (@port.read =~ /\d/ rescue nil)
  end

  def close_port
    @port.close
  end
end

Before {open_port}
After  {close_port}

World  MoodHelper
