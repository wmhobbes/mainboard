module CommonPermissions

  CANNED_ACLS = {
    'private' => {:public => [], :auth => []},
    'public-read' => {:public => [:read], :auth => [:read]},
    'public-read-write' => {:public => [:read, :write], :auth => [:read, :write]},
    'authenticated-read' => {:public => [], :auth => [:read]},
    'authenticated-read-write' => {:public => [], :auth => [:read, :write]}
  }

  def self.included(klass)
    klass.extend(ClassMethods)
  end

  module ClassMethods

    def canned_acls
      CommonPermissions::CANNED_ACLS.keys
    end
  end

  def access= value
    value = 'private' unless CANNED_ACLS[value]
    write_attribute :access, value
    write_attribute :public_access, CANNED_ACLS[value][:public]
    write_attribute :auth_access, CANNED_ACLS[value][:auth]
  end

  def readable_by? current_account
    check_access current_account, :read
  end

  def writable_by? current_account
    check_access current_account, :write
  end

  def acl_writable_by? current_account
    check_access current_account, :write_acls
  end

  def acl_readable_by? current_account
    check_access current_account, :read_acls
  end

  def owned_by? current_account
    current_account and owner.identity == current_account.identity
  end

  def check_access given_account, permission
    return true if owned_by? given_account

    if given_account
      auth_access.include? permission.to_sym
    else
      public_access.include? permission.to_sym
    end
  end

end
