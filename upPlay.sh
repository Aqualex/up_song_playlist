#!/bin/bash
########################################################################################################################
## SUGGESTIONS                                                                                                        ##
##                                                                                                                    ##
## 1. Add proper error trapping                                                                                       ##
########################################################################################################################

########################################################################################################################
##     SETTING ENVIRONMENT VARIABLES                                                                                  ##
########################################################################################################################
URL="https://www.youtube.com/watch?v=36tggrpRoTI&list=PLgAMMtt4kf4TXH0r0xINENxAAqFCXGN2t"
loc=/media/alex/cf35aee0-faeb-40bb-adac-88595e8f71fe/alex_hdd/2019/PersonalProg/bash/update_song_playlist/
to=/run/user/1000/gvfs/mtp:host=%5Busb%3A001%2C010%5D/Card/Music/

########################################################################################################################
##     FUNCTIONS DEFINITIONS                                                                                          ##
######################################################################################################################## 
gettimestamp(){
  #get timestamp for adding it to error/info reporting
  date "+%Y.%m.%dD%T.%N"
}

convertsnames(){
  #remove spaces in song
  for f in $loc*; do 
    #get name of file only 
    if [ 1 -eq `echo $f|grep mp3|wc -l` ];then 
      #echo "$(basename "$f")"; #test only 
      dir="$(dirname "$f")/";
      namebefore="$(basename "$f")";
      nameafter=`echo "$namebefore" | 
        awk '{ gsub (" ", "_", $0); print}' | 
        awk '{ gsub ("-", "_", $0); print}' | 
        awk '{ gsub ("___", "_", $0); print}'`
      mv "$dir$namebefore" "$dir$nameafter" &> /dev/null
    fi      
  done
}

settingdefaults(){
  #set defaul values
  echo "[INFO]|$(gettimestamp)|Checking if URL has been provided..."
  if [ -z "$URL" ];then 
    echo -n "[ERROR]|$(gettimestamp)|URL has not been provided! Program will now exit..."
    exit 1
  fi
}

downdep(){
  #check if youtube-dl is installed. install if not
  echo "[INFO]|$(gettimestamp)|Checking if youtube-dl is installed..." 
  if [ ! 1 -eq `dpkg -l|grep youtube-dl|wc -l` ]; then 
    echo "[INFO]|$(gettimestamp)|Installing youtube-dl..."	
    sudo apt-get -qq install youtube-dl
    if [ ! 1 -eq `dpkg -l|grep youtube-dl|wc -l` ];then
    	echo "[ERROR]|$(gettimestamp)|youtube-dl failed to download -> program will now exit!"
    	exit 1
    fi
    echo "[INFO]|$(gettimestamp)|youtube-dl has been succesfully downloaded..."
  else 
    echo "[INFO]|$(gettimestamp)|youtube-dl is already installed..."
  fi
}

updateplaylist(){
  echo "[INFO]|$(gettimestamp)|Downloading playlist..."
  youtube-dl --extract-audio --audio-format mp3 --output $loc --ignore-errors --continue --download-archive songs.txt $1	
}

syncdevice(){
  #move files
  echo "[INFO]|$(gettimestamp)|Syncing device..."
  cp "$loc*" "$to"
}

########################################################################################################################
##     MAIN                                                                                                           ##
########################################################################################################################
#Executing functions 
settingdefaults; 
downdep;
updateplaylist "$URL"; 
convertsnames;
syncdevice;
