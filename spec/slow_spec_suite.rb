class SlowSpecSuite
  def run
    Dir["#{File.dirname(__FILE__)}/{lib}/**/*_spec.rb"].each do |file|
      require file
    end
  end
end

if $0 == __FILE__
  SlowSpecSuite.new.run
end
