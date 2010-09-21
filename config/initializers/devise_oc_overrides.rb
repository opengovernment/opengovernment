module Devise
  module Models
    module DatabaseAuthenticatable
      protected

      # We need to use the same digest that OC uses otherwise everyone will have to change their password.
      def password_digest(password)
        Digest::SHA1.hexdigest("--#{self.salt}--#{password}--")
      end
    end
  end
end