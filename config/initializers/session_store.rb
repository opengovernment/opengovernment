# Be sure to restart your server when you modify this file.

# Your secret key for verifying cookie session data integrity.
# If you change this key, all old sessions will become invalid!
# Make sure the secret is at least 30 characters and all random, 
# no regular words or you'll be exposed to dictionary attacks.
ActionController::Base.session = {
  :key         => '_opengovernment_session',
  :secret      => '15754ed78cc8a39bced342939a81a57dad76bf63ea66cf56c5894559153fed8cbe56a811bbc46e4520547ee5ad62554a0a69983f0bc53a8255de41785c6d5588'
}

# Use the database for sessions instead of the cookie-based default,
# which shouldn't be used to store highly confidential information
# (create the session table with "rake db:sessions:create")
# ActionController::Base.session_store = :active_record_store
