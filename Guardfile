require 'asciidoctor'
require 'erb'

init_script = '<script type="text/javascript" src="init.js"></script>';

guard 'shell' do
  watch(/^[^\/]*\.asciidoc$/) {|m|
    out = Asciidoctor.render_file(m[0],
                                  :header_footer => true,
                                  :safe => Asciidoctor::SafeMode::SAFE, :attributes => {'linkcss!' => ''})
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
