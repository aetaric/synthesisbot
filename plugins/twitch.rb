require 'cinch'
require 'active_support'

class Twitch
  include Cinch::Plugin
  include ActiveSupport::Inflector

  match /^!follow (.+)/, use_prefix: false, method: :follow

  def follow(m, plug)
    if m.user.is_op?
      3.times
        m.reply "Hey Chat! You should follow https://www.twitch.tv/#{plug} !"
      end
    end
  end
end
