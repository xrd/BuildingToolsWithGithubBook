require 'rubygems'
require 'mechanize'
require 'vcr'

VCR.configure do |c|  
  c.cassette_library_dir = 'cached'
  c.hook_into :webmock
end

class ByTravelersProcessor
  attr_accessor :mechanize, :pages 

  def initialize
    @mechanize = Mechanize.new { |agent| 
      agent.user_agent_alias = 'Mac Safari'
    }
    @pages = []
  end

  def run
    100.times do |i| 
      get_ith_page( i ) 
    end
    100.times do |i|
      if pages[i]
        puts "'#{pages[i][0]}' (#{pages[i][1].length} characters)" # <4>
      end
    end
  end

  def process_body( i, row )
    row.text().strip() # <1>
  end

  def process_title( title )
    title = title
    if title
      title.gsub!( /Title:/, "" )
      title.strip!
    end
    title # <2>
  end
  
  def get_ith_page( i )
    root = "https://web.archive.org/web/20030502080831/http://www.bytravelers.com/journal/entry/#{i}"
    begin
      VCR.use_cassette("bt_#{i}") do 
        mechanize.get( root ) do |page|
          rows = ( page / "table[valign=top] tr" ) 
          if rows and rows.length > 3
            body = process_body( i, rows[4] ) 
            title = process_body( i, rows[1] )
            pages[ i ] = [ title, body ] # <3>
          end
        end
      end
    rescue Exception => e
    end
    
  end
  
end

  
