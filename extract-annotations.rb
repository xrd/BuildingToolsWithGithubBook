#!/usr/bin/env ruby

require 'pdf-reader'
require 'fileutils'
require 'json'

filename = ARGV.shift
initials = ARGV.shift
json = ARGV.shift

unless filename and initials and json
  puts "Need filename and initials and json-file as arguments"
  exit
end

todos = {}
if File.exists? File.join( "reviews", json )
  data = File.read( File.join( "reviews", json ) )
  todos = JSON.parse( data )
end

PDF::Reader.open(filename) do |reader|
  reader.pages.each do |page|
    begin
      annots_ref = page.attributes[:Annots]
      actual_annots = reader.objects[annots_ref]
      if actual_annots && actual_annots.size > 0
        actual_annots.each do |annot_ref|
          begin
            actual_annot = reader.objects[annot_ref]
            unless actual_annot[:Contents].nil?
              comment = actual_annot[:Contents].inspect
              todos[comment] = { page: page.number, text: page.text, initials: initials }
            end
          rescue Exception => e
            puts "Error in #{e.inspect}"
          end
        end
      end
    rescue Exception => e
      puts "Error in #{e.inspect}"
    end
  end
end

FileUtils.mkdir_p "reviews"

File.open( File.join( "reviews", json ), "w+" ) do |f|
  f.write todos.to_json
end

todo_page = "## Todos ##\n\n"
todos.keys.each do |k|
  t = todos[k]
  initials = t['initials'] || t[:initials]
  page = t['page'] || t[:page]
  text = t[:text] || t['text']
  unless initials and page and text
    puts "Nope! #{initials} / #{page} -> #{t.inspect}"
    exit
  end
  todo_page += "- [ ] from page [#{page} #{initials}](#{initials}-#{page}.txt): '#{k}'\n"
  File.open( File.join( "reviews", "#{initials}-#{page}.txt" ), "w+" ) do |f|
    f.write text
  end
end

File.open( File.join( "reviews", "todos.md" ), "w+"  ) do |f|
  f.write todo_page
end
