--------------------------------------------------------------------------------------------------------------------
----------------------- Invite Plugin Created By @To_My_Amigos -----------------------------------------------------
--------------------------------------------------------------------------------------------------------------------

function resolve_username(username,cb)
  tdcli_function ({
    ID = "SearchPublicChat",
    username_ = username
  }, cb, nil)
end
--------------------------------------------------------------------------------------------------------------------
function getMessage(chat_id, message_id,cb)
  tdcli_function ({
    ID = "GetMessage",
    chat_id_ = chat_id,
    message_id_ = message_id
  }, cb, nil)
end
---------------------------------------------------------------------------------------------------------------------
function from_username(msg)
  function gfrom_user(extra,result,success)
    if result.username_ then
      F = result.username_
    else
      F = 'nil'
    end
    return F
  end
  local username = getUser(msg.sender_user_id_,gfrom_user)
  return username
end
--Start Function
local function run(msg, matches)
  if matches[1] == "invite" and matches[2] and is_owner(msg) then
if string.match(matches[2], '^%d+$') then
tdcli.addChatMember(msg.to.id, matches[2], 0)
end
end
--------------------------Username--------------------------------------------------------------------------------------
if matches[1] == "invite" and matches[2] and is_owner(msg) then
if string.match(matches[2], '^.*$') then
function invite_by_username(extra, result, success)
if result.id_ then
tdcli.addChatMember(msg.to.id, result.id_, 5)
end
end
resolve_username(matches[2],invite_by_username)
end
end
--------------------------Reply-----------------------------------------------------------------------------------------
if matches[1] == "invite" and msg.reply_to_message_id_ ~= 0 and is_owner(msg) then
function inv_reply(extra, result, success)
tdcli.addChatMember(msg.to.id, result.sender_user_id_, 5)
end
getMessage(msg.chat_id_, msg.reply_to_message_id_,inv_reply)
end
end
--End
return {
patterns = { 
"^[!#/](invite)$", 
"^[!#/](invite) @(.*)$",
"^[!#/](invite) (.*)$",},
run =run,}

-- @To_My_Amigos