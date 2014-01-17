require 'asciidoctor'
require 'erb'

guard 'shell' do
  watch(/^*\.asciidoc$/) {|m|
    out = Asciidoctor.render_file(m[0],
        :header_footer => true,
                                  :safe => Asciidoctor::SafeMode::SAFE, :attributes => {'linkcss!' => ''})
    File.open m[0]+".html", "w+" do |f|
      f.write out
      puts "Wrote: #{m[0]+'.html'}"
    end
  }
end

guard 'livereload' do
  watch(%r{^.+\.(css|js|html)$})
end
