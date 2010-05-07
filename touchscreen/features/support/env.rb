require 'net/http'

class WaveformWorld
  IDC_SINE       = 1001
  IDC_SQUARE     = 1002
  IDC_DUTY_CYCLE = 1005

  def get(path)
    Net::HTTP.get ENV['DEVICE'], path, 8080
  end
end

World { WaveformWorld.new }
