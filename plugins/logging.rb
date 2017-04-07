class Cinch::Logging
  include Cinch::Plugin

  set :required_options, [:logfile]

  listen_to :connect,    :method => :setup
  listen_to :disconnect, :method => :cleanup
  listen_to :channel,    :method => :log_public_message
  timer 60,              :method => :check_midnight

  def setup(*)
    @logfile          = File.open(config[:logfile], "a")
    @timeformat       = config[:timeformat]       || "%H:%M"
    @logformat        = config[:format]           || "<%{time}> %{nick}: %{msg}"
    @midnight_message = config[:midnight_message] || "=== The dawn of a new day: %Y-%m-%d ==="
    @last_time_check  = Time.now

    bot.debug("Opened message logfile at #{config[:logfile]}")
  end

  def cleanup(*)
    @logfile.close
    bot.debug("Closed message logfile.")
  end

  def check_midnight
    time = Time.now
    @logfile.puts(time.strftime(@midnight_message)) if time.day != @last_time_check.day
    @last_time_check = time
  end

  def log_public_message(msg)
    time = Time.now.strftime(@timeformat)
    if !msg.user.nil?
      @logfile.puts(sprintf(@logformat,
                            :time => time,
                            :nick => msg.user.name,
                            :msg  => msg.message))
    else
      @logfile.puts(sprintf(@logformat,
                            :time => time,
                            :nick => nil,
                            :msg  => msg.message))
    end
  end

end
