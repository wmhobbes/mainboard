
Mainboard.helpers do

  def aws_fail error
    content_type :xml
    # for xml
    throw :halt, [error.transport_code, builder do |x|
      x.instruct! :xml, :version=>"1.0", :encoding=>"UTF-8"
      x.Error do |e|
        e.Code error.code
        e.Message error.message
        e.RequestId '0000'
        e.HostId 'unavailable'
      end
    end]

  end
end
