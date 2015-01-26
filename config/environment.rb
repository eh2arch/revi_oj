# Load the Rails application.
require File.expand_path('../application', __FILE__)

# Initialize the Rails application.
Rails.application.initialize!

ENV['RECAPTCHA_PUBLIC_KEY'] = '6LdKugATAAAAAHjwxeyd-7MR8S1xOWAUjIGmUNrU'
ENV['RECAPTCHA_PRIVATE_KEY'] = '6LdKugATAAAAAC726rSnQ82wcaslzVR5UE5DxXEz'
