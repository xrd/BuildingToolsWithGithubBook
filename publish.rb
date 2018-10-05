require './publisher'
require 'colorize'

publisher = Publisher.new()

# Verify all necessary environment variables
vars = publisher.verify_all_env_vars()
repos = publisher.verify_all_repositories()
if ( !vars || !repos )
  abort "Not all parameters could be satisfied, exiting".red
else
  puts "Hey, it all worked out."
  publisher.build()
end
