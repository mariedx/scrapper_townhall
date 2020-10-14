require 'nokogiri'
require 'open-uri'
require 'google_drive'
require 'csv'

class Scrapper
  attr_accessor :array_final

  def initialize
    @array_final = perform
  end

  valedoise = Nokogiri::HTML(URI.open("https://www.annuaire-des-mairies.com/val-d-oise.html"))

  def get_townhall_urls(valedoise)
    array_cities = []
    valedoise_cities = valedoise.xpath('//a[contains(@href, "./95/")]')
    valedoise_cities.each do |cities|
      array_cities << "http://annuaire-des-mairies.com#{cities['href'][1..-1]}"
    end
    array_cities
  end

  def get_townhall_email(valedoise)
    array_emails = []
    get_townhall_urls(valedoise).each do |url|
      array_emails << Nokogiri::HTML(URI.open(url)).xpath('/html/body/div/main/section[2]/div/table/tbody/tr[4]/td[2]').text
    end
    array_emails
  end

  def towns_names(valedoise)
    array_cities = []
    valedoise_cities = valedoise.xpath('//a[contains(@href, "./95/")]')
    valedoise_cities.each do |cities|
      array_cities << cities.text
    end
    array_cities
  end

  def hash_1(valedoise)
    hash_towns = Hash[towns_names(valedoise).zip(get_townhall_email(valedoise))]

    array_final = []
    hash_towns.each do |cities, emails|
      array_final << {cities => emails}
    end
    array_final
  end

  def perform 
    valedoise = Nokogiri::HTML(URI.open("https://www.annuaire-des-mairies.com/val-d-oise.html"))
    get_townhall_urls(valedoise)
    get_townhall_email(valedoise)
    towns_names(valedoise)
    hash_1(valedoise)
  end

  def save_as_JSON
    File.open("db/email.json","w") do |f|
      f.write(@array_final.to_json)
    end
  end

  def save_as_Google
    session = GoogleDrive::Session.from_config("config.json")
    ws = session.spreadsheet_by_key("10E-0tiZFlJ-FDfzhZhIBpkPJR3rTg4qMBs-rmkIs2Ko").worksheets[0]
    @array_final.each_with_index do |row, i|
      ws[i+1, 1] = row.keys[0]
      ws[i+1, 2] = row.values[0]
    end
    ws.save
  end 

  def save_as_csv
    CSV.open("db/emails.csv", "w") do |csv|
      csv << @array_final
    end
  end
end 




