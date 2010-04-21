require 'config/environment'
require 'with_progress'

class GovTrackImporter
  include OpenGov::Helpers

  def initialize(file)
    @doc = Hpricot(file)
    @people = @doc.search("//person")
  end

  def import
    with_progress do
      @people.each do |person|
        begin
          import_person(person)
        rescue Exception => e
          puts "\nSkipping #{person.attributes['id']}-#{person.attributes['name']}: #{e.message}"
          next
        end
      end
    end
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
    @person.birthday = valid_date?(date) && Date.strptime(date, "%Y-%m-%d")
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
    state = State.find_by_abbrev(attrs['state'])

    role.party = attrs['party']
    role.state = state
    role.district = state && state.districts.numbered(attrs['district']).first
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
    startdate = valid_date?(startdate) && Date.strptime(startdate, "%Y-%m-%d")
    enddate = attrs['enddate']
    enddate = valid_date?(enddate) && Date.strptime(enddate, "%Y-%m-%d")

    options = {:person_id => @person.id, :start_date => startdate, :end_date => startdate}

    Role.find(:first, :conditions => options) || Role.new(options)
  end

  def valid_date?(date)
    Date.parse(date) rescue nil
  end
end


if __FILE__ == $0
  File.open(File.join(DATA_DIR, 'people.xml')) do |file|
    GovTrackImporter.new(file).import
  end
end
