# frozen_string_literal: true

require "arachnid2"

URL = "http://barcelonaconventionbureau.com/"
SPIDER = Arachnid2.new(URL)
MAX_URLS = 1000
DOCS_DIR = "docs/raw/"

# documents crawling
responses = []

puts "Start crawling..."

SPIDER.crawl(max_urls: MAX_URLS) { |response| responses << response }

puts "#{responses.size} docs crawled. Docs directory: #{DOCS_DIR}"

# documents links storing
links = responses.map(&:effective_url)
File.open("index.txt", "w") { |f| f.puts links }

# creation of directory for downloaded docs
Dir.mkdir DOCS_DIR unless File.exist? DOCS_DIR

# docs content retrieving and storing
responses.each.with_index(1) do |response, index|
  html_doc = Nokogiri::HTML(response.body)
  html_doc.search("//style|//script").remove

  inner_contents = html_doc.xpath("//text()").map do |content|
    content.text.scan(/[A-Za-z]+/i)
  end

  File.open("#{DOCS_DIR}#{index}.txt", "w") do |f|
    f.puts inner_contents.reject(&:empty?).join(" ")
  end
end