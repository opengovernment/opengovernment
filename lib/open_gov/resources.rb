module OpenGov
  class Resources
    def download(url, opts = {})
      opts[:curl_ops] ||= '-Lf'
      opts[:output_fn] ||= File.basename(url)
      opts[:unzip] ||= false

      `curl #{opts[:curl_ops]} -o "#{opts[:output_fn]}" #{url}`

      if opts[:unzip] == true
        `unzip -oqu #{opts[:output_fn]}`
      end
      
      return opts[:output_fn]
    end
  end
end
