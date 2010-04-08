def setup_districts
  # Force a reload of the DistrictType class, so we get the proper constants
  #Object.class_eval do
  #  remove_const("DistrictType") if const_defined?("DistrictType")
  #end
  #load "district_type.rb"
  
  #District.delete_all
  # For testing, we will keep things simple and install only Texas.
  #OpenGov::District.import!(File.join(Rails.root, 'spec/shapefiles/su48_d11.shp'))
end
