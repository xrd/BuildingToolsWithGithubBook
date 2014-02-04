require 'asciidoctor'
require 'erb'

$:.unshift( "../gems/oreilly-snippets/lib" )
require 'oreilly/snippets'

init_script = '<script type="text/javascript" src="init.js"></script>';

guard 'shell' do
  watch(/pre/^[^\/]*\.asciidoc$/) {|m|
    contents = File.read( m[0] )
    snippetized = Oreilly::Snippets.process( contents )

    out = Asciidoctor.render( snippetized,
                              :header_footer => true,
                              :safe => Asciidoctor::SafeMode::SAFE,
                              :attributes => {'linkcss!' => ''})
    File.open m[0]+".html", "w+" do |f|
      out.gsub!( '</body>', "</body>\n#{init_script}\n" )
      f.write out
      puts "Wrote: #{m[0]+'.html'}"
    end
  }
end

guard 'livereload' do
  watch(%r{^.+\.(css|js|html)$})
end
