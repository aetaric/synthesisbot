class TwitchMod
  include Cinch::Plugin

  listen_to :channel, :method => :upsert_mod

  def upsert_mod(m)
    if m.tags["mod"].to_i === 1
      @collection = $mongo[:mods]
      user = @collection.find(nick: m.user.name)
      if user.any?
        if !user.first[:channels].include? m.channel.name
          channels = user.first[:channels]
          channels.push m.channel.name

          @collection.find_one_and_replace(
          { :nick => m.user.name },
          { :nick => m.user.name,
            :channels => channels})
        end
      else
        @collection.insert_one(
        { :nick => m.user.name,
          :channels => [ m.channel.name ] })
      end
    end
  end

end
