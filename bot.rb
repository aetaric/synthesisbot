#!/usr/bin/ruby

# Load '.'
$LOAD_PATH.unshift(File.expand_path(File.dirname(__FILE__))) unless $LOAD_PATH.include?(File.expand_path(File.dirname(__FILE__)))

# require Cinch IRCBot Framwork
require 'cinch'

# require activesupport for various Rails like magics
require 'active_support'

# add Inflector methods and overrides.
include ActiveSupport::Inflector

# load libs
Dir["./lib/*.rb"].each {|file| load file}

# load custom cinch plugins
Dir["./plugins/*.rb"].each {|file| load file}

$brain = Brain.new
$host_chans = []

if !$brain.config
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
  twitchcreds = {}
  print "Client ID: "
  twitchcreds["client"] = gets.chomp
  print "Client Secret: "
  twitchcreds["secret"] = gets.chomp
  $brain.twitchcreds = twitchcreds

  system("clear")
  puts "Initial config complete... SAVING!"
  $brain.save
  $brain.reload
end

channels = []
$brain.channels.each do |chan|
  channels.push chan["name"]
end

plugins = []
$brain.plugins.each do |plugin|
  plugins.push constantize(plugin)
end



@bot = Cinch::Bot.new do
  configure do |c|
    c.nick = $brain.bot["nick"]
    c.server = $brain.bot["server"]
    c.port = $brain.bot["port"]
    c.ssl.use = $brain.bot["ssl"]
    c.ssl.verify = $brain.bot["ssl_verify"]
    c.password = $brain.bot["password"]
    c.channels = channels
    c.caps = [:"twitch.tv/membership", :"twitch.tv/commands"]
    c.plugins.options[Cinch::Logging] = {
      :logfile => "/tmp/public.log", # required
      :timeformat => "%H:M",
      :format => "<%{time}> %{nick}: %{msg}",
      :midnight_message => "=== New day: %Y-%m-%d ==="
    }
    c.plugins.plugins = plugins
  end

  on :invite do |m|
    if permission_check(m, 20)
      @bot.join(m.channel)
      $brain.channels.push m.channel
    end
  end

  on :notice do |m|
    # implement now hosting handling here
  end

  on :hosttarget do |m|
    # implement hosttarget tracking and redirection here
  end
  
end

$plugin_list = Cinch::PluginList.new @bot
@bot.start
