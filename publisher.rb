# coding: utf-8
require 'asciidoctor'
require 'erb'
require 'oreilly/snippets'
require 'colorize'
require 'fileutils'
require 'nokogiri'

Oreilly::Snippets.config( flatten: true, skip_flattening: { java: true } )

class Publisher 
  
  ASCIIDOC_SNIPPETS_POSTFIX = ".asciidoc.snippet"
  ASCIIDOC_POSTFIX = ".asciidoc"
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
      puts "Root is: #{@root}".yellow
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

  def process_file(file)
    ## Iterate over the entire set of files called 
    contents = File.read( file )
    snippetized = Oreilly::Snippets.process( contents )
    out = asciidoc_to_html(snippetized)
    return out
  end

  def asciidoc_to_html(contents)
    # append the special editing sauce
    rendered = Asciidoctor.render( ( ENV['BTWG_EXTRAS'] ? ":docinfo1: shared\n\n" : "" ) +
                               contents,
                               :header_footer => true,
			       :line_numbers => true,
			       :src_numbered => 'numbered',
                               :safe => Asciidoctor::SafeMode::SAFE,
                               :attributes => {'linkcss!' => ''})

    doc = Nokogiri::HTML::DocumentFragment.parse rendered
    title = Nokogiri::XML::Node.new "h2", doc
    title.content = doc.search( "h2" )[0].content
    puts "TITLE: #{title}".yellow
    paragraph = Nokogiri::XML::Node.new "div", doc
    paragraph.add_class 'paragraph'
    p = Nokogiri::XML::Node.new "p", doc
    p.content = doc.search( ".paragraph" )[0].content
    paragraph.add_child p
    puts "Excerpt: #{paragraph}".yellow

    excerpt_wrapper = Nokogiri::XML::Node.new "div", doc
    excerpt_wrapper.set_attribute :id, 'excerpt'
    sect1 = Nokogiri::XML::Node.new "div", doc
    sect1.add_class( 'sect1' )
    sectionbody = Nokogiri::XML::Node.new "div", doc
    sectionbody.add_class( 'sectionbody' )
    sectionbody.add_child paragraph
    sect1.add_child title
    sect1.add_child sectionbody
    
    excerpt_wrapper.add_child sect1
    
    body = doc.search('body').first
    body.prepend_child excerpt_wrapper
    full = body.search( '#content').first
    full.set_attribute( 'style', "display: none" )

    return doc.to_html
  end
  
  def build
    all_files = process_all_files()
    puts "All files: #{all_files}"
    # Now, write up the index.html file
    write_index(all_files)

    # Copy in the extras
    FileUtils.copy "extras/fab.css", @root
    FileUtils.copy "extras/edit.js", @root
    FileUtils.copy "extras/micromodal.css", @root
  end

  def process_all_files
    processed = []
    Dir.foreach(".") do |filename|
      # Only process things with snippets in them.
      if filename.end_with?(ASCIIDOC_SNIPPETS_POSTFIX)
        puts "Processing: #{filename} as a snippet file".yellow
        out = process_file(filename)
        # Now, get the file without ".asciidoc.snippet" and
        htmlFilename = filename.gsub(ASCIIDOC_SNIPPETS_POSTFIX, ".html")
        # Save it to use later.
        processed << htmlFilename
        puts "Converted #{filename} to #{htmlFilename}".yellow
        File.open( File.join( @root, htmlFilename), "w+" ) do |f|
          f.write out
        end
      elsif filename.end_with?(ASCIIDOC_POSTFIX)
        htmlFilename = filename.gsub( ".asciidoc", ".html" )

        # If it is already processed as snippet, ignore it.
        if processed.include?(htmlFilename)
          puts "Already processed: #{htmlFilename}".blue
          next
        end
        puts "Processing: #{filename} as a #{ASCIIDOC_POSTFIX} file into #{File.join( @root, filename )}".yellow
        contents = File.read( filename )
        out = asciidoc_to_html(contents)
        # Get the new filename
        processed << htmlFilename
        
        File.open( File.join( @root,  htmlFilename ), "w+") do |f|
          f.write out
        end
      end
    end
    return processed
  end
  
  def write_index(all_files)
    toc = <<"END"
[[introduction]]
[role="pagenumrestart"]
== Building Tools with GitHub

==== By Chris Dawson and Ben Straub

If you find value in the material here, 
consider supporting the authors by buying the book from http://shop.oreilly.com/product/0636920043027.do[O'Reilly] 
or on https://www.amazon.com/Building-Tools-GitHub-Customize-Workflow/dp/149193350X[Amazon]

The repository with this book contents can be 
found at https://github.com/xrd/BuildingToolsWithGithubBook[github.com/xrd/BuildingToolsWithGithubBook].

If you would like to offer your comments and suggestions on the book while reading, try visiting the 
https://btwg2.teddyhyde.io[experimental site].

A huge thank you to O'Reilly for allowing us to republish this under creative commons.

END

    # Get all the chapters, plus the preface as the first file and the appendix as the last
    all_files
      .select { |f| f.include?("chapter") }
      .sort
      .uniq
      .unshift( "preface.html" )
      .push( "appendix-ruby-and-nodejs.html" )
      .each do |f|
      # Get the title from the file, read in the first ten lines and get the header...
      puts "Processing file: #{f}"
      # Get the original and the header
      original = File.exists?( f.gsub('.html', '.asciidoc.snippet') ) ? f.gsub('.html', '.asciidoc.snippet') : f.gsub('.html', '.asciidoc' )
      title = ""
      if File.exists?(original)
        puts "Grabbing original contents from #{original}".green
        title = File.read( original ).split( "\n" )[0..10].find { |l| '='.eql?(l[0]) && '='.eql?(l[1]) }[2..-1]
      else
        puts "No file found: #{f}".red
      end
      # puts "Title: #{title}".green
      toc += "1. link:#{f}[#{title}]\n"
    end
    
    contents = Asciidoctor.render( toc,
                                   :header_footer => true,
			           :line_numbers => true,
			           :src_numbered => 'numbered',
                                   :safe => Asciidoctor::SafeMode::SAFE,
                                   :attributes => {'linkcss!' => ''})
    
    File.open( File.join( @root, "index.html"), "w+" ) do |f|
      f.write( contents )
    end    
    
  end
end
