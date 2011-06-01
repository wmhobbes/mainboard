
Admin.helpers do

  def acl value
    n = AWS::S3::ACLs::CANNED_ACLS.select { |k,v| v == value }.to_a.first
    n ? n.first : value
  end

  def from_acl value
    v = AWS::S3::ACLs::CANNED_ACLS[value]
    v ? v : value
  end

end
