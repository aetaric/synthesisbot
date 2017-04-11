require 'cinch'
require 'cinch/cooldown'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  enforce_cooldown

  match /follow (.+)/, method: :follow
  match /source/, method: :source
  match /viewers resubscribed while you were away/, method: :processlive
  match /host (.+)/, method: :host

  timer 120, method: :pull_team

  def follow(m, plug)
    if mod?(m) 
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def source(m)
    m.reply ".w #{m.user} I'm written in Ruby and my developer accepts pull reqs that resolve active issues or feature requests."
    m.reply ".w #{m.user} You can find my source code here: https://github.com/aetaric/aetbot ."
  end

  def processlive(m)
    if m.user == "twitchnotify"
      $live_chans.push m.channel
    end
  end

  def host(m, target)
    if mod?(m)
      m.reply ".host #{target}"
    end
  end

  def pull_team
    uri = URI.parse("https://api.twitch.tv/kraken/teams/" + $brain.twitch["team"])
    request = Net::HTTP::Get.new(uri)
    request["Accept"] = "application/vnd.twitchtv.v5+json"
    request["Client-Id"] = $brain.twitch["client"]

    req_options = {
      use_ssl: uri.scheme == "https",
    }

    response = Net::HTTP.start(uri.hostname, uri.port, req_options) do |http|
      http.request(request)
    end

    if response.code == 200
      output = JSON.load(response.body)
      @bot.warn output
      if !output.nil?
        output["users"].each do |user|
          u = {}
          u["id"] = user["_id"]
          u["game"] = user["game"]
          u["name"] = user["name"]
          $team_chans.push u
        end
      end
    end
  end
end
