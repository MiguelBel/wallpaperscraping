require 'json'
require 'pp'
require 'mechanize'
require 'nokogiri'

require ("./lib/crawler.rb")
require ("./lib/database.rb")

crawler = Crawler.new

crawler.downloadAllImages