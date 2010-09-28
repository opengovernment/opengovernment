begin
  MongoMapper.connection = Mongo::Connection.new('localhost')
  MongoMapper.database = "og_#{Rails.env}"

  MongoMapper.ensure_indexes!
rescue Exception => e
  Rails.logger.debug("Mongodb: #{e.message}")
end

