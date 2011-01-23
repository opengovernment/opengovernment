Before do
  # Webrat's default host is www.example.com, but Rails 3's default is
  # example.org.
  header('Host', 'example.org')
end
