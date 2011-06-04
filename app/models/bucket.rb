class Bucket
  include MongoMapper::Document
  include CommonPermissions

  key :account_id,  ObjectId
  key :type,        String,   :length => 6,   :default => :data
  key :name,        String,   :length => 255, :format => /^[-\w]+$/

  key :access,      String
  key :meta,        String
  # permission set for anonymous access
  key :public_access, Array
  # permission set for authenticated access
  key :auth_access,   Array

  timestamps!

  ensure_index :name

  validates_uniqueness_of :name
  validates_presence_of :access

  belongs_to :account
  many :slots,      :dependent => :destroy

  def owner
    account
  end

end
