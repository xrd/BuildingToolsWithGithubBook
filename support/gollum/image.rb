require 'sinatra'
require 'gollum-lib'
require 'tempfile'
require 'zip/zip'
wiki = Gollum::Wiki.new(".")
get '/' do
  render File.open( "index.html" )
end
post '/unpack' do
    zip = params[:zip][:tempfile]
    Zip::ZipFile.open( zip ) { |zipfile|
      zipfile.each do |f|
        puts "F: #{f.name}"
        # Extract files into our images directory                                                                                              filename = "images/" + ( f.name.gsub( /\s+/, '_' ).gsub( /^.*\/([^\/]*)$/, $1 ) )
        puts "Filename: #{filename}"
      end
    }
  }
  render json: { success: 'ok' }
end  
