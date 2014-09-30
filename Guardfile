require 'asciidoctor'
require 'erb'
require 'oreilly/snippets'

#$:.unshift( "../gems/oreilly-snippets/lib" )
require 'oreilly/snippets'

init_script = '<script type="text/javascript" src="init.js"></script>';

guard 'shell' do
  watch( /^pre\/[^\.][^\/]*\.asciidoc$/) {|m|
    contents = File.read( m[0] )
    snippetized = Oreilly::Snippets.process( contents )
    snippet_out =  m[0].gsub( "pre/", "" )
    File.open( snippet_out, "w+" ) do |f|
      f.write snippetized
    end
  }
end

guard 'shell' do 
  watch( /^[^\/]*\.asciidoc$/ ) { |m|
    asciidoc = File.read( m[0] )
    out = Asciidoctor.render( asciidoc,
                              :header_footer => true,
                              :safe => Asciidoctor::SafeMode::SAFE,
                              :attributes => {'linkcss!' => ''})

    File.open( m[0]+ ".html", "w+" ) do |f|
      out.gsub!( '</body>', "</body>\n#{init_script}\n" )
      f.write out
    end
  }
end

guard 'livereload' do
  watch(%r{^.+\.(css|js|html)$})
end
