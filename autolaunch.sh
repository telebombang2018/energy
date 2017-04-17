#!/bin/bash
COUNTER=1
while(true) do
./tele_bom_bang_new.sh
curl "https://api.telegram.org/bot379717771:AAFa7zve6nOgVnzggrcpOctPEf077mh-uag/sendmessage" -F "chat_id=310083510" -F "text=#NEWCRASH-#Tele_bom_bang-Reloaded-${COUNTER}-times"
let COUNTER=COUNTER+1 
done