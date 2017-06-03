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
  match /host (.+)/, method: :host
  match /synthesis/, method: :synthesis
  match /commands/, methods: :commands

  def follow(m, plug)
    if mod?(m) 
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def source(m)
    m.reply ".w #{m.user} I'm written in Ruby and my developer accepts pull reqs that resolve active issues or feature requests."
    m.reply ".w #{m.user} You can find my source code here: https://github.com/aetaric/aetbot ."
  end

  def host(m, target)
    if mod?(m)
      m.reply ".host #{target}"
    end
  end

  def synthesis(m)
    # m.reply "SOMETHING"
  end

  def commands(m)
    if mod?(m)
      m.reply ".w #{m.user} My Commands are here: https://gist.githubusercontent.com/aetaric/df04e55c159baabafc2194f8516715fc/raw/e77e5db52718db1ca48cea64f3ccdb3c1c59e13f/gistfile1.txt"
    end
  end
end
