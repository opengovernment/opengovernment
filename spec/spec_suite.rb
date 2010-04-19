class SpecSuite
  def run
    Dir["#{File.dirname(__FILE__)}/{models, controllers, views, helpers, webrat}/**/*_spec.rb"].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  SpecSuite.new.run
end
