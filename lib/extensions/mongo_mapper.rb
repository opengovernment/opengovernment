module MongoMapper
  module Connection
    def connected?
      begin
        conn = MongoMapper.connection # Gets the actual connection
        conn && conn.server_info # need to make an actual call to see if the conenction stale
        return true
      rescue Mongo::ConnectionFailure => e
        Rails.logger.debug("Mongodb: #{e.message}")
        return false
      end
    end
  end
end
