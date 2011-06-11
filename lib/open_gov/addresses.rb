module OpenGov
  class Addresses < Resources
    include StateWise
    
    def initialize
      @s, @u = 0, 0
    end
    
    def import_state(state, options = {})
      puts "Importing addresses from VoteSmart for #{state.abbrev}"

      import_scoped(state.people.with_votesmart_id.with_current_role)

      puts "\nUpdated addresses for #{@u} people; skipped #{@s}."
    end
    
    private

    def import_scoped(scope)
      scope.each do |person|
        import_one(person)
      end
    end
    
    def import_one(person)
      begin
        # The person is often going to come to us as a read only object, so reload it:
        person = Person.find(person.id)

        if @u % 10 == 0
          print '.'
          $stdout.flush
        end

        Address.delete_all(:person_id => person.id)

        puts person.votesmart_id  

        main_office = GovKit::VoteSmart::Address.find(person.votesmart_id)
        
        # TODO: Remove this unless once GovKit stops returning [] for 0-1 item calls
        unless main_office == []
          offices = [*main_office.office]

          offices.each do |office|
            address = person.addresses.find_or_initialize_by_line_one(office.address.street)
            address.city = office.address.city
            address.state = State.find_by_abbrev(office.address.state)
            address.postal_code = office.address.zip
            address.votesmart_type = office.address['type']
            address.phone_one = office.phone.phone1
            address.phone_two = office.phone.phone2
            address.fax_one = office.phone.fax1
            address.fax_two = office.phone.fax2
            address.save
          end
        end
        
        web_address = GovKit::VoteSmart::WebAddress.find person.votesmart_id
        
        # TODO: Remove this unless once GovKit stops returning [] for 0-1 item calls
        unless web_address == []
          web_addresses = [*web_address.address]

          website_count = 0
          web_addresses.each do |wa|
            case wa.webAddressTypeId.to_i
              when 1 # email
                person.email = wa.webAddress
              when 2 # webmail
                person.webmail = wa.webAddress
              when 3 # website
                if website_count == 0
                  person.website_one = wa.webAddress
                else
                  person.website_two = wa.webAddress
                end
                website_count+=1
            end
          end
        end

        # puts "Updating #{person.to_param}"
        @u += 1
        person.save
      rescue GovKit::ResourceNotFound
        @s += 1
        # puts "No addresses found for #{person.to_param}"
      rescue Timeout::Error
        puts "Timeout fetching address for #{person.to_param}"
      end
    end
  end
end
