
Miniconf.with_config do |c|
  MongoMapper.connection = Mongo::Connection.new(
    c.database.host,
    c.database.port,
    :logger => logger
  )
  MongoMapper.database = c.database.db
  if c.database.username && c.database.password
    
    MongoMapper.database.authenticate(
      c.database.username,
      c.database.password
    )
  end
end