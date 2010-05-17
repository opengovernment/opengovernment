require File.dirname(__FILE__) + '/../spec_helper'
require 'lib/gov_track_importer'

describe GovTrackImporter do
  before do
    Object.redefine_const("GOV_TRACK_DATA_URL", "file://#{Rails.root}/spec/fixtures/data/gov_track_sample.xml")
    @data_file = File.basename(GOV_TRACK_DATA_URL)
  end

  context ".fetch_data" do
    it "should fetch the data to default data directory" do
      GovTrackImporter.fetch_data
      File.exist?(File.join(DATA_DIR, @data_file)).should be_true
    end

    it "should fetch the data to the given directory" do
      directory = Rails.root.join("spec", "fixtures", "data")
      GovTrackImporter.fetch_data(directory)
      File.exist?(File.join(directory, @data_file)).should be_true
    end
  end

  context "#import" do
    before do
      @importer = GovTrackImporter.new
      @raw_data = Hpricot(File.read(File.join(DATA_DIR, @data_file)))
      @people = @raw_data.search('//person')
    end

    it "should should import the given people" do
      lambda do
        @importer.import!
      end.should change(Person, :count).by(@people.size)

      @people.each do |person|
        Person.find_by_govtrack_id(person.attributes['id']).should_not be_nil
      end
    end
  end

  after do
    if File.exist?(File.join(DATA_DIR, @data_file))
      File.delete(File.join(DATA_DIR, @data_file))
    end
  end
end
