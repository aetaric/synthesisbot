class Cinch::Logging
  include Cinch::Plugin

  listen_to :connect,    :method => :setup
  listen_to :disconnect, :method => :cleanup
  listen_to :channel,    :method => :log_public_message
  listen_to :notice,     :method => :log_notice
  listen_to :roomstate,  :method => :log_roomstate
  listen_to :hosttarget, :method => :log_hosttarget
  listen_to :clearchat,  :method => :log_clearchat
  listen_to :usernotice, :method => :log_usernotice

  def setup(*)
    @collection = $mongo[:logs]
  end

  def log_message(type, nick, channel, message, tags)
      time = Time.now
      @collection.insert_one( { :time => time, :type => type, :nick => nick, :channel => channel, :msg => message, :tags => tags } )
  end

  def log_public_message(msg)
    if !msg.user.nil?
      log_message "Chat", msg.user.name, msg.channel.name, msg.message, msg.tags
    else
      log_message "Chat", nil, msg.channel.name, msg.message, msg.tags
    end
  end

  def log_notice(msg)
    if !msg.channel.nil?
      log_message "Notice", "system (Notice)", msg.channel.name, msg.message, msg.tags
    else
      log_message "Notice", "system (Notice)", nil, msg.message, msg.tags
    end
  end

  def log_roomstate(msg)
    log_message "RoomState", "System (RoomState)", msg.channel.name, "Room state changed!", msg.tags
  end

  def log_hosttarget(msg)
    log_message "HostTarget", "System (HostTarget)", msg.channel.name, msg.message, msg.tags
  end

  def log_clearchat(msg)
    log_message "ClearChat", msg.message, msg.channel.name, "User Purge/Timeout/Ban", msg.tags
  end

  def log_usernotice(msg)
    log_message "UserNotice", msg.tags["display-name"], msg.channel.name, msg.message, msg.tags
  end

end
