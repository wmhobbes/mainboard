class Bucket
  include MongoMapper::Document

  key :account_id,  ObjectId
  key :type,        String,   :length => 6,   :default => 'data'
  key :name,        String,   :length => 255, :format => /^[-\w]+$/
  key :created_at,  Time
  key :updated_at,  Time
  key :access,      Integer
  key :meta,        String

  validates_uniqueness_of :name

  belongs_to :account
  many :slots

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

  # def self.readable_by? bucket
  #   check_access(bucket.user, READABLE_BY_AUTH, READABLE)
  # end

  def readable_by? account
    check_access(account, READABLE_BY_AUTH, READABLE)
  end

  def owned_by? passed_account
    passed_account and account.identity == passed_account.identity
  end

  def writable_by? current_account
    check_access(current_account, WRITABLE_BY_AUTH, WRITABLE)
  end

  # private

  def check_access account, group_perm, account_perm
    !!(
      if owned_by?(account) or (account and (access > 0 && group_perm > 0)) or (access > 0 && account_perm > 0)
        true
      elsif account
        acl = account.find(account.id) rescue nil
        acl and acl.access.to_i & account_perm
      end
    )
  end
end
