

Mainboard.controllers do

  before do
    puts "+++++++++CRAP"
    aws_authenticate
    headers :server => "Mainboard"
  end
end