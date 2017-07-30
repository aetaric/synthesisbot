require 'cinch'
require 'cinch/cooldown'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class CustomCommand
  include Cinch::Plugin
  include ActiveSupport::Inflector

  enforce_cooldown

  listen_to :connect, :method => :setup

  match /^!(\w+)\s?@?(\w+)?/i, use_prefix: false, method: :custom
  match /addcomm (\w+)([a-zA-Z0-9\w\W ]*)/, method: :add_custom
  match /updatecomm (\w+) ([a-zA-Z0-9\w\W ]*)/, method: :update_custom
  match /deletecomm (\w+)/, method: :delete_custom

  def setup(*)
    @collection = $mongo[:commands]
  end

  def custom(m, command, target=nil)
    results = @collection.find(channel: m.channel.name, command: command)
    if results.any?
      if target == nil
        m.reply "@#{m.user.name}, #{results.first["message"]}"
      else
        m.reply "@#{target}, #{results.first["message"]}"
      end
    end
  end

  def add_custom(m, command, message)
    if mod? m
      if !command.nil? && !message.nil?
        @collection.insert_one( { :channel => m.channel.name, :command => command, :message => message } )
        m.reply "@#{m.user.name}, Added command: #{command}"
      end
    end
  end

  def update_custom(m, command, message)
    if mod? m
      if !command.nil? && !message.nil?
        @collection.update_one( { :channel => m.channel.name, :command => command }, 
                           { :channel => m.channel.name, :command => command, :message => message } )
        m.reply "@#{m.user.name}, Updated command: #{command}"
      end
    end
  end

  def delete_custom(m, command)
    if mod? m
      if !command.nil?
        @collection.delete_one( { :channel => m.channel.name, :command => command } )
        m.reply "@#{m.user.name}, Deleted Command: #{command}"
      end
    end
  end
end
