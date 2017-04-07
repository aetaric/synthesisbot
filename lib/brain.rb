# require Redis for brain
require 'redis'
require 'json'
require 'active_support'

class Brain
  attr_accessor :users, :channels, :plugins, :bot, :config, :twitch
  
  def initialize
    @redis = Redis.new :db => 1
    @bot = JSON.load(@redis.get("bot"))
    @users = JSON.load(@redis.get("users"))
    @plugins = JSON.load(@redis.get("plugins"))
    @channels = JSON.load(@redis.get("channels"))
    @twitch = JSON.load(@redis.get("twitch"))
    if @redis.get "config"
      if @redis.get("config").to_i == 1
        @config = true
      else
        @config = false
      end
    end
  end

  def save
    @redis.pipelined do
      @redis.set "bot", @bot.to_json
      @redis.set "users", @users.to_json
      @redis.set "plugins", @plugins.to_json
      @redis.set "channels", @channels.to_json
      @redis.set "twitch", @twitch.to_json
      @redis.set "config", 1
    end
  end

  def reload
    @redis = Redis.new :db => 1
    @bot = JSON.load(@redis.get("bot"))
    @users = JSON.load(@redis.get("users"))
    @plugins = JSON.load(@redis.get("plugins"))
    @channels = JSON.load(@redis.get("channels"))
    @twitch = JSON.load(@redis.get("twitch"))
    @config = true
  end

  def setup
    system "clear"
    puts "Configuring Bot Info..."
    puts ""
    bot = {}
    print "Bot Nickname: "
    bot["nick"] = gets.chomp
    print "IRC Server: "
    bot["server"] = gets.chomp
    print "IRC Port: "
    bot["port"] = gets.chomp.to_i

    print "Use SSL?[Y/n] "
    response = gets.chomp.downcase
    if response === "y"
      bot["ssl"] = true
    elsif response === "n"
      bot["ssl"] = false
    else
      bot["ssl"] = true
    end

    print "Verify SSL?[y/N] "
    response = gets.chomp.downcase
    if response === "y"
      bot["ssl_verify"] = true
    elsif response === "n"
      bot["ssl_verify"] = false
    else
      bot["ssl_verify"] = false
    end
    
    print "Server Password?[default is none] "
    response = gets.chomp
    if response === ""
      bot["password"] = gets.chomp
    else
      bot["password"] = ""
    end

    $brain.bot = bot
    puts "Bot Info configured..."
    sleep 1

    puts "Configuring Admin User..."
    users = []
    user = {:permission => 75}
    print "Enter nickname of Bot Owner: "
    user["nick"] = gets.chomp
    print "Enter ident(sso) of Bot Owner: "
    user["ident"] = gets.chomp
    users.push user
    $brain.users = users
    puts "Admin User configured..."
    sleep 1

    puts "Configuring Initial Channel..."
    chans = []
    channel = {}
    print "Channel name: "
    channel["name"] = gets.chomp
    chans.push channel
    $brain.channels = chans
    puts "Initial Channel configured..."
    sleep 1

    puts "Setting plugins to defaults..."
    plugins = [constantize("CommandPlugin"), constantize("Cinch::Logging"), constantize("Twitch")]
    $brain.plugins = plugins

    puts "Configuring Twitch Credentials..."
    twitch = {}
    print "Client ID: "
    twitch["client"] = gets.chomp
    print "Client Secret: "
    twitch["secret"] = gets.chomp
    print "Twitch Team: "
    twitch["team"] = gets.chomp
    $brain.twitch = twitch

    system("clear")
    puts "Initial config complete... SAVING!"
    $brain.save
    $brain.reload
  end
end
