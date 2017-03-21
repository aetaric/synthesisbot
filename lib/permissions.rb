def permission_check_provision(m, permission_required, permission_requested)
  command_user = m.user.nick
  user_not_found = true

  $brain.users.each do |user|
    if user["nick"] == command_user
      user_not_found = false
      if user["permission"] > permission_required
        if user["permission"] <= permission_requested
          return true
        else
          return false
        end
      else
        m.reply "You don't have permission to do that!"
        return false
      end
    end
  end
  if user_not_found == true
    m.reply "You are not my master!"
    return false
  end
end

def permission_check(m, permission_required)
  command_user = m.user.nick
  user_not_found = true

  $brain.users.each do |user|
    if user["nick"] == command_user
      user_not_found = false
      if user["permission"] > permission_required
        return true
      else
        m.reply "You don't have permission to do that!"
        return false
      end
    end
  end
  if user_not_found == true
    m.reply "You are not my master!"
    return false
  end
end
