require File.expand_path(File.dirname(__FILE__) + '/../spec_helper')
require Rails.root + 'lib/gov_track_importer'

describe GovTrackImporter do
  before(:all) do
    @data_dir = File.join(Rails.root, 'data')
    @data_url = "file://#{Rails.root}/spec/fixtures/data/gov_track_sample.xml"
    @data_file = File.join(@data_dir, File.basename(@data_url))
    File.delete(File.join(@data_file)) if File.exist?(@data_file)

    @importer = GovTrackImporter.new(:data_url => @data_url, :data_dir => @data_dir)
  end

  context ".fetch_data" do
    it "should fetch the data to the given directory" do
      @importer.fetch_data
      File.exists?(@data_file).should be_true
    end
  end

  context "#import" do
    before do
      @raw_data = Nokogiri::XML(File.read(@data_file))
      @people = @raw_data.search('//person')
    end

    it "should should import the given people" do
      lambda do
        @importer.import
      end.should change(Person, :count).by(@people.size)

      @people.each do |person|
        Person.find_by_govtrack_id(person.attributes['id'].to_s).should_not == nil
      end
    end
  end

  after(:all) do
    File.delete(File.join(@data_file)) if File.exist?(@data_file)
  end
end
