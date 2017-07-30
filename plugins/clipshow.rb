require 'cinch'
require 'active_support'
require 'json'
require 'net/http'
require 'uri'

class ClipShow
  include Cinch::Plugin
  include ActiveSupport::Inflector

  listen_to :channel, :method => :vote

  match /startclipshow/, method: :startClipShow
  match /endclipshow/, method: :endClipShow
  match /startvote/, method: :startVote
  match /endvote/, method: :endVote

  def startClipShow(m)
    if m.channel.name == "#geoff"
      if mod?(m)
        m.reply "Yo Chat, It's the Clip Show!"
        sleep 2
        m.reply "The rules are simple. Geoff will play a clip and then once Geoff or a mod uses !startvote enter a number between 1-10 where 1 is \"This is the worse clip\" and 10 is \"I've never seen something so funny\""
        sleep 2
        m.reply "Votes can be whole numbers or halves (1 ,1.5 ,2 ,etc), and FYI, I'll remember only your first vote (for now)!"
        sleep 2
        m.reply "Once the clip has played a few times a mod will use !stopvote which will then tally up the votes and provide the average to determine the outcome!"
        sleep 2
        m.reply "With that out of the way, LET'S WATCH THE FIRST CLIP!"
        $clipshow = true
      end
    end
  end

  def endClipShow(m)
    if m.channel.name == "#geoff"
      if mod?(m)
        m.reply "That's it! Show's over! You don't have to go home, but you can't stay here!"
        $clipshow = false
      end
    end
  end

  def vote(m)
    if m.channel.name == "#geoff"
      if $voting == true
        if /(10|[1-9]|0[1-9])/.match(m.message)
          result = false
          $results.each do |r|
            if r["username"] == m.user.name
              result = true
            end
          end
          if result == false
            u = {}
            u.username = m.user.name
            u.vote = /(10|[1-9]|0[1-9])/.match(m.message)[1].to_f
            $results.push u
          end
        end
      end
    end
  end

  def startVote(m)
    if m.channel.name == "#geoff"
      if mod?(m)
        $voting = true
        m.reply "That's some clip! Start casting your votes now!"
      end
    end
  end

  def endVote(m)
    if m.channel.name == "#geoff"
      if mod?(m)
        $voting = false
        m.reply "Voting is over!"
        result = 0.0
        $results.each do |r|
          result += r["vote"].to_f
        end
        m.reply "The clip scored #{result / $results.length} with chat!"
        $results.clear
      end
    end
  end

end
