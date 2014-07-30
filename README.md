dflogs
======

Dansguardian farm logs parser

About
-----
dflogs is a combination of perl scripts and php pages to parse, analyze and display statistics about a serverfarm of dansguardian servers.
The perl scripts parse the combined dansguardian logs and save the produced statistics in txt files.
Then the php page reads these files and displays the statistics in a more friendly format.

History
-------
dflogs was initially written to cover our needs in the company I work for. We have a farm of 12 dansguardian servers and we were unable to find a log parser to do exactly what we wanted to do and so I decided to write one myself.
It's the very first thing I ever wrote in Perl so the code is far from good (I'm not a programmer) but it gets it's work done so I thought I might share and hopefully somebody will find it useful.

Usage
-----
### Analyze phase (Perl)

The perl scripts can accept a filename as input in the command line or STDIN. In any case it must be a combined log of all servers (we have every server logging to a central syslog server).
logparser.pl

Produces daily and temporary monthly statistics (more on that later) and outputs the result in text files in the specified directory. The php pages however expect to find those txt files in the "data" directory so if you change the output directory you should update the php scripts too.
metaparser.pl

Parses the .tmp files produced my logparser.pl and produces the final txt files with the combined monthly statistics. The reason for two different parsers for the monthly logs is simply log files sizes. In cases where the log files are too big and it would take a very long time to parse all of them each month, I decided to parse each one separately (together with the daily stats parsing), save the temporary "state" of the parser and next day continue where we left off. Each day (or whenever you like) metaparser.pl runs, reads the "state" files and produces up-to-date monthly statistics.

### Presentation phase (PHP)

The PHP pages parse the local txt files and present them in the more user-friendly format.

The statistics generated are these :

- Hits per server
- Bytes per server
- Blocked per server
- Allowed Domain Hits
- Allowed Domain Traffic
- Top users per hit number
- Top users per traffic
- Blocked domain hits
- Blocked categories
- Hits per profile
- Bytes per profile
- Blocked per profile
- Viruses found 

I believe you'll understand most of them but I'll explain a bit more when I find some more time. A note about the last table "Viruses found". In our environment dansguardian is configured to use ClamAV for scanning and that particular filter is written with that in mind. If you have some other antivirus scanner and you would like a filter for that too, just send me a few lines from your logfiles and I'll see what I can do. 

Installation
-----------
Not much to say here.

The share directory contains a .htaccess file with some useful rewrite rules so you can use the more friendly /stats/2009/12/31 url instead of /stats/index.php?y=2009&m=12&d=31 In order to work you need to put this

> AllowOverride All

in your apache config for the specific directory.

Of course you can always add the rules straight into the apache conf file.

><Directory /usr/local/dflogs/share>
>        Options Indexes FollowSymlinks
>        RewriteEngine on
>        RewriteRule ([0-9]+)/([0-9]+)/([0-9]+)/?$ /stats/index.php?y=$1&m=$2&d=$3 [L]
>        RewriteRule monthly/([0-9]+)/([0-9]+)/?$ /stats/monthly.php?y=$1&m=$2 [L]
>        RewriteRule monthly/?$ /stats/monthly.php [L]
></Directory>


