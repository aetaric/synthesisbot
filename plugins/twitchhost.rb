require 'cinch'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class TwitchHost
  include Cinch::Plugin
  include ActiveSupport::Inflector

  match /viewers resubscribed while you were away/, method: :process_live

  listen_to :hosttarget, :method => :update_host
  listen_to :notice, :method => :target_offline
  listen_to :connect, :method => :pull_team

  timer 3600, method: :pull_team

  def process_live(m)
    if !$live_chans.include? chan_to_user(m)
      $live_chans.push chan_to_user(m)
      pull_team
    end
  end
  
  def update_host(m)
    split_msg = m.message.split(" ")
    target = split_msg[0]
    if target != "-"
      $live_chans.delete chan_to_user(m)
    end
  end

  def target_offline(m)
    if /has gone offline. Exiting host mode./.match m.message
      if !$host_chans.include chan_to_user(m)
        $host_chans.push chan_to_user(m)
      end
    end
  end

  def pull_team(m=nil)
    url = "https://api.twitch.tv/kraken/teams/" + $brain.twitch["team"].to_s
    uri = URI.parse(url)
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
      puts output
      if !output.nil?
        output["users"].each do |user|
          exist = false

          $team_chans.each do |chan|
            if user["name"] == chan["name"]
              exist = true
            end
          end

          if !exist
            u = {}
            u["id"] = user["_id"]
            u["game"] = user["game"]
            u["name"] = user["name"]
            $team_chans.push u

            chan = "#" +user["name"].to_s
            Channel(chan).join
          end
        end
      end
    end
    pull_live
  end

  def pull_live
    ids = []
    $team_chans.each do |chan|
      ids.push chan["id"]
    end
    
    url = "https://api.twitch.tv/kraken/streams/?channel=" + ids.join(",")
    uri = URI.parse(url)
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
      if !output.nil?
        output["users"].each do |user|
          if !$live_chans.include? user["name"]
            $live_chans.push user["name"]
          end
        end
        force_host
      end
    end
  end

  def force_host
    target = $live_chans.shuffle.pop
    message = ".host " + target
    $host_chans.each do |chan|
      chan.send message
    end
  end
end
