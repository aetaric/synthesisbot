require 'cinch'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class CustomCommand
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :connect, :method => :setup

  match /^!(\w+)/i, use_prefix: false, method: :custom
  match /addcomm (\w+) (\w+)/, method: :add_custom
  match /updatecomm (\w+) (\w+)/, method: :update_custom

  def setup(*)
    @collection = $mongo[:commands]
  end

  def custom(m, command)
    results = @collection.find(channel: m.channel.name, command: command)
    if results.any?
      m.reply "@#{m.user.name}, #{results.first.message}"
    end
  end

  def add_custom(m, command, message)
    if mod? m
      if !command.nil? && !message.nil?
        @collection.insert( { :channel => m.channel.name, :command => command, :message => message } )
      end
    end
  end

  def update_custom(m, command, message)
    if mod? m
      if !command.nil? && !message.nil?
        @colletion.update( { :channel => m.channel.name, :command => command }, 
                           { :channel => m.channel.name, :command => command, :message => message } )
      end
    end
  end
end
