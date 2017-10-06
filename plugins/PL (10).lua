-----my_name_is_ehsan*#@mafia_boy
-----@ENERGY_TEAM     FOR UPDATE
-----لطفا پیام بالا رو پاک نکنید
 local function run(msg, matches) 
if matches [1] =='setnerkh' then 
if not is_admin(msg) then 
return 'شما سودو نیستید' 
end 
local nerkh = matches[2] 
redis:set('bot:nerkh',nerkh) 
return 'متن شما با موفقیت تنظیم شد.' 
end 
if matches[1] == 'nerkh' or 'نرخ' then 
if not is_mod(msg) then 
return 
end 
    local hash = ('bot:nerkh') 
    local nerkh = redis:get(hash) 
    if not nerkh then 
    return ' ثبت نشده' 
    else 
     tdcli.sendMessage(msg.chat_id_, 0, 1, nerkh, 1, 'html') 
    end 
    end 
if matches[1]=="delnerkh" then 
if not is_admin(msg) then 
return 'شما ادمین نیستید' 
end 
    local hash = ('bot:nerkh') 
    redis:del(hash) 
return ' پاک شد' 
end 
end 
return { 
patterns ={ 
"^[!#/](setnerkh) (.*)$", 
"^[!#/](nerkh)$",
"^💳$",
"^قیمت ربات$",
"^قیمت رباط$",
"^نرخ$", 
"^[!#/](delnerkh)$", 
}, 
run = run 
}
-----my_name_is_ehsan*#@mafia_boy
-----@ENERGY_TEAM     FOR UPDATE
-----لطفا پیام بالا رو پاک نکنید