class IntegrationSpecSuite
  def run
    Dir["#{File.dirname(__FILE__)}/integration/*_spec.rb"].each do |file|
      require File.expand_path(file)
    end
  end
end

if $0 == __FILE__
  IntegrationSpecSuite.new.run
end
