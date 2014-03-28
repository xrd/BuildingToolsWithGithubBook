require 'calabash-android/calabash_steps'

@status = nil
moods = %w{ happy sad angry blue energized }

def check_and_set( id, text )
  check_element_exists "edittext id:'#{id}'"
  query "edittext id:'#{id}'", :setText => text
end

When(/^I enter the username$/) do
  check_and_set( "username", ENV['GH_USERNAME'] )
end

When(/^I enter the password$/) do
  check_and_set( "password", ENV['GH_PASSWORD'] )
end

Then(/^I enter my current mood status$/) do
  @mood = "Feeling #{moods[(rand()*moods.length).to_i]} today, at #{DateTime.new()}"
  puts @mood
end

And(/^I have a new jekyll post/) do
  `curl https://api.github.com/#{ENV['GH_USERNAME'}/#{ENV['GH_REPO']}/_posts
END

