module OpenGov::Load::Addresses
  def self.import!
    Person.with_votesmart_id.with_current_role.each do |person|
      begin
        Address.delete_all(:person_id => person.id)

        main_office =  GovKit::VoteSmart::Address.find person.votesmart_id
        offices = main_office.office.to_a

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

        web_address = GovKit::VoteSmart::WebAddress.find person.votesmart_id
        web_addresses = web_address.address.to_a

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
        puts "Updating #{person.full_name}"
        person.save
      rescue
        puts "Problem saving #{person.full_name}..skipping"
      end
    end
  end
end
