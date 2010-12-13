namespace :generate do
  desc 'Generates a Session Secret Token and other app tokens'
  task :app_tokens do
    path = File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
    secret_token = ActiveSupport::SecureRandom.hex(40)
    File.open(path, 'w') do |f|
      f.write <<"EOF"
# Be sure to restart your server when you modify this file.

# Your secret key for verifying the integrity of signed cookies.
# If you change this key, all old signed cookies will become invalid!
# Make sure the secret is at least 30 characters and all random,
# no regular words or you'll be exposed to dictionary attacks.
Rails.application.config.secret_token = '#{secret_token}'
EOF
    end

  end

end
