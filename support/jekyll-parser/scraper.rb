require 'rubygems'
require 'mechanize'
require 'vcr'
require 'net/http'

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
    title = page[0][0]  # <1>
    image = page[0][1]
    body = page[1]
    creation_date = page[2]
    
    title.gsub!( /"/, '' )
    
    template = <<"TEMPLATE" 
---
layout: post   
title: "#{title}"  
published: true
image: #{image}   # <2>
---

#{body}
TEMPLATE

    title_for_filename = title.downcase.gsub( /,+/, '' ).gsub( /[\s\/\:\;]+/, '-') 
    # puts "Title: #{title_for_filename}"
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
        write_post( pages[i] ) 
      end
    end
  end

  def process_creation_date( i, row )
    location, creation_date = row.text().split /last updated on:/ 
    creation_date.strip()
  end  
  
  def process_body( name, i, row )
    body = ""
    if row
      ( row / "p" ).each do |p|
        text = p.text()
        text.strip!
        text.gsub!( /\*\s*/, '' )
        body += text + "\n\n"
      end
    end
    body 
  end

  def process_title( i, title )
    img = ( title / "img" ) 
    src = img.attr('src').text()
    filename = src.split( "/" ).pop
    
    output = "assets/images/"
    full = File.join( output, filename ) 
    
    unless File.exists? full
      root = "https://web.archive.org"
      remote = root + src
      contents = `wget --quiet -O #{full} #{remote}`  
    end
    
    title = title.text()
    if title
      title.gsub!( /Title:/, "" )
      title.strip!
    end
    [ title, filename ] 
    
  end
  
  def get_ith_page( i )
    root = "https://web.archive.org/web/20030502080831/http://www.bytravelers.com/journal/entry/#{i}"
    begin
      VCR.use_cassette("bt_#{i}") do 
        mechanize.get( root ) do |page|
          rows = ( page / "table[valign=top] tr" ) 
          if rows and rows.length > 3
            title = process_title( i, rows[1] )
            body = process_body( title, i, rows[4] ) 
            creation_date = process_creation_date( i, rows[3] )
            pages[ i ] = [ title, body, creation_date ]
          end
        end
      end
    rescue Exception => e
      puts "Error: #{e}"
    end
  end
  
end

  
