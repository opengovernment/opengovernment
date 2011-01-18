require  File.expand_path(File.dirname(__FILE__) + '/settings')

begin
  MongoMapper.connection = Mongo::Connection.new('localhost')
  MongoMapper.database = Settings.mongo_database

rescue Exception => e
  Rails.logger.debug("Mongodb: #{e.message}")
end

