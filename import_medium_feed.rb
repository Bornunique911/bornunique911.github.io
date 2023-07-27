require "jekyll-import"
require "open-uri"
require "nokogiri"
require "date"
require "fileutils"

def create_post(title, content, date, slug, tags)
  content = <<~EOS
    ---
    layout: post
    title: "#{title}"
    date: #{date}
    tags: #{tags}
    ---
    #{content}
  EOS

  filename = "#{date}-#{slug}.html"
  File.open("_posts/#{filename}", "w") { |file| file.write(content) }
end

rss_feed_url = "https://medium.com/feed/@bornunique911"
rss_content = URI.open(rss_feed_url).read
rss = Nokogiri::XML(rss_content)

items = rss.xpath("//item")

items.each do |item|
  title = item.at_xpath("title").text
  link = item.at_xpath("link").text
  content = item.at_xpath("content:encoded").text # Use "content:encoded" for Medium RSS feeds
  date = Date.parse(item.at_xpath("pubDate").text).strftime("%Y-%m-%d")
  slug = link.split("/").last.split("?").first # Extracting slug from the link and removing the query parameters
  tags = item.xpath("category").map { |tag| tag.text }.join(", ") # Assuming tags are available as "category" in the RSS feed

  # Call the method to create the Jekyll post
  create_post(title, content, date, slug, tags)
end
