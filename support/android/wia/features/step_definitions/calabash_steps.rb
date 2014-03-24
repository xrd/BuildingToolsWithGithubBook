require 'calabash-android/calabash_steps'

def check_and_set( name, text )
  check_element_exists "edittext contentDescription:'GitHub #{name}'"
  query "edittext contentDescription:'GitHub #{name}'", :setText => text
end

When(/^I enter the username$/) do
  check_and_set( "username", ENV['GH_USERNAME'] )
end

When(/^I enter the password$/) do
  check_and_set( "password", ENV['GH_PASSWORD'] )
end

