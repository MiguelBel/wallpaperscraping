require 'bcrypt'
require 'data_mapper'

#Database
DataMapper.setup(:default, 'postgres://alice:password@localhost/wallpapers')

class Categories
	include DataMapper::Resource

	property :id, Serial
	property :name, Text, :lazy => false, :unique => true
	property :url, Text, :lazy => false, :unique => true
end

class CategoryMaxPage
	include DataMapper::Resource

	property :id, Serial
	property :category, Text, :lazy => false, :unique => true
	property :page, Integer
end	

class Links
	include DataMapper::Resource

	property :id, Serial
	property :category, Text, :lazy => false
	property :link, Text, :lazy => false, :unique => true
	property :page, Integer
	property :downloaded, Boolean, :default => false
end

DataMapper.auto_upgrade!