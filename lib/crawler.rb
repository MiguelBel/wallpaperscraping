class Crawler

	@@url = "http://wallpaperswide.com/"

	def getPage(url)
		agent = Mechanize.new
		page = agent.get(url)
		return page
	end

	def getCategories	
		page = self.getPage(@@url)
		categories = []
		page.search("ul.categories a").each do |link|
			categories.push [link.text, @@url + link["href"]]
		end 
		return categories
	end

	def insertCategories
		categories = self.getCategories
		categories.each do |category|
			created = Categories.create(:name => category[0], :url => category[1])
		end
	end

	def getMaxPage(content)
		pages_links = []

		content.search("div.pagination").each_with_index do |pagination, index|
			pagination.search("a").each do |link|
				pages_links.push link["href"].gsub(/[^0-9]/, '').to_i
			end
		end
			return pages_links.max
	end

	def getMaxPages
		categories = Categories.all
		maxPages = []
		categories.each do |category|
			maxPages.push [category.name, self.getMaxPage(self.getPage(category.url))]
		end

		return maxPages
	end

	def insertMaxPages
		maxPages = self.getMaxPages
		maxPages.each do |page|
			CategoryMaxPage.create({:page => page[1], :category => page[0]})
		end		
	end

	def generateURL(category, page)
		category = Categories.first({:name => category})
		return "#{category.url.chop.chop.chop.chop.chop}/page/#{page}"
	end

	def getLinks(category, page)
		page = self.getPage(self.generateURL(category, page))

		links = []
		totalUL = page.search("ul.wallpapers").count

		page.search("ul.wallpapers").each_with_index do |div, index|
			if index == 1 or totalUL == 1
				div.search("a").each do |link|
					links.push link["href"]
				end
			end
		end

		return links.uniq
	end

	def insertLinks(category, page)
		links = self.getLinks(category, page)
		links.each do |link|
			Links.create({:category => category, :link => link, :page => page})
		end
	end

	def getAllTheLinks(category)
		category = Categories.first({:name => category})
		initial = Links.all.count
		maxPage = CategoryMaxPage.first({:category => category.name})
		(1..maxPage.page).each do |page|
			self.insertLinks(category.name, page)
			total = Links.all.count - initial
			p "Inserted of #{category.name} [#{category.id}/28] the page #{page} of #{maxPage.page} with #{total} links"
		end
	end

	def getAllTheLinksOfAllCategories(low_limit)
		getCategories.each_with_index do |category, index|
			if index > low_limit
				self.getAllTheLinks(category)
			end
		end
	end

	def getLinkBestImage(partial_url)
		full_url = @@url + partial_url
		page = self.getPage(full_url)
		resolutions = []
		page.search("div.wallpaper-resolutions a").each do |item|
			partial_res = item.text.split("x")
			resolutions.push [partial_res[0].to_i * partial_res[1].to_i, item.text, @@url.chop + item["href"]]
		end

		final_resolution = resolutions.max

		return final_resolution[2]
	end

	def downloadImage(partial_url, category)
		link = self.getLinkBestImage(partial_url)
		agent = Mechanize.new
		agent.pluggable_parser.default = Mechanize::Download
		ref = @@url.chop + partial_url
		#/long_desert_road_black_and_white-wallpapers.html
		partial_url[0] = ""
		partial_url = partial_url.chop.chop.chop.chop.chop
		path = "images/#{category}/#{partial_url}.jpg"
		create = agent.get(link, nil, ref).save(path)
		return File.exist?(path)
	end

	def downloadAllImages
		links = Links.all(:downloaded => false)
		links.each do |link|
			download = self.downloadImage(link.link, link.category)
			if download
				adapter = DataMapper.repository(:default).adapter
				updated = adapter.execute("UPDATE links SET downloaded=TRUE WHERE id=#{link.id};")
				p "Downloaded #{link.link} with id #{link.id}/#{links.count}"
			else
				pp download
			end
		end
	end

end