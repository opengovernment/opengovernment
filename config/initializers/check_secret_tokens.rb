unless File.exists?( File.join(Rails.root, 'config', 'initializers', 'secret_token.rb'))
  `rake generate:app_tokens`
   require File.join(Rails.root, 'config', 'initializers', 'secret_token.rb')
end
