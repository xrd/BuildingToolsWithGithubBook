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

  def write_post( page )
    title = page[0]
    body = page[1]
    creation_date = page[2]

    template = <<"TEMPLATE"  # <2>
---
layout: default
title: "#{title.gsub(/"/, '\\"')}"
published: false
---

#{body}
TEMPLATE
    
    title_for_filename = title.downcase.gsub( /[",]+/, '' ).gsub( /[\s\/\:\;]+/, '-') # <3>
    filename = "_posts/#{creation_date}-#{title_for_filename}.md"
    File.open( filename, "w+" ) do |f|
      f.write template
    end
  end

  def run
    100.times do |i| 
      get_ith_page( i ) 
    end
    100.times do |i|
      if pages[i]
        write_post( pages[i] ) # <4>
      end
    end
  end

  def process_creation_date( i, row )
    location, creation_date = row.text().split /last updated on:/ # <5>
    creation_date.strip()
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
            creation_date = process_creation_date( i, rows[3] )
            pages[ i ] = [ title, body, creation_date ]
          end
        end
      end
    rescue Exception => e
    end
    
  end
  
end

  
