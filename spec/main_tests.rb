require 'rspec'
require 'mechanize'
require 'nokogiri'

require File.dirname(__FILE__) + '/../lib/crawler.rb'
require File.dirname(__FILE__) + '/../lib/database.rb'



#tests
describe "Main tests" do

	let(:crawler) { Crawler.new }

	it "tests test" do
		plus = 2 + 2
		plus.should eql 4
	end

	it "get categories should return an array" do
		categories = crawler.getCategories
		categories.class.should eql Array
	end

	it "insert categories in database" do
		crawler.insertCategories
		categories = Categories.all.count
		categories.should eql 28
	end

	it "get max page" do
		maxPages = crawler.getMaxPages
		maxPages.class.should eql Array
		maxPages[0][1].class.should eql Fixnum
	end

	# it "insert max pages" do
	# 	crawler.insertMaxPages
	# 	maxPages = CategoryMaxPage.all.count
	# 	maxPages.should eql 28
	# end


	# it "get links of wallpapers from a website" do
	# 	category = "Charity"
	# 	page = 1
	# 	crawler.getLinks(category, page).count.should eql 10
	# end

	# it "get the link of best image" do
	# 	partial_url = '/long_desert_road_black_and_white-wallpapers.html'
	# 	crawler.getLinkBestImage(partial_url).class.should eql String
	# end

	# it "download the image" do
	# 	partial_url = '/long_desert_road_black_and_white-wallpapers.html'
	# 	category = 'Aero'
	# 	crawler.downloadImage(partial_url, category)
	# end
end