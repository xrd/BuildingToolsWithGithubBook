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
      get_ith_page( i )
    end
  end
  
  def get_ith_page( i )
    
  end
  
end

  
