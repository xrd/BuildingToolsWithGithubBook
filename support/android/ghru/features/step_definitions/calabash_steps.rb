require 'calabash-android/calabash_steps'
require 'httparty'

def set_title_and_mood
  moods = %w{ happy sad angry blue energized }
  @mood = "Feeling #{moods[(rand()*moods.length).to_i]} today"
  @title = @mood.downcase.strip.gsub(' ', '-').gsub(/[^\w-]/, '')
  date = (ENV['date'] ? Time.parse(ENV['date']) : Time.now).strftime('%Y-%m-%d')
  @filename = "_posts/#{date}-#{@title}.md"
end

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

Then(/^I choose my blog$/) do
  check_and_set( "repository", ENV['GH_REPO'] )
end

Then(/^I enter my current mood status$/) do
  set_title_and_mood()
  check_and_set( "post", @mood )
end

And(/^I have a new jekyll post with my mood status$/) do
  url = "https://raw.githubusercontent.com/#{ENV['GH_USERNAME']}/#{ENV['GH_REPO']}/#{ENV['GH_BRANCH']||'master'}/#{@filename}"
  puts "Checking #{url} for content..."
  response = HTTParty.get( url )
  assert( response.body.include?( @mood ), "Post unsuccessful" )
end

