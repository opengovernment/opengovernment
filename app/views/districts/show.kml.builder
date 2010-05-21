xml.instruct!
xml.kml("xmlns" => KML_NS) do
  xml.tag! "Document" do
    xml.tag! "Style", :id => "myStyle" do
      xml.tag! "PolyStyle" do

        xml.color "#80800000" #format is aabbggrr
        xml.outline 1
      end

    end
    xml.tag! "Placemark" do
      xml.name @district.full_name
      xml.description @district.description
      xml.styleUrl "#myStyle"
      xml << @district.geom.as_kml(:altitude => 0, :altitude_mode => :relative)
    end
  end
end