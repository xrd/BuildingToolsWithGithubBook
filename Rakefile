
ASCIIDOC_EXT= ".asciidoc"

def process_asciidoc( file )
  # asciidoc -f orm.docbook45.conf -a docinfo -b docbook -d book -v -o chapter-13-github-api-on-javascript.asciidoc.xml chapter-13-github-api-on-javascript.asciidoc
  `asciidoc -f support/orm.docbook45.conf -a docinfo -b docbook -d book -v -o xml/#{file}.xml #{file}`
end

namespace :github do

  desc "Build Asciidoc"
  task :build_asciidoc do
    if filename = ENV['f'] || ENV['filename']
      puts "File: #{filename}"
      process_asciidoc filename
    else
      Dir.foreach "." do |f|
        if (f.length-ASCIIDOC_EXT.length) == f.index( ASCIIDOC_EXT )
          process_asciidoc f
        end
      end
    end
  end
end


