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
    root = "https://web.archive.org/web/20030502080831/" +
      "http://www.bytravelers.com/journal/entry/#{i}"
    begin
      VCR.use_cassette("bt_#{i}") do # <1>
        @mechanize.get( root ) do |page|
          rows = ( page / "table[valign=top] tr" ) # <2>
          if rows and rows.length > 3
            self.process_body( i, rows[4] ) # <3>
          end
        end
      end
    rescue Exception => e
    end
  end

  def process_body( i, row )
    puts "#{i}: #{row.text().strip()[0...50]}"
  end
  
end

  
