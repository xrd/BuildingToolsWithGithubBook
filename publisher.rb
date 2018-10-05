require 'asciidoctor'
require 'erb'
require 'oreilly/snippets'
require 'colorize'
require 'fileutils'

Oreilly::Snippets.config( flatten: true, skip_flattening: { java: true } )

class Publisher
  
  ENV_VARS = [ 'PUBLISH_ROOT' ]
  REPOSITORIES = [
    'https://github.com/xrd/final-scraper',
    'https://github.com/xrd/GhRu2',
  ]
  
  attr_accessor :root
  
  def verify_all_env_vars
    rv = true
    ENV_VARS.each do |e|
      if !ENV[e]
        STDERR.puts "Environment variable #{e} is not defined and is required".red
        rv = false
      end
    end
    
    if rv
      @root = ENV['PUBLISH_ROOT']
    end
    
    rv
  end
  
  def verify_all_repositories
    rv = true
    REPOSITORIES.each do |e|
      # Get the directory
      dir = "../#{e.split('/').pop}"
      if !Dir.exists? dir
        STDERR.puts "A necessary repository is not available (for snippets) #{dir}".red
        STDERR.puts "  Fix it with this command: `pushd .. && git clone #{e} && popd`".green
        rv = false
      end
    end
    
    rv
  end
  
  def build
    Dir.foreach(".") do |filename|
      
      # Only process things with snippets in them.
      if filename.include?(".asciidoc.snippet")
        puts "Processing: #{filename} as a snippet file"
        out = process_file( d )
        # Do something with that...
        File.open( root + filename, "w+" ) do |f|
          f.write out
        end
      else if filename.include?(".html")
        puts "Processing: #{filename} as a regular HTML file into #{@root}"
        # Copy the file into the build directory
        FileUtils.cp( filename, @root + filename )
      end
    end
  end
  
  def process_file(file)
    ## Iterate over the entire set of files called 
    contents = File.read( file )
    snippetized = Oreilly::Snippets.process( contents )
    asciidoc = File.read( snippetized )
    out = Asciidoctor.render( asciidoc,
                              :header_footer => true,
			      :line_numbers => true,
			      :src_numbered => 'numbered',
                              :safe => Asciidoctor::SafeMode::SAFE,
                              :attributes => {'linkcss!' => ''})
    out
  end
end
end
