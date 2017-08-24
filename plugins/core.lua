local function openChat(chat_id, cb)
  tdcli_function ({
    ID = "OpenChat",
    chat_id_ = chat_id
  }, cb or dl_cb, nil)
end

function ByRoO(msg, matches) 
redis:incr("allmsg")
if msg.chat_id_ then
local id = tostring(msg.chat_id_)
if id:match('-100(%d+)') then
if not redis:sismember("su",msg.chat_id_) then
redis:sadd("su",msg.chat_id_)
end
elseif id:match('-(%d+)') then
if not redis:sismember("gp",msg.chat_id_) then
redis:sadd("gp",msg.chat_id_)
end
elseif id:match('') then
if not redis:sismember("user",msg.chat_id_) then
redis:sadd("user",msg.chat_id_)
end
end
end
if matches[1] == 'stats' and is_sudo(msg) then
-------------------------------------------------
local allmsg = redis:get("allmsg")
-------------------------------------------------
local gps = redis:scard("su")
-------------------------------------------------
local gp = redis:scard("gp")
-------------------------------------------------
local user = redis:scard("user")
-------------------------------------------------
       return '>گزارش ربات: \n\n> تمام پیام های دریافتی : '..allmsg..'\n\n> تعداد سوپر گروه ها : '..gps..'\n\n> تعداد گروه ها : '..gp..'\n\n> کاربران پیوی: '..user..'\n'
end
if matches[1] == 'reset' and is_sudo(msg) then
redis:del("allmsg")
redis:del("su")
redis:del("gp")
redis:del("user")
return "has been reset"
end
if matches[1] == "open" and is_sudo(msg) then 
  local text = matches[2]
  tdcli.openChat(text)
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1,"*Done!\nGroup* `"..text.."` *has Been Reloaded*", 1, 'md')     
end
if matches[1] == "openchat" and is_sudo(msg) then 
local chat = redis:smembers('su')
  for i=1, #chat do
  tdcli.openChat(chat[i])
  end
  tdcli.sendMessage(msg.chat_id_, msg.id_, 1,"*Reloaded Chat*", 1, 'md')     
end
if msg.to.type ~= "pv" then
	tdcli.openChat(msg.chat_id_, dl_cb, nil)
	tdcli.sendChatAction(bot.id, 'Typing', 100, dl_cb, nil)
end
 end
 
 return { 
  patterns = {
  "^[!/#](open) (.*)$",
  "^[!/#](openchat)$",
  "^[!/#](stats)$",
  "^[!/#](reset)$",
  "(.*)",
  }, 
run = ByRoO 
}
-----منبع این پلاگین مربوط ب مهدی رو هس گفتم نگین نگفته-----