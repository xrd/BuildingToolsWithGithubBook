require 'asciidoctor'
require 'erb'
require 'oreilly/snippets'

require 'json'

RENDER_REGEX = /([^\/]*\.asciidoc)\.html$/
INIT_SCRIPT = '<script type="text/javascript" src="init.js"></script>';

class AsciiToHTML
  def initialize(app)
    @app = app
  end
  def call(env)
    self.render(env)
    @app.call(env)
  end

  protected

  def render(env)
    puts env["REQUEST_PATH"]
    m = RENDER_REGEX.match(env["REQUEST_PATH"])
    return unless m

    asciidoc = File.read( m[1] )
    out = Asciidoctor.render( asciidoc,
                              :header_footer => true,
                              :safe => Asciidoctor::SafeMode::SAFE,
                              :attributes => {'linkcss!' => ''})

    File.open( m[0], "w+" ) do |f|
      out.gsub!( '</body>', "</body>\n#{INIT_SCRIPT}\n" )
      f.write out
    end
  end
end

use AsciiToHTML

run Rack::Directory.new('.')
