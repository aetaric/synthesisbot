def chan_to_user(m)
  len = m.channel.to_s.length
  return m.channel.name.slice(1,len).to_s
end
