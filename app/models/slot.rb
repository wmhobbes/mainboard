class Slot
  include MongoMapper::Document
  include CommonPermissions

  plugin Joint

  attachment :bit

  key :bucket_id,   ObjectId
  key :access,      String, :default => 'private'
  key :metadata,      Hash
  # permission set for anonymous access
  key :public_access, Array
  # permission set for authenticated access
  key :auth_access,   Array

  timestamps!
  ensure_index :bit_name

  belongs_to :bucket
  validates_presence_of :bit_name
  validates_presence_of :access

  def owner
    bucket.owner
  end

end

