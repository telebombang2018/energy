-----my_name_is_ehsan*#@mafia_boy
-----@ENERGY_TEAM     FOR UPDATE
-----لطفا پیام بالا رو پاک نکنید
local function pre_process(msg)
 msg.text = msg.content_.text
	local timetoexpire = 'unknown'
	local expiretime = redis:hget ('expiretime', msg.chat_id_)
	local now = tonumber(os.time())
	if expiretime then    
		timetoexpire = math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1
		if tonumber("0") > tonumber(timetoexpire) and not is_sudo(msg) then
		if msg.text:match('/') then
			return tdcli.sendMessage(msg.chat_id_, 0, 1, '*ExpireTime Ended.*', 1, 'md')
		else
			return
		end
	end
	if tonumber(timetoexpire) == 0 then
		if redis:hget('expires0',msg.chat_id_) then end
		tdcli.sendMessage(msg.chat_id_, 0, 1, '*⚠️مدت استفاده ربات شما تمام شده است لطفا آن را تمدید کنید*.', 1, 'md')
		redis:hset('expires0',msg.chat_id_,'5')
	end
	if tonumber(timetoexpire) == 1 then
		if redis:hget('expires1',msg.chat_id_) then end
		tdcli.sendMessage(msg.chat_id_, 0, 1, '*⚠️ ⚠️ فقط 1⃣ روز  تا پایان مدت استفاده از ربات باقی مانده است لطفا آن را تمدید کنید.*.', 1, 'md')
		redis:hset('expires1',msg.chat_id_,'5')
	end

end

end
function run(msg, matches)
	if matches[1]:lower() == 'setexpire' or 'شارژ' then
		if not is_sudo(msg) then return end
		local time = os.time()
		local buytime = tonumber(os.time())
		local timeexpire = tonumber(buytime) + (tonumber(matches[2]) * 86400)
		redis:hset('expiretime',msg.chat_id_,timeexpire)
		return "*انقضای ربات تنظیم شد به * _"..matches[2].. "_ *روز* "
	end
	if matches[1]:lower() == 'expire' then
		local expiretime = redis:hget ('expiretime', msg.chat_id_)
		if not expiretime then return '*Unlimited*' else
			local now = tonumber(os.time())
			return (math.floor((tonumber(expiretime) - tonumber(now)) / 86400) + 1) .. " *روز باقی مانده⏱*"
		end
	end

end
return {
  patterns = {
    "^[!#/]([Ss]etexpire) (.*)$",
	"^(شارژ) (.*)$",
	"^[!#/]([Ee]xpire)$",
    
  },
  run = run,
  pre_process = pre_process
}
-- http://bombangteam.blogfa.com
-----my_name_is_ehsan*#@mafia_boy
-----@ENERGY_TEAM     FOR UPDATE
-----لطفا پیام بالا رو پاک نکنید