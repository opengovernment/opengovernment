module OpenGov::Load::Addresses

  def self.import!
    Person.with_votesmart_id.with_current_role.each do |person|

      Address.delete_all(:person_id => person.id)

      office = VoteSmart::Address.get_office person.votesmart_id
      # See http://api.votesmart.org/docs/Address.html for full spec

      if office['error'].blank?
        # VoteSmart will return an array here unless there's only one address available...
        addresses = office['address']['office']

        # ... but to simplify things, let's always make an array happen.
        addresses = [addresses] unless addresses.kind_of?(Array)

        addresses.each do |addr|
  
          a = addr['address']
          p = addr['phone']

          next if a['street'].blank? || a['city'].blank? || a['typeId'].blank? || a['zip'].blank?

          # Even though we deleted their addresses earlier,
          # we still want to find_or_ because VoteSmart often gives us
          # duplicate address records for one person.
          address = Address.find_or_initialize_by_person_id_and_line_one(person.id, a['street'])

          begin
            address.update_attributes!(
              :person => person,
              :city => a['city'],
              :state => State.find_by_abbrev(a['state']),
              :postal_code => a['zip'],
              :votesmart_type => a['type'],
              :phone_one => p['phone1'],
              :phone_two => p['phone2'],
              :fax_one => p['fax1'],
              :fax_two => p['fax2']
            )
          rescue
            puts "error inserting address: #{$!}"
            pp addr
          end
        end
      else
        puts "Error retrieving #{person.full_name} (votesmart_id #{person.votesmart_id}): #{office['error']['errorMessage']}"
      end
      
      web = VoteSmart::Address.get_office_web_address person.votesmart_id

      if web['error'].blank?
        # VoteSmart will return an array here unless there's only one address available...
        addresses = web['webaddress']['address']

        # ... but to simplify things, let's always make an array happen.
        addresses = [addresses] unless addresses.kind_of?(Array)

        website_count = 0

        addresses.each do |addr|
          case addr['webAddressTypeId'].to_i
          when 1 # email
            person.email = addr['webAddress']
          when 2 # webmail
            person.webmail = addr['webAddress']
          when 3 # website
            if website_count == 0
              person.website_one = addr['webAddress']
            else
              person.website_two = addr['webAddress']
            end
            website_count+=1
          end
        end

        person.save

      else
        puts "Error retrieving #{person.full_name} (votesmart_id #{person.votesmart_id}): #{web['error']['errorMessage']}"
      end
      
      
    end
  end

end
