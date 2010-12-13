namespace :generate do
  desc 'Generates a Session Secret Token'
  task :secret_token do
    path = File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
    secret = ActiveSupport::SecureRandom.hex(40)
    File.open(path, 'w') do |f|
      f.write <<"EOF"
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Rails.application.config.secret_token = '#{secret}'
EOF
    end
    
    path = File.join(Rails.root, 'config', 'initializers', 'rack-bug.rb')
    secret = ActiveSupport::SecureRandom.base64(30)
    File.open(path, 'w') do |f|
      f.write << "EOF"
Rails.application.config.middleware.use 'Rack::Bug', :secret_key => '#{secret}'
EOF
    end
  end

end
