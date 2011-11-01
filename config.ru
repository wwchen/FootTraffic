# This file is used by Rack-based servers to start the application.

# So this is a cool little "hack" to get Heroku to look at the /app directory for our app...
WEBSITE_SUBDIR = 'app'

#require ::File.expand_path('../config/environment',  __FILE__)
require ::File.expand_path("#{WEBSITE_SUBDIR}/config/environment",  __FILE__)

run FootTraffic::Application
