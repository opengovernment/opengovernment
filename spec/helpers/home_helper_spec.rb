require 'spec/spec_helper'

describe HomeHelper do
  include HomeHelper

  it "should return an appropriate Google Chart image tag" do
    State.delete_all
    State.make(:supported, :abbrev => "AA")
    State.make(:supported, :abbrev => "BB")
    State.make(:pending, :abbrev => "CC")
    State.make(:pending, :abbrev => "DD")
    us_map_image_tag.should match(/<img src="http:\/\/chart.apis.google.com\/chart\?cht=t&chs=[\dx]+&chd=s:AA99&chco=[A-F\d,]+&chld=AABBCCDD&chtm=usa&chf=bg,s,[A-F\d]+">/)
  end

end
