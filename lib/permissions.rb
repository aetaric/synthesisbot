def permission_check_provision(m, permission_required, permission_requested)
  command_user = m.user.nick.downcase
  user_not_found = true

  $brain.users.each do |user|
    if user["nick"].downcase == command_user
      user_not_found = false
      if user["permission"].to_i > permission_required.to_i
        if user["permission"].to_i >= permission_requested.to_i
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
    return false
  end
end

def permission_check(m, permission_required)
  command_user = m.user.nick.downcase
  user_not_found = true

  $brain.users.each do |user|
    if user["nick"].downcase == command_user
      user_not_found = false
      if user["permission"].to_i > permission_required
        return true
      else
        m.reply "You don't have permission to do that!"
        return false
      end
    end
  end
  if user_not_found == true
    return false
  end
end
