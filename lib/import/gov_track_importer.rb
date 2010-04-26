require 'config/environment'

class GovTrackImporter
  GOV_TRACK_PEOPLE_URL = "http://www.govtrack.us/data/us/people.xml"
  GOV_TRACK_PEOPLE_FILE = 'people.xml'

  include OpenGov::Helpers

  class << self
    def fetch_data(data_dir = DATA_DIR)
      Dir.chdir(data_dir)

      # Download only if the server copy is newer
      curl_ops = File.exists?(GOV_TRACK_PEOPLE_FILE) ? "-z #{GOV_TRACK_PEOPLE_FILE}" : ''

      `curl #{curl_ops} -fO #{GOV_TRACK_PEOPLE_URL}`
    end
  end

  def initialize(options = {})
    options[:data_url] ||= GOV_TRACK_PEOPLE_URL
    options[:refresh_data] ||= false

    @file_name = File.basename(options[:data_url])

    self.class.fetch_data if options[:refresh_data]

    File.open(File.join(DATA_DIR, @file_name)) do |file|
      @doc = Hpricot(file)
    end

    @people = @doc.search("//person")
  end

  def import!
    @people.each_with_index do |person, i|
      if i % 10 == 0
        print '.'
        $stdout.flush
      end

      begin
        import_person(person)
      rescue Exception => e
        puts "\nSkipping #{person.attributes['id']}-#{person.attributes['name']}: #{e.message}"
        next
      end
    end

    puts "\nThanks!"
  end

  def import_person(person_xml)
    @person = person_already_exists?(person_xml)
    attrs = person_xml.attributes
    @person.suffix = ''
    @person.first_name = attrs['firstname']
    @person.last_name = attrs['lastname']
    @person.middle_name = attrs['middlename']
    @person.gender = attrs['gender']

    date = attrs['birthday']
    @person.birthday = valid_date!(date) && Date.strptime(date, "%Y-%m-%d")
    @person.religion = attrs['religion']

    @person.votesmart_id = attrs['pvsid']
    @person.opensecrets_id = attrs['osid']
    @person.bioguide_id = attrs['bioguideid']
    @person.youtube_id = attrs['youtubeid']
    @person.metavid_id = attrs['metavidid']

    if @person.save
      roles = person_xml.search("//role")
      roles.each do |role|
        role = make_role(role)
        role.save
      end
    else
      puts "Errors saving the person #{@person.errors.full_messages.join('\n')}"
    end
  end

  def make_role(role_xml)
    role = role_already_exists?(role_xml)
    attrs = role_xml.attributes

    role.party = attrs['party']

    if attrs['type'] == 'sen'
      role.chamber = UpperChamber::US_SENATE
      role.senate_class = attrs['class']
      role.state = State.find_by_abbrev(attrs['state'])
    elsif attrs['type'] == 'rep'
      role.chamber = LowerChamber::US_HOUSE
      role.district = LowerChamber::US_HOUSE.districts.numbered(attrs['district']).first
    end

    role
  end

  protected
  def person_already_exists?(person_xml)
    gid = person_xml.attributes['id']
    Person.find_by_govtrack_id(gid) || Person.new(:govtrack_id => gid)
  end

  def role_already_exists?(role_xml)
    attrs = role_xml.attributes

    startdate = attrs['startdate']
    startdate = valid_date!(startdate) && Date.strptime(startdate, "%Y-%m-%d")
    enddate = attrs['enddate']
    enddate = valid_date!(enddate) && Date.strptime(enddate, "%Y-%m-%d")

    options = {:person_id => @person.id, :start_date => startdate}

    Role.find(:first, :conditions => options) || Role.new(options.merge({ :end_date => enddate }))
  end

  def valid_date!(date)
    Date.parse(date) rescue nil
  end
end


if __FILE__ == $0
  GovTrackImporter.new(:refresh_data => true).import!
end
