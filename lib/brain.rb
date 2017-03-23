# require Redis for brain
require 'redis'
require 'json'
require 'active_support'

class Brain
  attr_accessor :users, :channels, :password, :plugins, :bot, :config
  
  def initialize
    @redis = Redis.new :db => 1
    @bot = JSON.load(@redis.get("bot"))
    @users = JSON.load(@redis.get("users"))
    @plugins = JSON.load(@redis.get("plugins"))
    @channels = JSON.load(@redis.get("channels"))
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
      @redis.set "config", 1
    end
  end

  def reload
    @redis = Redis.new :db => 1
    @bot = JSON.load(@redis.get("bot"))
    @users = JSON.load(@redis.get("users"))
    @plugins = JSON.load(@redis.get("plugins"))
    @channels = JSON.load(@redis.get("channels"))
    @config = true
  end
end
