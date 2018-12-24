module OpenGov
  class OpenStates < Resources
    def fetch(opts = {})
      State.loadable.each do |state|
        fetch_one(state, opts)
      end
    end

    def fetch_one(state, opts = {})
      if fs_state = GovKit::OpenStates::State.find_by_abbreviation(state.abbrev)
        FileUtils.mkdir_p(Settings.openstates_dir)
        Dir.chdir(Settings.openstates_dir)

        # If available from OpenStates, use the latest_json_url and latest_json_date.
        openstates_url = fs_state[:latest_json_url]
        if openstates_url.blank?
          puts "No latest_json_url returned for #{state.name}; skipping download."
          return
        end

        openstates_fn = File.basename(openstates_url)
        openstates_date = (fs_state[:latest_json_date] && fs_state[:latest_json_date].to_time) || Time.now
        
        puts "---------- Downloading the OpenStates data for #{state.name} - #{openstates_fn}"
        `rm -f {committees,legislators}/#{state.abbrev.upcase}*`
        `rm -rf {bills}/#{state.abbrev.downcase}`

        unless File.exists?(openstates_fn) && openstates_date > File.mtime(openstates_fn)
          tries = 3
          begin
            curl_ops = File.exists?(openstates_fn) ? "-LOz #{openstates_fn}" : '-LO'

            download(openstates_url, {:curl_ops => curl_ops}.merge(opts))
            tries -= 1
          end while !system("unzip -qt #{openstates_fn} || (rm -f #{openstates_fn} && false)") && tries > 0

          if tries == 0
            puts "Could not download valid openstates data for #{state.name}; skipping"
          end
        else
          puts "The local copy of the data is already fresh; skipping download."
        end

        `unzip -oqu #{openstates_fn} 2>/dev/null`
      else
        puts "Could not fetch metadata from OpenStates for #{state.abbrev}; skipping download."
      end
    end
  end
end
