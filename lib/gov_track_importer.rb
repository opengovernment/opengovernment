require File.dirname(__FILE__) + '/../config/environment'

class GovTrackImporter
  GOV_TRACK_PEOPLE_URL = "http://www.govtrack.us/data/us/people.xml"
  attr_reader :file_name, :data_url, :data_dir

  def initialize(options = {})
    @data_url = options[:data_url] || GOV_TRACK_PEOPLE_URL
    @file_name = File.basename(@data_url)
    @refresh_data = options[:refresh_data] || false
    @data_dir = options[:data_dir] || DATA_DIR
  end

  def fetch_data
    Dir.chdir(@data_dir)

    # Download only if the server copy is newer
    curl_ops = File.exists?(@file_name) ? "-z #{@file_name}" : ''

    `curl #{curl_ops} -fO #{@data_url}`
  end

  def import!
    puts "\n---------- Loading people from GovTrack."
    fetch_data
    import
  end

  def import
    print "\nImporting people."

    File.open(File.join(@data_dir, @file_name)) do |file|
      @doc = Hpricot(file)
    end

    @people = @doc.search("//person")

    @people.each_with_index do |person, i|
      if i % 10 == 0
        print '.'
        $stdout.flush
      end

      begin
        Person.transaction do
          import_person(person)
        end
      rescue StandardError => e
        puts "\nSkipping #{person.attributes['id']}-#{person.attributes['name']}: #{e.message}"
        next
      end
    end

    puts "\nThanks!"
  end

  def import_person(person_xml)

    roles = person_xml.search("//role")
    
    # We want them to have at least one role that starts within the last 10 years, otherwise don't import them.
    if roles.any? { |r| Date.valid_date!(r['startdate']) && Date.strptime(r['startdate'], "%Y-%m-%d") > 10.years.ago.to_date }

      @person = person_already_exists?(person_xml)
      attrs = person_xml.attributes
      @person.suffix = ''
      @person.first_name = attrs['firstname']
      @person.last_name = attrs['lastname']
      @person.middle_name = attrs['middlename']
      @person.gender = attrs['gender']

      date = attrs['birthday']
      @person.birthday = Date.valid_date!(date) && Date.strptime(date, "%Y-%m-%d")
      @person.religion = attrs['religion']

      @person.votesmart_id = attrs['pvsid']
      @person.opensecrets_id = attrs['osid']
      @person.bioguide_id = attrs['bioguideid']
      @person.youtube_id = attrs['youtubeid']
      @person.metavid_id = attrs['metavidid']

      if @person.save
        roles.each do |role|
          role = make_role(role)
          role.save
        end
      else
        puts "Errors saving the person #{@person.errors.full_messages.join('\n')}"
      end

    end
  end

  def make_role(role_xml)
    role = role_already_exists?(role_xml)
    attrs = role_xml.attributes

    role.party = case attrs['party']
      when 'Democrat', 'D'
        'Democratic'
      when 'Republican', 'R'
        'Republican'
      else
        'Independent'
      end

    state = State.find_by_abbrev(attrs['state'])

    if attrs['type'] == 'sen'
      role.chamber = UpperChamber::US_SENATE
      role.senate_class = attrs['class']
      role.state = state
    elsif attrs['type'] == 'rep'
      role.chamber = LowerChamber::US_HOUSE
      role.district = LowerChamber::US_HOUSE.districts.for_state(state.id).numbered(attrs['district']).first
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
    startdate = Date.valid_date!(startdate) && Date.strptime(startdate, "%Y-%m-%d")
    enddate = attrs['enddate']
    enddate = Date.valid_date!(enddate) && Date.strptime(enddate, "%Y-%m-%d")

    options = {:person_id => @person.id, :start_date => startdate}

    Role.find(:first, :conditions => options) || Role.new(options.merge({:end_date => enddate}))
  end

end


if __FILE__ == $0
  GovTrackImporter.new.import!
end
