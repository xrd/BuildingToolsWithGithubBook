
ASCIIDOC_EXT= ".asciidoc"

def process_asciidoc( file )
  # asciidoc -f orm.docbook45.conf -a docinfo -b docbook -d book -v -o chapter-13-github-api-on-javascript.asciidoc.xml chapter-13-github-api-on-javascript.asciidoc
  `asciidoc -f support/orm.docbook45.conf -a docinfo -b docbook -d book -v -o xml/#{file}.xml #{file}`
end

def get_all_asciidoc_files
  files = []
  Dir.foreach "." do |f|
    if (f.length-ASCIIDOC_EXT.length) == f.index( ASCIIDOC_EXT )
      files << f
    end
  end
  files
end

def error( msg, line, file )
  puts "#{file}:#{line}: #{msg}"
end

namespace :github do

  desc "Check heading levels"
  task :check_heading_levels do
    get_all_asciidoc_files.each do |f|
      found_first = false
      File.readlines( f ).each_with_index do |l,i|
        if !found_first
          if l =~ /^=={3}.*/
            error( "First header must be two level header (==)", i, f )
            puts 
          else
            found_first = true
          end
        elsif l =~ /^={1,2}[^=]/ and not found_first
          error( "Incorrect header count: '#{l}'", i, f )
        end
      end
    end
  end
  
  desc "Build Asciidoc"
  task :build_asciidoc do
    if filename = ENV['f'] || ENV['filename']
      puts "File: #{filename}"
      process_asciidoc filename
    else
      get_all_asciidoc_files.each do |f|
        process_asciidoc f
      end
    end
  end
end


