require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'json'

class Webscraper
	@@json_data = []

	#extract job tags from web page
	def extract_jobs(page_content)
		page_content.css('.jobsearch-SerpJobCard').each do |job|
			job_title = job.css('.jobtitle').text   #get job title
			company = job.css('.company').text		#get company name
			snip = job.css('.snip')					
			wage = snip.css('.no-wrap').text		#get wage
			summary = job.css('.summary').text		#get summary
			detail_link = job['data-jk']			#get detail link
			@@json_data.push(
				title:job_title,
				company:company,
				wage:wage,
				summary:summary,
				detail_link:detail_link
				)
		end
	end

	#save json object as .json file
	def save_json()
		json = JSON.pretty_generate(@@json_data)					#parse
		File.open("data.json", 'w') { |file| file.write(json) }		#save as json file
		
	end

	#get data for all jobs from query,location, page number
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


input_array = ARGV
query = input_array[0]
location = input_array[1]
number = input_array[2]
query = ''
location = ''
temp_str = ''
input_array.each do |item|
	temp_str += item + ' '
end
splited_array = temp_str.split("-")
query = splited_array[0]
location = splited_array[1]
query = query.strip!
location = location.strip!
# query = "it support analyst"				#input for query
# location = "London Heathrow Terminal 3"		#input for location
number = 5
scrapper = Webscraper.new
scrapper.get_data(query,location,number)


