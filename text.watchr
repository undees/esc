require 'g'

watch('article\.txt') do |m|
  g 'Building PDF'

  `make pdf`

  result = ($? == 0) ? 'passed' : 'failed'
  g 'PDF build ' + result
end
