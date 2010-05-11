module OpenGov::Fetch::Bills

  def self.process
    FileUtils.mkdir_p(FIFTYSTATES_DIR)
    Dir.chdir(FIFTYSTATES_DIR)

    fiftystates_fn = 'tx.zip'
    curl_ops = File.exists?(fiftystates_fn) ? "-z #{fiftystates_fn}" : ''

    puts "Downloading the bills for Texas"
    `curl #{curl_ops} -fO http://fiftystates-dev.sunlightlabs.com/data/tx.zip`
    `unzip -u #{fiftystates_fn}`
  end

end
