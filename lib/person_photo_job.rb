class PersonPhotoJob < Struct.new(:person_id)
  def perform
    Person.find(self.person_id).sync_photo!
  end
end