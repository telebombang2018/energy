

--Special Thx To @aliaz003 CH;@RICHENERGY
--------------------------------

local function run_bash(str)
    local cmd = io.popen(str)
    local result = cmd:read('*all')
    return result
end
--------------------------------
local api_key = nil
local base_api = "https://maps.googleapis.com/maps/api"
--------------------------------
local function get_latlong(area)
	local api      = base_api .. "/geocode/json?"
	local parameters = "address=".. (URL.escape(area) or "")
	if api_key ~= nil then
		parameters = parameters .. "&key="..api_key
	end
	local res, code = https.request(api..parameters)
	if code ~=200 then return nil  end
	local data = json:decode(res)
	if (data.status == "ZERO_RESULTS") then
		return nil
	end
	if (data.status == "OK") then
		lat  = data.results[1].geometry.location.lat
		lng  = data.results[1].geometry.location.lng
		acc  = data.results[1].geometry.location_type
		types= data.results[1].types
		return lat,lng,acc,types
	end
end
--------------------------------
local function get_staticmap(area)
	local api        = base_api .. "/staticmap?"
	local lat,lng,acc,types = get_latlong(area)
	local scale = types[1]
	if scale == "locality" then
		zoom=8
	elseif scale == "country" then 
		zoom=4
	else 
		zoom = 13 
	end
	local parameters =
		"size=600x300" ..
		"&zoom="  .. zoom ..
		"&center=" .. URL.escape(area) ..
		"&markers=color:red"..URL.escape("|"..area)
	if api_key ~= nil and api_key ~= "" then
		parameters = parameters .. "&key="..api_key
	end
	return lat, lng, api..parameters
end
--------------------------------
local function get_weather(location)
	print("Finding weather in ", location)
	local BASE_URL = "http://api.openweathermap.org/data/2.5/weather"
	local url = BASE_URL
	url = url..'?q='..location..'&APPID=eedbc05ba060c787ab0614cad1f2e12b'
	url = url..'&units=metric'
	local b, c, h = http.request(url)
	if c ~= 200 then return nil end
	local weather = json:decode(b)
	local city = weather.name
	local country = weather.sys.country
	local temp = 'دمای شهر '..city..' هم اکنون '..weather.main.temp..' درجه سانتی گراد می باشد\n____________________'
	local conditions = 'شرایط فعلی آب و هوا : '
	if weather.weather[1].main == 'Clear' then
		conditions = conditions .. 'آفتابی☀'
	elseif weather.weather[1].main == 'Clouds' then
		conditions = conditions .. 'ابری ☁☁'
	elseif weather.weather[1].main == 'Rain' then
		conditions = conditions .. 'بارانی ☔'
	elseif weather.weather[1].main == 'Thunderstorm' then
		conditions = conditions .. 'طوفانی ☔☔☔☔'
	elseif weather.weather[1].main == 'Mist' then
		conditions = conditions .. 'مه 💨'
	end
	return temp .. '\n' .. conditions
end
--------------------------------
local function calc(exp)
	url = 'http://api.mathjs.org/v1/'
	url = url..'?expr='..URL.escape(exp)
	b,c = http.request(url)
	text = nil
	if c == 200 then
    text = 'Result = '..b..'\n____________________'..msg_caption
	elseif c == 400 then
		text = b
	else
		text = 'Unexpected error\n'
		..'Is api.mathjs.org up?'
	end
	return text
end
--------------------------------
function exi_file(path, suffix)
    local files = {}
    local pth = tostring(path)
	local psv = tostring(suffix)
    for k, v in pairs(scandir(pth)) do
        if (v:match('.'..psv..'$')) then
            table.insert(files, v)
        end
    end
    return files
end
--------------------------------
function file_exi(name, path, suffix)
	local fname = tostring(name)
	local pth = tostring(path)
	local psv = tostring(suffix)
    for k,v in pairs(exi_file(pth, psv)) do
        if fname == v then
            return true
        end
    end
    return false
end
--------------------------------
function run(msg, matches) 
local Chash = "cmd_lang:"..msg.to.id
local Clang = redis:get(Chash)
	if matches[1]:lower() == "calc" or matches[1] == 'ماشین حساب' and is_mod(msg) then
		if msg.to.type == "pv" then 
			return 
       end
		return calc(matches[2])
	end
--------------------------------
	if matches[1]:lower() == "praytime" or matches[1] == 'ساعات شرعی' and is_mod(msg) then
		if matches[2] then
			city = matches[2]
		elseif not matches[2] then
			city = 'Tehran'
		end
		local lat,lng,url	= get_staticmap(city)
		local dumptime = run_bash('date +%s')
		local code = http.request('http://api.aladhan.com/timings/'..dumptime..'?latitude='..lat..'&longitude='..lng..'&timezonestring=Asia/Tehran&method=7')
		local jdat = json:decode(code)
		local data = jdat.data.timings
		local text = 'شهر: '..city
		text = text..'\nاذان صبح: '..data.Fajr
		text = text..'\nطلوع آفتاب: '..data.Sunrise
		text = text..'\nاذان ظهر: '..data.Dhuhr
		text = text..'\nغروب آفتاب: '..data.Sunset
		text = text..'\nاذان مغرب: '..data.Maghrib
		text = text..'\nعشاء : '..data.Isha
		text = text..msg_caption
		return tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
	end
--------------------------------
	if matches[1]:lower() == "tophoto" or matches[1] == 'تبدیل به عکس' and is_mod(msg) and msg.reply_id then
		function tophoto(arg, data)
			function tophoto_cb(arg,data)
				if data.content_.sticker_ then
					local file = data.content_.sticker_.sticker_.path_
					local secp = tostring(tcpath)..'/data/sticker/'
					local ffile = string.gsub(file, '-', '')
					local fsecp = string.gsub(secp, '-', '')
					local name = string.gsub(ffile, fsecp, '')
					local sname = string.gsub(name, 'webp', 'jpg')
					local pfile = 'data/photos/'..sname
					local pasvand = 'webp'
					local apath = tostring(tcpath)..'/data/sticker'
					if file_exi(tostring(name), tostring(apath), tostring(pasvand)) then
						os.rename(file, pfile)
						tdcli.sendPhoto(msg.to.id, 0, 0, 1, nil, pfile, msg_caption, dl_cb, nil)
					else
						tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This sticker does not exist. Send sticker again._'..msg_caption, 1, 'md')
					end
				else
					tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This is not a sticker._', 1, 'md')
				end
			end
            tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, tophoto_cb, nil)
		end
		tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_id }, tophoto, nil)
    end
--------------------------------
	if matches[1]:lower() == "tosticker" or matches[1] == 'تبدیل به استیکر' and is_mod(msg) and msg.reply_id then
		function tosticker(arg, data)
			function tosticker_cb(arg,data)
				if data.content_.ID == 'MessagePhoto' then
					file = data.content_.photo_.id_
					local pathf = tcpath..'/data/photo/'..file..'_(1).jpg'
					local pfile = 'data/photos/'..file..'.webp'
					if file_exi(file..'_(1).jpg', tcpath..'/data/photo', 'jpg') then
						os.rename(pathf, pfile)
						tdcli.sendDocument(msg.chat_id_, 0, 0, 1, nil, pfile, msg_caption, dl_cb, nil)
					else
						tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This photo does not exist. Send photo again._', 1, 'md')
					end
				else
					tdcli.sendMessage(msg.to.id, msg.id_, 1, '_This is not a photo._', 1, 'md')
				end
			end
			tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = data.id_ }, tosticker_cb, nil)
		end
		tdcli_function ({ ID = 'GetMessage', chat_id_ = msg.chat_id_, message_id_ = msg.reply_id }, tosticker, nil)
    end
--------------------------------
	if matches[1]:lower() == "weather" or matches[1] == 'اب و هوا' and is_mod(msg) then
		city = matches[2]
		local wtext = get_weather(city)
		if not wtext then
			wtext = 'مکان وارد شده صحیح نیست'
		end
		return wtext
	end
--------------------------------
	if matches[1]:lower() == "time" or matches[1] == 'ساعت' and is_mod(msg) then
		local url , res = http.request('http://irapi.ir/time/')
		if res ~= 200 then
			return "No connection"
		end
		local colors = {'blue','green','yellow','magenta','Orange','DarkOrange','red'}
		local fonts = {'mathbf','mathit','mathfrak','mathrm'}
		local jdat = json:decode(url)
		local url = 'http://latex.codecogs.com/png.download?'..'\\dpi{600}%20\\huge%20\\'..fonts[math.random(#fonts)]..'{{\\color{'..colors[math.random(#colors)]..'}'..jdat.ENtime..'}}'
		local file = download_to_file(url,'time.webp')
		tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, msg_caption, dl_cb, nil)

	end
--------------------------------
	if matches[1]:lower() == "voice" or matches[1] == 'تبدیل به صدا' and is_mod(msg) then
 local text = matches[2]
    textc = text:gsub(' ','.')
    
  if msg.to.type == 'pv' then 
      return nil
      else
  local url = "http://tts.baidu.com/text2audio?lan=en&ie=UTF-8&text="..textc
  local file = download_to_file(url,'BD-Reborn.mp3')
 				tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, msg_caption, dl_cb, nil)
   end
end

 --------------------------------
	if matches[1]:lower() == "tr" or matches[1] == 'ترجمه' and is_mod(msg) then
		url = https.request('https://translate.yandex.net/api/v1.5/tr.json/translate?key=trnsl.1.1.20160119T111342Z.fd6bf13b3590838f.6ce9d8cca4672f0ed24f649c1b502789c9f4687a&format=plain&lang='..URL.escape(matches[2])..'&text='..URL.escape(matches[3]))
		data = json:decode(url)
		return 'زبان : '..data.lang..'\nترجمه : '..data.text[1]..'\n____________________'..msg_caption
	end
--------------------------------
	if (matches[1]:lower() == 'short' and not Clang) or (matches[1]:lower() == 'لینک کوتاه' and Clang) then
		if matches[2]:match("[Hh][Tt][Tt][Pp][Ss]://") then
			shortlink = matches[2]
		elseif not matches[2]:match("[Hh][Tt][Tt][Pp][Ss]://") then
			shortlink = "https://"..matches[2]
		end
		local yon = http.request('http://api.yon.ir/?url='..URL.escape(shortlink))
		local jdat = json:decode(yon)
		local bitly = https.request('https://api-ssl.bitly.com/v3/shorten?access_token=f2d0b4eabb524aaaf22fbc51ca620ae0fa16753d&longUrl='..URL.escape(shortlink))
		local data = json:decode(bitly)
		local u2s = http.request('http://u2s.ir/?api=1&return_text=1&url='..URL.escape(shortlink))
		local llink = http.request('http://llink.ir/yourls-api.php?signature=a13360d6d8&action=shorturl&url='..URL.escape(shortlink)..'&format=simple')
		local text = ' 🌐لینک اصلی :\n'..check_markdown(data.data.long_url)..'\n\nلینکهای کوتاه شده با 6 سایت کوتاه ساز لینک : \n》کوتاه شده با bitly :\n___________________________\n'..(check_markdown(data.data.url) or '---')..'\n___________________________\n》کوتاه شده با u2s :\n'..(check_markdown(u2s) or '---')..'\n___________________________\n》کوتاه شده با llink : \n'..(check_markdown(llink) or '---')..'\n___________________________\n》لینک کوتاه شده با yon : \nyon.ir/'..(check_markdown(jdat.output) or '---')..'\n____________________'..msg_caption
		return tdcli.sendMessage(msg.chat_id_, 0, 1, text, 1, 'html')
	end
--------------------------------
	if matches[1]:lower() == "sticker" or matches[1] == 'استیکر' and is_mod(msg) then
		local eq = URL.escape(matches[2])
		local w = "500"
		local h = "500"
		local txtsize = "100"
		local txtclr = "ff2e4357"
		if matches[3] then 
			txtclr = matches[3]
		end
		if matches[4] then 
			txtsize = matches[4]
		end
		if matches[5] and matches[6] then 
			w = matches[5]
			h = matches[6]
		end
		local url = "https://assets.imgix.net/examples/clouds.jpg?blur=150&w="..w.."&h="..h.."&fit=crop&txt="..eq.."&txtsize="..txtsize.."&txtclr="..txtclr.."&txtalign=middle,center&txtfont=Futura%20Condensed%20Medium&mono=ff6598cc"
		local receiver = msg.to.id
		local  file = download_to_file(url,'text.webp')
		tdcli.sendDocument(msg.to.id, 0, 0, 1, nil, file, msg_caption, dl_cb, nil)
	end
--------------------------------
	if matches[1]:lower() == "photo" or matches[1] == 'عکس' and is_mod(msg) then
		local eq = URL.escape(matches[2])
		local w = "500"
		local h = "500"
		local txtsize = "100"
		local txtclr = "ff2e4357"
		if matches[3] then 
			txtclr = matches[3]
		end
		if matches[4] then 
			txtsize = matches[4]
		end
		if matches[5] and matches[6] then 
			w = matches[5]
			h = matches[6]
		end
		local url = "https://assets.imgix.net/examples/clouds.jpg?blur=150&w="..w.."&h="..h.."&fit=crop&txt="..eq.."&txtsize="..txtsize.."&txtclr="..txtclr.."&txtalign=middle,center&txtfont=Futura%20Condensed%20Medium&mono=ff6598cc"
		local receiver = msg.to.id
		local  file = download_to_file(url,'text.jpg')
		tdcli.sendPhoto(msg.to.id, 0, 0, 1, nil, file, msg_caption, dl_cb, nil)
	end


--------------------------------
if matches[1] == "fun help" and not Clang then
local hash = "gp_lang:"..msg.to.id
local lang = redis:get(hash)
if not lang then
helpfun_en = [[
🔘_ENERGY.دستورات سرگرمی:_

◾️*!time*
◾️*ساعت*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!short* `[link]`
◾️*لینک کوتاه* `[لینک]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!voice* `[text]`
◾️*تبدیل به صدا* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tr* `[lang] [word]`
◾️*ترجمه* `[زبان] [کلمه]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!sticker* `[word]`
◾️*استیکر* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!photo* `[word]`
◾️*عکس* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!calc* `[number]`
◾️*ماشین حساب* `[معادله]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!praytime* `[city]`
◾️*ساعات شرعی* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tosticker* `[reply]`
◾️*تبدیل به استیکر* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tophoto* `[reply]`
◾️*تبدیل به عکس* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!weather* `[city]`
◾️*اب و هوا* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘*شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘_You can use_ *[!/#]* _at the beginning of commands._
🌐 @RICHENERGY 🌐 ;)]]
else

helpfun_en = [[
🔘_ENERGY.دستورات سرگرمی:_

◾️*!time*
◾️*ساعت*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!short* `[link]`
◾️*لینک کوتاه* `[لینک]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!voice* `[text]`
◾️*تبدیل به صدا* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tr* `[lang] [word]`
◾️*ترجمه* `[زبان] [کلمه]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!sticker* `[word]`
◾️*استیکر* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!photo* `[word]`
◾️*عکس* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!calc* `[number]`
◾️*ماشین حساب* `[معادله]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!praytime* `[city]`
◾️*ساعات شرعی* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tosticker* `[reply]`
◾️*تبدیل به استیکر* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tophoto* `[reply]`
◾️*تبدیل به عکس* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!weather* `[city]`
◾️*اب و هوا* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘*شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘_You can use_ *[!/#]* _at the beginning of commands._
🌐 @RICHENERGY 🌐 ;)]]
end
return helpfun_en..msg_caption
end

if matches[1] == "راهنما فان" and Clang then
local hash = "gp_lang:"..msg.to.id
local lang = redis:get(hash)
if not lang then
helpfun_fa = [[
🔘_ENERGY.دستورات سرگرمی:_

◾️*!time*
◾️*ساعت*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!short* `[link]`
◾️*لینک کوتاه* `[لینک]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!voice* `[text]`
◾️*تبدیل به صدا* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tr* `[lang] [word]`
◾️*ترجمه* `[زبان] [کلمه]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!sticker* `[word]`
◾️*استیکر* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!photo* `[word]`
◾️*عکس* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!calc* `[number]`
◾️*ماشین حساب* `[معادله]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!praytime* `[city]`
◾️*ساعات شرعی* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tosticker* `[reply]`
◾️*تبدیل به استیکر* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tophoto* `[reply]`
◾️*تبدیل به عکس* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!weather* `[city]`
◾️*اب و هوا* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘*شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘_You can use_ *[!/#]* _at the beginning of commands._
🌐 @RICHENERGY 🌐 ;)]]
else

helpfun_fa = [[
🔘_ENERGY.دستورات سرگرمی:_

◾️*!time*
◾️*ساعت*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!short* `[link]`
◾️*لینک کوتاه* `[لینک]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!voice* `[text]`
◾️*تبدیل به صدا* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tr* `[lang] [word]`
◾️*ترجمه* `[زبان] [کلمه]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!sticker* `[word]`
◾️*استیکر* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!photo* `[word]`
◾️*عکس* `[متن]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!calc* `[number]`
◾️*ماشین حساب* `[معادله]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!praytime* `[city]`
◾️*ساعات شرعی* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tosticker* `[reply]`
◾️*تبدیل به استیکر* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!tophoto* `[reply]`
◾️*تبدیل به عکس* `[ریپلی]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
◾️*!weather* `[city]`
◾️*اب و هوا* `[شهر]`
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘*شما میتوانید از [!/#] در اول دستورات برای اجرای آنها بهره بگیرید*
﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄﹃﹄
🔘_You can use_ *[!/#]* _at the beginning of commands._
🌐 @RICHENERGY 🌐 ;)]]
end
return helpfun_fa..msg_caption
end

end
--------------------------------
return {               
	patterns = {
        "^[#!/](fun help)$",
    	"^[#!/](weather) (.*)$",
		"^[#!/](calc) (.*)$",
		"^[#!/](time)$",
		"^[#!/](tophoto)$",
		"^[#!/](tosticker)$",
		"^[#!/](voice) +(.*)$",
		"^[#!/]([Pp]raytime) (.*)$",
		"^[#!/](praytime)$",
		"^[#!/]([Tt]r) ([^%s]+) (.*)$",
		"^[#!/]([Ss]hort) (.*)$",
		"^[#!/](photo) (.+)$",
		"^[#!/](sticker) (.+)$",
        "^(راهنما فان)$",
    	"^(اب و هوا) (.*)$",
		"^(ماشین حساب) (.*)$",
		"^(ساعت)$",
		"^(تبدیل به عکس)$",
		"^(تبدیل به استیکر)$",
		"^(تبدیل به صدا) +(.*)$",
		"^(ساعات شرعی) (.*)$",
		"^(ساعات شرعی)$",
		"^(ترجمه) ([^%s]+) (.*)$",
		"^(لینک کوتاه) (.*)$",
		"^(عکس) (.+)$",
		"^(استیکر) (.+)$"
		}, 
	run = run,
	}

--#EDITby @RICHENERGY:)
