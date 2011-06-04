class Metadatum
  include MongoMapper::EmbeddedDocument

  key :key, String, :length => 64
  key :value, String, :length => 255

end

