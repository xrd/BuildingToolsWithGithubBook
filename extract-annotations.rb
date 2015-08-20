#!/usr/bin/env ruby

require 'pdf-reader'
require 'fileutils'

filename = ARGV.shift
initials = ARGV.shift

unless filename and initials
  puts "Need filename and initials as arguments"
  exit
end

todos = []
pages = []
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
              todos << { page: page.number, comment: actual_annot[:Contents].inspect }
              pages << { text: page.text, page: page.number }
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

path = File.join "reviews", initials
FileUtils.mkdir_p path

todo_page = "## Todos ##\n\n"
todos.each do |t|
  todo_page += "- [ ] from page [#{t[:page]}](#{t[:page]}.txt): '#{t[:comment]}'\n"
end

File.open( File.join( path, "todos.md" ), "w+"  ) do |f|
  f.write todo_page
end

pages.each do |p|
  File.open( File.join( path, "#{p[:page]}.txt" ), "w+" ) do |f|
    f.write p[:text]
  end
end
