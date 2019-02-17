require "arachnid2"
require "nokogiri"

url = "https://en.wikipedia.org/wiki/FC_Bayern_Munich"
spider = Arachnid2.new(url)
responses = []
doc_dir = "docs"

spider.crawl { |response|
  responses << Nokogiri::HTML(response.body)
  print '*'
}

responses.each_with_index do |response, index|
  response_directory_name = "response_#{index}"
  response.elements.each_with_index do |element, i|
    element_directory_name = "element_#{index}"
    path = [doc_dir, response_directory_name, element_directory_name].join('/')
    # Dir.mkdir(path) unless Dir.exists?(path)
    FileUtils.mkdir_p(path)
    element.search("//style|//script").remove
    # write all links to file
    links = element.xpath('//a').map {|element| element["href"]}.compact.select{ |str| str.start_with?("https") }
    File.open([path, "links.txt"].join("/"), "w") {|file| file.puts(links)}

    # write text content
    File.open([path, "content.txt"].join("/"), "w") {|file| file.puts(element.content)}
  end
end