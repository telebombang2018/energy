local function run(msg, matches)
    if matches[1] == 'addkick' or 'اد کردن ممبر ها' and is_admin(msg) then
        if gp_type(msg.to.id) == "channel" then
            tdcli.getChannelMembers(msg.to.id, 0, "Kicked", 200, function (i, naji)
                for k,v in pairs(naji.members_) do
                    tdcli.addChatMember(i.chat_id, v.user_id_, 50, dl_cb, nil)
                end
            end, {chat_id=msg.to.id})
            return "`اعضای محروم از گروه به گروه دعوت شدند`"
        end
        return "_😐 فقط در _`سوپر گروه`_ ممکن است_"
    end
end

return { 
patterns = { 
"^اد کردن ممبر ها$",
"^[!/#](addkick)$", 
}, 
run = run 
}
-----my_name_is_ehsan*#@mafia_boy
-----@ENERGY_TEAM     FOR UPDATE
-----لطفا پیام بالا رو پاک نکنید