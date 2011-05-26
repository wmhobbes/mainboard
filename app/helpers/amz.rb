
Mainboard.helpers do

  def amz_headers header_name
    @amz_headers[header_name.to_s]
  end


  def amz_requested_acl
    CANNED_ACLS[amz_headers('x-amz-acl') || 'private']
  end

end