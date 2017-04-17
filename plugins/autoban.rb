require 'cinch'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class AutoBan
  include Cinch::Plugin
  include ActiveSupport::Inflector

  match /wbt.link/, use_prefix: false, method: :elena

  def elena(m)
    if /SEX/.match(m.message)
      if /elena/.match(m.user.nick)
        m.reply ".ban #{m.user.nick}"
      end
    end
  end

end
