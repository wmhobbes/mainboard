module AWS
  module S3
    module ACLs
      RESOURCE_TYPES = %w[acl torrent]

      CANNED_ACLS = {
        'private' => 0600,
        'public-read' => 0644,
        'public-read-write' => 0666,
        'authenticated-read' => 0640,
        'authenticated-read-write' => 0660
      }

      READABLE = 0004
      WRITABLE = 0002
      READABLE_BY_AUTH = 0040
      WRITABLE_BY_AUTH = 0020
    end
  end
end