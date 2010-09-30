module OpenGov
  class OpenStates
    def self.fetch!
      State.loadable.each do |state|
        fetch_one(state)
      end
    end
    
    def self.fetch_one(state)
      FileUtils.mkdir_p(Settings.openstates_dir)
      Dir.chdir(Settings.openstates_dir)

      openstates_fn = "#{state.abbrev.downcase}.zip"
      curl_ops = File.exists?(openstates_fn) ? "-z #{openstates_fn}" : ''

      puts "---------- Downloading the OpenStates data for #{state.name}"
      `rm -f api/{committees,legislators}/#{state.abbrev.upcase}*`
      `rm -rf api/#{state.abbrev.downcase}`
      `curl #{curl_ops} -LOf http://openstates.sunlightlabs.com/data/#{openstates_fn}`
      `unzip -qu #{openstates_fn} 2>/dev/null`
    end
  end
end