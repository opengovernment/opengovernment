module OpenGov
  class OpenStates < Resources
    def fetch
      State.loadable.each do |state|
        fetch_one(state)
      end
    end

    def fetch_one(state)
      if fs_state = GovKit::OpenStates::State.find_by_abbreviation(state.abbrev)
        FileUtils.mkdir_p(Settings.openstates_dir)
        Dir.chdir(Settings.openstates_dir)

        puts "---------- Downloading the OpenStates data for #{state.name}"
        `rm -f api/{committees,legislators}/#{state.abbrev.upcase}*`
        `rm -rf api/#{state.abbrev.downcase}`

        # If available from OpenStates, use the latest_dump_url and latest_dump_date.
        openstates_url = fs_state[:latest_dump_url]
        openstates_fn = File.basename(openstates_url)
        openstates_date = (fs_state[:latest_dump_date] && fs_state[:latest_dump_date].to_time) || Time.now

        if openstates_url.blank?
          puts "No latest_dump_url returned for #{state.name}; skipping download."
          return
        end

        unless File.exists?(openstates_fn) && openstates_date > File.mtime(openstates_fn)
          tries = 3
          begin
            curl_ops = File.exists?(openstates_fn) ? "-LOz #{openstates_fn}" : '-LO'

            download(openstates_url, :curl_ops => curl_ops)
            tries -= 1
          end while !system("unzip -qt #{openstates_fn} || (rm -f #{openstates_fn} && false)") && tries > 0

          if tries == 0
            puts "Could not download valid openstates data for #{state.name}; skipping"
          end
        else
          puts "The local copy of the data is already fresh; skipping download."
        end

        `unzip -qu #{openstates_fn} 2>/dev/null`
      else
        puts "Could not fetch metadata from OpenStates for #{state.abbrev}; skipping download."
      end
    end
  end
end
