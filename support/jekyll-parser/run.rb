require 'rubygems'
require 'bundler/setup'
require './scraper'

btp = ByTravelersProcessor.new()
btp.run()
