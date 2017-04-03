require 'cinch'
require 'active_support'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  match /follow (.+)/, method: :follow
  match /mod (.+)/, method: :mod
  match /addmember (.+)/, method: :addmember
  match /hostmode (.+)/, method: :hostmode
  match /viewers resubscribed while you were away/, method: :processlive

  def follow(m, plug)
    if permission_check(m, 20)
      3.times { m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !" }
    end
  end

  def mod(m, user)
    if permission_check_provision(m, 40, 20)
      # implement mod permissions here
    end
  end

  def addmember(m, user)
    if permission_check_provision(m, 60, 40)
      # implement team memeber addition here
    end
  end

  def hostmode(m, user)
    if permission_check(m, 40)
      # implement team hosting mode here
    end
  end

  def processlive(m)
    if m.user == "twitchnotify"
      $host_chans.push m.channel
    end
  end
end
