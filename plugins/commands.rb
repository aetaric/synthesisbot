require 'cinch'
require 'active_support'

class CommandPlugin
  include Cinch::Plugin
  include ActiveSupport::Inflector

  # Bot management commands
  match /^!die/, use_prefix: false, method: :kill_bot
  match /^!reload/, use_prefix: false, method: :reload_bot
  match /^!save/, use_prefix: false, method: :save_bot
  match /^!adduser (.+) (\d{1,2})/, use_prefix: false, method: :add_user
  match /^!chuser (.+) (\d{1,2})/, use_prefix: false, method: :ch_user
  match /^!rmuser (.+)/, use_prefix: false, method: :rm_user

  # Plugin management commands
  match /^!unload (.+)/, use_prefix: false, method: :unload_plugin
  match /^!load (.+)/, use_prefix: false, method: :load_plugin

  def load_plugin(m, plugin)
    if permission_check(m, 60)
      if plugin != "CommandPlugin"
        begin
          plugin_list.register_plugin(constantize(plugin))
          $brain.plugins.push plugin
          m.reply "Plugin \"%s\" loaded!" % [plugin]
        rescue NameError
          "No such plugin \"%s\". Check Your spelling and case and try again." % [plugin]
        end
      else
        m.reply "You cannot alter this plugin! It's where this command lives!"
      end
    end
  end

  def unload_plugin(m, plugin)
    if permission_check(m, 60)
      if plugin != "CommandPlugin"
        $plugin_list.unregister_plugin(constantize(plugin))
        $brain.plugins.delete plugin
        m.reply "Plugin \"%s\" unloaded!" % [plugin]
      else
        m.reply "You cannot alter this plugin! It's where this command lives!"
      end
    end
  end

  def rm_user(m, nick)
    if permission_check(m, 70)
      $brain.users.each do |user,index|
        if user["nick"] == nick
          $brain.users.slice index
          $brain.save
        end
      end
    end
  end

  def ch_user(m, nick, permission)
    if permission_check_provision(m, 65, permission)
      $brain.users.each do |user,index|
        if user["nick"] == nick
          $brain.users[index]["permission"] = permission
          $brain.save
        end
      end
    end
  end

  def add_user(m, nick, permission)
    if permission_check_provision(m, 65, permission)
      user_hash = {}
      user = User(nick)
      user_hash["nick"] = user.nick
      user_hash["ident"] = user.user
      user_hash["permission"] = permission

      $brain.users.push user_hash
      $brain.save
    end
  end

  def reload_bot(m)
    if permission_check(m, 45)
      m.reply "Reloading Brain from Redis!"
      $brain.reload
    end
  end

  def save_bot(m)
    if permission_check(m,45)
      $brain.save
      m.reply "Saving Brain to Redis!"
    end
  end

  def kill_bot(m)
    if permission_check(m,65)
      m.reply "Good bye cruel world!"
      $brain.save
      @bot.exit
    end
  end

end
