require 'rubygems'
require 'mechanize'
require 'vcr'

VCR.configure do |c|
  c.cassette_library_dir = 'cached'
  c.hook_into :webmock
end

class ByTravelersProcessor
  attr_accessor :mechanize

  def initialize
    @mechanize = Mechanize.new { |agent|
      agent.user_agent_alias = 'Mac Safari'
    }
  end

  def run
    100.times do |i|
      begin
        root = "http://web.archive.org/web/20030820233527/http://bytravelers.com/journal/entry/#{i}"
        VCR.use_cassette("bt_#{i}") do
          @mechanize.get( root ) do |page|
            begin

            end
          end
        end
      end
    end
              
  
end

  
