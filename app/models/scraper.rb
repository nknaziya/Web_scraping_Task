require 'nokogiri'
require 'httparty'
require 'spreadsheet'
require 'pry'
require 'json'

url = 'https://www.ycombinator.com/companies'
response = HTTParty.get(url)
doc = Nokogiri::HTML(response.body)

json = []

elements = doc.css('.WxyYeI15LZ5U_DOM0z8F')
elements.each do |element|
  url = element['href']
  img_url = element.css('.left img').first['src']
  spans = element.css('.right span')
  title = spans[0].text
  address = spans[1].text
  description = spans[2].text
  json << {
    title: title,
    image: img_url,
    address: address,
    description: description,
    url: url
  }
end

full_json = json.map do |data|
  response = HTTParty.get(data[:url])
  company_doc = Nokogiri::HTML(response.body)
  data[:founded_in] = company_doc.css('.ycdc-card .flex-row span').last.text
  data[:website] = company_doc.css('.my-8 .text-linkColor').text
  data[:linkedin] = company_doc.css('.ycdc-card a[href*="linkedin').text
  puts data
  data
end

puts full_json

workbook = Spreadsheet::Workbook.new
worksheet = workbook.create_worksheet(name: 'Data')

worksheet.row(0).concat(['Title', 'Image', 'Address', 'Description', 'Founded In', 'Website','linkedin'])

full_json.each_with_index do |data, row|
  worksheet.row(row + 1).concat([data[:title], data[:image], data[:address], data[:description], data[:founded_in], data[:website], data[:linkedin]])
end

workbook.write('data.xls')



# -----------------------------------------------------------------------------------------------

# require 'nokogiri'
# require 'httparty'
# require 'spreadsheet'

# def extract_company_data(element)
#   title_element = element.css('.right span:first-child')
#   title = title_element.text.strip

#   address_element = element.css('.right span:nth-child(2)')
#   address = address_element.text.strip

#   description_element = element.css('.right span:nth-child(3)')
#   description = description_element.text.strip

#   img_element = element.css('.left img')
#   img_url = img_element.attr('src').to_s.strip

#   {
#     title: title,
#     address: address,
#     description: description,
#     image: img_url
#   }
# end

# def extract_additional_data(url)
#   response = HTTParty.get(url)
#   doc = Nokogiri::HTML(response.body)

#   website_element = doc.css('.my-8 .text-linkColor')
#   website = website_element.text.strip

#   linkedin_element = doc.css('.ycdc-card a[href*="linkedin"]')
#   linkedin_url = linkedin_element.attr('href').to_s.strip

#   founded_in_element = doc.css('.ycdc-card .flex-row span').last
#   founded_in = founded_in_element.text.strip

#   {
#     website: website,
#     linkedin_url: linkedin_url,
#     founded_in: founded_in
#   }
# end

# url = 'https://www.ycombinator.com/companies'
# response = HTTParty.get(url)
# doc = Nokogiri::HTML(response.body)

# companies = []

# elements = doc.css('.WxyYeI15LZ5U_DOM0z8F')
# elements.each do |element|
#   company_data = extract_company_data(element)
#   companies << company_data
# end

# companies.each do |company|
#   url = "https://www.ycombinator.com#{company[:title].downcase.gsub(' ', '-')}"
#   additional_data = extract_additional_data(url)
#   company.merge!(additional_data)
# end

# workbook = Spreadsheet::Workbook.new
# worksheet = workbook.create_worksheet(name: 'Data')

# worksheet.row(0).concat(['Name', 'Address', 'Description', 'Image Link', 'Website', 'LinkedIn URL', 'Founding Year'])

# companies.each_with_index do |company, row|
#   worksheet.row(row + 1).concat([
#     company[:title],
#     company[:address],
#     company[:description],
#     company[:image],
#     company[:website],
#     company[:linkedin_url],
#     company[:founded_in]
#   ])
# end

# file_name = 'company_data.xls'
# workbook.write(file_name)
# puts "Excel file saved as #{file_name}"

