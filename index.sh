#!/bin/bash

echo "Content-type: text/html"
echo ""
echo "<!doctype html>
<head>
<meta charset=\"utf-8\">
<meta name=\"author\" content=\"Blaize Stewart\">
<title>RTMP Restream Server</title>
</head>
<style>
textarea {
  white-space: pre;
  overflow-wrap: normal;
  overflow-x: scroll;
}
</style>
<body>
<h1>RTMP Restream Server</h1>"

function urldecode() { : "${*//+/ }"; echo -e "${_//%/\\x}"; }

# eval `echo "${QUERY_STRING}"|tr '&' ';'`


if [ ! -z "$QUERY_STRING" ]
then

        saveIFS=$IFS
        IFS='=&'
        parm_get=($QUERY_STRING)
        IFS=$saveIFS

        for ((i=0; i<${#parm_get[@]}; i+=2)); do
                stream=$(urldecode ${parm_get[i+1]})
                if [ "$stream" != "" ]
                then
                        if  [ ! -z "$streams" ]
                        then
                                streams="$streams;"
                        fi
                        streams="$streams$stream"
                fi
        done
        /bin/bash /usr/local/nginx/html/conf.sh --streams=$streams
        echo "<h3 color='#FF0000'>Streams where updated.</h3>"
fi

echo "<h3>Enter your streaming URL's</h3>
<p>Each URL will recive the stream that is published to this server.</p>
<p>At least one stream is required.</p>

<form method='GET'>
<p><input name='stream1' width='600px'></p>
<p><input name='stream2' width='600px'></p>
<p><input name='stream3' width='600px'></p>
<p><input name='stream4' width='600px'></p>
<p><input name='stream5' width='600px'></p>
<p><input type=submit value='Update'></p>
</form>
</body>
</html>"
exit 0