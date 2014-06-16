require 'rubygems'
require 'mechanize'
require 'vcr'

VCR.configure do |c|  # <1> 
  c.cassette_library_dir = 'cached'
  c.hook_into :webmock
end

class ByTravelersProcessor
  attr_accessor :mechanize  # <2>

  def initialize
    @mechanize = Mechanize.new { |agent| # <3>
      agent.user_agent_alias = 'Mac Safari'
    }
  end

  def run
    100.times do |i| 
      get_ith_page( i ) # <4>
    end
  end
  
  def get_ith_page( i )
    puts "Loading #{i}th page"
  end
  
end

  
