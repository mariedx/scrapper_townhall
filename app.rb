require 'bundler'
Bundler.require

require 'open-uri'

$:.unshift File.expand_path("./../lib", __FILE__)
require 'app/scrapper'

mairie = Scrapper.new
# mairie.save_as_JSON
# mairie.save_as_Google
# mairie.save_as_csv

