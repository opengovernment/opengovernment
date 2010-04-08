Sham.define do
  fips_code { rand(50) }
  abbrev { Faker::Address.us_state_abbr }
end

State.blueprint do
  name { Faker::Name.name }
  abbrev { }
  fips_code
end

State.blueprint(:supported) do
  launch_date { 2.minutes.ago }
end

State.blueprint(:unsupported) do
end

State.blueprint(:pending) do
  launch_date { 2.minutes.from_now }
end
