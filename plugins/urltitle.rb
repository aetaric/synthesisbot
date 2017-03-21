require 'cinch'
require 'uri'
require 'rubygems'
require 'nokogiri'
require 'open-uri'

class UrlTitle
  include Cinch::Plugin
  match /(.*http.*)/, use_prefix: false, method: :title_it

  def title_it m, message
    URI.extract(message, ["http", "https"]) do |uri|
      begin
        io = open(uri)                    # open-uri follows server redirects
        url = io.base_uri.to_s            # Save the final url
        url_match = Regexp.new "#{uri}/?"
        m.reply "Followed URL: %s" % url if url !~ url_match
      rescue
        m.reply "Couldn't resolve url"
        puts $!, $@
      end
      begin
        html = io.read                    # Get dat body text
        page = Nokogiri::HTML(html)       # Parse the raw html with Nokogiri
        title = page.css("title")[0].text # Get dat title text
        m.reply "Title: %s" % title
      rescue
        m.reply "Couldn't get title"
        puts $!, $@
      end
    end
  end
end
