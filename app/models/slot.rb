class Slot
  include MongoMapper::Document

  plugin Joint

  attachment :bit

  key :bucket_id,   ObjectId
  key :access,      Integer
  key :created_at,  Time
  key :updated_at,  Time

  belongs_to :bucket

  def access_readable
    name, _ = CANNED_ACLS.find { |k, v| v == self.access }

    if name
      name
    else
      [0100, 0010, 0001].map { |i|
        [[4, 'r'], [2, 'w'], [1, 'x']].map { |k, v|
          (self.access & (i * k) == 0 ? '-' : v )
        }
      }.join
    end
  end

  def readable_by? current_account
    check_access(current_account, READABLE_BY_AUTH, READABLE)
  end

  def owned_by? current_account
    current_account and bucket.account.login == current_account.login
  end

  def writable_by? current_account
    check_access(current_account, WRITABLE_BY_AUTH, WRITABLE)
  end

  def check_access account, group_perm, account_perm
    !!(
      if owned_by?(account) or (account and (access > 0 && group_perm > 0)) or (access > 0 && account_perm > 0)
        true
      elsif account
        acl = accounts.find(account.id) rescue nil
        acl and acl.access.to_i & account_perm
      end
    )
  end
end

