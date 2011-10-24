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

parse_query input popeye

$popeye <<<$input | head -200 2>&1

