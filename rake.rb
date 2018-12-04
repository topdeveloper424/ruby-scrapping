require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

class Webscraper
	@@json_data = []
	def extract_jobs(page_content)
		page_content.css('.jobsearch-SerpJobCard').each do |job|
			job_title = job.css('.jobtitle').text
			company = job.css('.company').text
			snip = job.css('.snip')
			wage = snip.css('.no-wrap').text
			summary = job.css('.summary').text
			detail_link = job['data-jk']
			@@json_data.push(
				title:job_title,
				company:company,
				wage:wage,
				summary:summary,
				detail_link:detail_link
				)
		end
	end

	def save_json()
		json = JSON.pretty_generate(@@json_data)
		File.open("data.json", 'w') { |file| file.write(json) }
		
	end

	def get_data(what,where,page_num)
		page_num = page_num - 1
		url = "https://www.indeed.co.uk/jobs?q="+what+"&l="+where+"&start="
		for i in 0..page_num
			start_num = i * 10
			url_temp = url + start_num.to_s
			url_temp = URI::encode(url_temp)
			page = Nokogiri::HTML(open(url_temp))
			extract_jobs(page)
			puts "----------------------------"
		end
		save_json()
	end
end



what = "it support analyst"
where = "London Heathrow Terminal 3"
number = 5
scrapper = Webscraper.new
scrapper.get_data(what,where,number)


