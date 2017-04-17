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

end
