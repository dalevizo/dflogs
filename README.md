dflogs
======

Dansguardian farm logs parser

About

dflogs is a combination of perl scripts and php pages to parse, analyze and display statistics about a serverfarm of dansguardian servers.
The perl scripts parse the combined dansguardian logs and save the produced statistics in txt files.
Then the php page reads these files and displays the statistics in a more friendly format.

History

dflogs was initially written to cover our needs in the company I work for. We have a farm of 12 dansguardian servers and we were unable to find a log parser to do exactly what we wanted to do and so I decided to write one myself.
It's the very first thing I ever wrote in Perl so the code is far from good (I'm not a programmer) but it gets it's work done so I thought I might share and hopefully somebody will find it useful.
