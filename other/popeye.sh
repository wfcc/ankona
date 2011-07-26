#!/bin/bash

#############
parse_query() #@ USAGE: parse_query var ...
{
    local var val
    local IFS='&'
    vars="&$*&"
    [ "$REQUEST_METHOD" = "POST" ] && read QUERY_STRING
    set -f
    for item in $QUERY_STRING; do
      var=${item%%=*}
      val=${item#*=}
      val=${val//+/ }
      case $vars in
          *"&$var&"* )
              case $val in
                  *%[0-9a-fA-F][0-9a-fA-F]*)
                       ## Next line requires bash 3.1 or later
                       printf -v val "%b" "${val//\%/\\x}."
                       ## Older bash, use: val=$( printf "%b" "${val//\%/\\x}." )
                       val=${val%.}
              esac
              eval "$var=\$val"
              ;;
      esac
    done
    set +f
}
#############

echo Content-type: text/plain
echo ""

QUERY_STRING=`cat`
unset REQUEST_METHOD  ## just in case

parse_query stipulation forsyth popeye

$popeye <<EOD 2>&1
      BeginProblem
      Option NoBoard
      Option MaxTime 30             
      Stipulation $stipulation
      Forsyth $forsyth
      EndProblem
EOD

