state = State.build(
  :name => 'Texas',
  :abbrev => 'TX'
  :url => 'http://www.capitol.state.tx.us',
  :unicameral => false,
  :fips_code => 48,
  :legislature => {
    :name => 'Texas Legislature',
    :chambers => [{
      :name => 'Senate',
      :title => 'Senator',
      :term_length => 4
    }, {
      :name => "House of Representatives",
      :title => 'Representative',
      :term_length => 2
    }]
  }  
);
state.save
state.legislature.save!

district = 

session = Session.new(
  :legislature => state.legislature,
  :start_year => 2009,
  :end_year => 2010,
  :name => '81'
)
session.save

sub_session = Session.new(
  :name => '811',
  :start_year => 2009,
  :end_year => 2010,
  :parent => session
)
sub_session.save

kirk = Person.new(
  :first_name => "Kirk",
  :last_name => "Watson",
  :openstates_id => 370,
  :votesmart_id => 57991
);
kirk.save

Role.create(
  :person => kirk,
  :session => session,
  :district => district,
  :chamber => state.legislature.upper_chamber,
  :party => 'Democrat'
)

Factory.define :bill_hb10, :class => Bill do |f|
  f.title 'Relating to the regulation of residential mortgage loan originators; providing a penalty.'
  f.bill_number  'HB 10'
  f.kind_one 'bill'
  f.association :state, :factory => :texas
  f.association :chamber, :factory => :tx_lower_chamber
  f.association :session, :factory => :tx_session_81
end

Factory.define :bill_sponsorship_hb10, :class => BillSponsorship do |f|
  f.kind 'author'
  f.association, :sponsor, :factory => :kirk
  f.association :bill, :factory => :bill_hb10
end

Factory.define :bill_hb10_signed, :class => Action do |f|
  f.actor 'upper'
  f.action 'Signed in Senate-Art III Sec 49a Tx. Const.'
  f.date '2009-07-01 07:00:00'
  f.kind_one 'bill:signed'
  f.action_number 'S1'
  f.association :bill, :factory => :hb10
end

Factory.define :bill_version_hb00010i, :class => BillVersion do |f|
  f.name: 'HB00010I'
  f.url 'ftp://ftp.legis.state.tx.us/bills/81R/billtext/html/house_bills/HB00001_HB00099/HB00010I.HTM'
  f.association :bill, :factory => hb10
end
