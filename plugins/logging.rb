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

  def log_public_message(msg)
    time = Time.now
    if !msg.user.nil?
      @collection.insert_one( { :time => time, :type => "Chat", :nick => msg.user.name, :channel => msg.channel.name, :msg => msg.message, :tags => msg.tags } )
    else
      @collection.insert_one( { :time => time, :type => "Chat", :nick => nil, :channel => msg.channel.name, :msg => msg.message, :tags => msg.tags } )
    end
  end

  def log_notice(msg)
    time = Time.now
    if !msg.channel.nil?
      @collection.insert_one( { :time => time, :type => "Notice", :nick => "system (Notice)", :channel => msg.channel.name, :msg => msg.message, :tags => msg.tags } )
    else
      @collection.insert_one( { :time => time, :type => "Notice", :nick => "system (Notice)", :channel => nil, :msg => msg.message, :tags => msg.tags } )
    end
  end

  def log_roomstate(msg)
    time = Time.now
    @collection.insert_one( { :time => time, :type => "RoomState", :nick => "System (RoomState)", :channel => msg.channel.name, :msg => "Room state changed!", :tags => msg.tags } )
  end

  def log_hosttarget(msg)
    time = Time.now
    @collection.insert_one( { :time => time, :type => "HostTarget", :nick => "System (HostTarget)", :channel => msg.channel.name, :msg => msg.message, :tags => msg.tags } )
  end

  def log_clearchat(msg)
    time = Time.now
    @collection.insert_one( { :time => time, :type => "ClearChat", :nick => msg.message, :channel => msg.channel.name, :msg => "User Purge/Timeout/Ban", :tags => msg.tags } )
  end

  def log_usernotice(msg)
    time = Time.now
    @collection.insert_one( { :time => time, :type => "UserNotice", :nick => msg.tags["display-name"], :channel => msg.channel.name, :msg => msg.message, :tags => msg.tags } )
  end

end
