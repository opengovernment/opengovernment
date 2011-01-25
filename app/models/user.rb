class User < ActiveRecord::Base
  if ActiveRecord::Base.configurations.has_key?('opencongress')
    establish_connection 'opencongress'

    # some column name differences between OC implementation and devise
    # these columns should be renamed and methods removed before launch
    def encrypted_password
      self.crypted_password
    end

    def encrypted_password=(val)
      self.crypted_password = val
    end

    def password_salt
      self.salt
    end

    def password_salt=(val)
      self.salt = val
    end
  end

  devise :database_authenticatable, :rememberable, :token_authenticatable, :timeoutable

  attr_accessible :login, :email, :password, :password_confirmation

  # hook called after token authentication (in our case, SSO)
  def after_token_authentication
    # immediately change the auth_token so it can't be used again
    update_attribute('authentication_token', Digest::SHA1.hexdigest("--#{Time.now.utc}--#{encrypted_password}--#{id}--#{rand}--"))
  end

  def self.find_for_database_authentication(conditions)
    value = conditions[authentication_keys.first]
    where(["login = :value OR email = :value", { :value => value }]).first
  end
end
