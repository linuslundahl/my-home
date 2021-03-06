#!/bin/sh

# Various functions
h() { cd "$HOME/$1" || return; }
compctl -M 'm:{a-zA-Z}={A-Za-z}' -W ~/ -/ h

# Fun
# snow() { ruby -e 'C=`stty size`.scan(/\d+/)[1].to_i;S=["2743".to_i(16)].pack("U*");a={};puts "\033[2J";loop{a[rand(C)]=0;a.each{|x,o|;a[x]+=1;print "\033[#{o};#{x}H \033[#{a[x]};#{x}H#{S} \033[0;0H"};$stdout.flush;sleep 0.1}'; }
starwars() { telnet towel.blinkenlights.nl; }

# Copy absolute filepath.
pwdc() { echo "$PWD/$1" | pbcopy; }

# Get image dimensions
dim() { sips "$1" -g pixelWidth -g pixelHeight; }

# Download all images from url
downloadImages() { wget -nd -H -p -A jpg,jpeg,png,gif -e robots=off "$1"; }

# Project dir functions
pd() { cd "$PROJECT_DIR/$1/$2" || return; }             # root in project
pp() { cd "$PROJECT_DIR/$1/$2/public_html" || return; } # public_html in project
# sublp() {subl $PROJECT_DIR/$1}
# sublw() {subl $PROJECT_DIR/$1/public_html/wp-content}
# subld() {subl $PROJECT_DIR/$1/public_html/sites/all}
# solrp() {cd $PROJECT_DIR/$1/solr/example; java -jar start.jar;}
# png8p() {png8 $PROJECT_DIR/$1/*.png && \rm $PROJECT_DIR/$1/*.backup.png}
compctl -W "$PROJECT_DIR" -/ pd pp

# Logs
logclear() { echo '' >! "$HOME/Library/Logs/$1";echo "$1 was cleared."; }
logtail() { tail -f "$HOME/Library/Logs/$1"; }
logopen() { open "$HOME/Library/Logs/$1"; }
compctl -W ~/Library/logs/ -f log-clear log-tail log-open

# List most used commands
his() { history | awk '{a[$2]++}END{for(i in a){print a[i] " " i}}' | sort -rn | head -10; }

# Find text in any file
ft() { find . -name "$2" -exec grep -il "$1" {} \;; }

# SQL import using pv
sqlimport() {
  FILE=$1
  if [ "$3" ]; then
    USER=$2
    DB=$3
  else
    USER='root'
    DB=$2
  fi

  pv "$FILE" | mysql -u "$USER" -p "$DB"
}

# List all aliases available
# listaliases() {
#   COMMANDS=`echo "$PATH" | xargs : -I {} find {} -maxdepth 1 \
#     -executable -type f -printf '%P\n'`
#   ALIASES=`alias | cut -d '=' -f 1`
#   echo "$COMMANDS"'\n'"$ALIASES" | sort -u
# }

# Extract most know archives with one command
extract() {
  if [ -f "$1" ] ; then
    case $1 in
      *.tar.bz2)   tar xjf "$1"     ;;
      *.tar.gz)    tar xzf "$1"     ;;
      *.bz2)       bunzip2 "$1"     ;;
      *.rar)       unrar e "$1"     ;;
      *.gz)        gunzip "$1"      ;;
      *.tar)       tar xf "$1"      ;;
      *.tbz2)      tar xjf "$1"     ;;
      *.tgz)       tar xzf "$1"     ;;
      *.zip)       unzip "$1"       ;;
      *.Z)         uncompress "$1"  ;;
      *.7z)        7z x "$1"        ;;
      *)     echo "'$1' cannot be extracted via extract()" ;;
       esac
   else
       echo "'$1' is not a valid file"
   fi
}

# Go back x directories
dc() {
  str=""
  count=0
  while [ "$count" -lt "$1" ];
  do
    str=$str"../"
    count=$((count+1))
  done
  cd $str || return
}

# Pretty print json
pjson() {
  if [ $# -gt 0 ];
    then
    for arg in "$@"
    do
      if [ -f "$arg" ];
        then
        less "$arg" | python -m json.tool
      else
        echo "$arg" | python -m json.tool
      fi
    done
  fi
}

# Install a grunt plugin and save to devDependencies
gi() { npm install --save-dev grunt-"$*"; }

# Install a grunt-contrib plugin and save to devDependencies
gci() { npm install --save-dev grunt-contrib-"$*"; }

# Start a simple server in current directory
serve() { python -m SimpleHTTPServer "${1:-8080}"; }

# Encode a given image file as base64 and output to clipboard
enc64() {
  openssl base64 -in "$1" | awk -v ext="${1#*.}" '{ str1=str1 $0 }END{ print "data:image/"ext";base64,"str1"" }' | pbcopy
  echo "$1 encoded to clipboard"
}

b64() { < "$1" base64 | pbcopy; }

# Helper to loop through directories and merge:
# for dir in $(find . -type d -maxdepth 1 -not -path .); do cd $dir && mergevideo && cd ..; done
mergevideo() {
  touch files.txt && touch files-2.txt;
  find ./*.avi | while read -r each; do echo "file '$each'" >> files.txt; done;
  find ./*.avi | while read -r each; do echo "$each" >> files-2.txt; done;
  ffmpeg -f concat -i files.txt -c copy "${PWD##*/}.avi";
  if [ -e "${PWD##*/}.avi" ]
  then
    while read -r file; do
      rm "$file";
    done <files-2.txt
  fi
  rm files.txt
  rm files-2.txt;
}

treelist() { tree -I ".git|node_modules|bower_components|.sass-cache|.DS_Store" --dirsfirst --filelimit 15 -L "${1:-3}" -aC "$2"; }

# List with size
lssize() { du -sk -- * | sort -n | perl -pe \''@SI=qw(K M G T P); s:^(\d+?)((\d\d\d)*)\s:$1." ".$SI[((length $2)/3)]."\t":e'\'; }

# ringtone() { afconvert "$1" "${1%.*}.m4r" -f m4af; }
ringtone() { ffmpeg -i "$1" -aq 2 "${1%.*}.m4a" && mv "${1%.*}.m4a" "${1%.*}.m4r"; }
ringtones() { for i in *.mp3; do ringtone "$i"; done }
gif2webm() { ffmpeg -i "$1" -b:v 600K -qmin 0 -qmax 50 -crf 5 "$2"; }
giflossy2() { gifsicle -O3 --lossy=80 -o "$2" "$1"; }

killports() { lsof -i tcp:"$1" | awk 'NR!=1 {print $2}' | xargs kill -9; }

mff() { curl "https://malmo-ff.unwi.se/$1"; }
