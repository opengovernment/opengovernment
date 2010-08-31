Factory.define :subject do |s|
  s.name 'Education'
end

Factory.define :tag, :class => ActsAsTaggableOn::Tag do |t|
  t.name 'education'
end

Factory.define :tagging, :class => ActsAsTaggableOn::Tagging do |t|
  t.tag { |tag| tag.association(:tag) }
  t.taggable {|taggable| taggable.association(:subject) }
end 

Factory.define :bills_subject do |bs|
  bs.bill_id { Bill.first.id }
  bs.subject {|s| s.association(:subject) }
end
