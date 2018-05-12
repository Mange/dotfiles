#!/bin/sh

# i3get
#
# search for windows in i3 tree, return desired information
# if no arguments are passed. con_id of acitve window is returned.
# ctrl+c, ctrl+v by budRich 2017
# bash to sh by: nimaje
# 
# Options:
# a             currently active window (default)
# c CLASS       search for windows with the given class
# i INSTANCE    search for windows with the given instance
# t TITLE       search for windows with title.
# n CON_ID      search for windows with the given con_id
# d CON_ID      search for windows with the given window id
# m CON_MARK      search for windows with the given mark
# y             synch on. If this option is included, script will wait till
#               target window exist.
# 
# r [tcidnmw]   desired return.
#                 t: title
#                 c: class
#                 i: instance
#                 d: Window ID
#                 n: Con_Id (default)
#                 m: mark
#                 w: workspace
#                 a: is active
#                 f: floating state
#
# Examples:
# search for window with instance name sublime_text. Request
# workspace, title and floating state.
# i3get -i sublime_text -r wtf

while getopts :c:i:t:n:d:r:m:ay option
do
  case "${option}" in
    i) crit="\"instance\"" srch="${OPTARG}";;
    c) crit="\"class\"" srch="${OPTARG}";;
    t) crit="\"title\"" srch="${OPTARG}";;
    n) crit="\"id\"" srch="${OPTARG}";;
    d) crit="\"window\"" srch="${OPTARG}";;
    m) crit="\"marks\"" srch="${OPTARG}";;
    a) crit="\"focused\"" && srch="true";;
    r) sret="${OPTARG}" ;;
    y) synk=1;;
  esac
done

synk=${synk:=0}
sret=${sret:=n}
[ -z "$crit" ] && crit="\"focused\"" && srch="true"

getwindow(){
  i3-msg -t get_tree \
  | awk -v RS=',' -F':' -v crit="${crit}" -v srch="${srch}" -v sret="${sret}" \
    'BEGIN{hit="0"}
      $1~"{\"id\"" {if(sret ~ n)r["n"]=$2}
      $2~"\"id\"" {if(sret ~ n)r["n"]=$3}
      $1==crit && $2 ~ srch  {hit=1}
      $2 ~ crit && $3 ~ srch {hit=1}
      sret ~ t && $1=="\"title\"" {r["t"]=$2}
      sret ~ c && $2 ~ "\"class\"" {r["c"]=$3}
      sret ~ i && $1=="\"instance\"" {r["i"]=$2}
      sret ~ d && $1=="\"window\"" {r["d"]=$2}
      sret ~ m && $1=="\"marks\"" {r["m"]=$2}
      sret ~ a && $1=="\"focused\"" {r["a"]=$2}
      sret ~ f && $1=="\"floating\"" {r["f"]=$2;if(hit == "1") exit}
      sret ~ w && $1=="\"num\"" {r["w"]=$2}
    END{if(hit == "0") exit
      split(sret, aret, "")
      for (i=1; i <= length(sret); i++) {
        if(r[aret[i]]!="")printf("%s\n", r[aret[i]])
      }
    }
    '
}

result=$(getwindow)
[ $synk = 1 ] && \
  while [ -z "$result" ]; do sleep 0.1; result=$(getwindow); done
[ -n "$result" ] && printf "${result}\n"
