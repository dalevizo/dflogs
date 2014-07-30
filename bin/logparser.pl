#!/usr/bin/perl
#variables
$dlimit=10; #defines how many rows to display in every file for daily stats
$mlimit=100000; #defines how many rows to display in every file for monthly temp files
$verbose = $fileformat = $forceprint = 0; #0 - unchecked, 1 - squid, 2 - dansguardian

use Getopt::Long;
GetOptions("daily=s"=>\$dout,
	   "monthly=s"=>\$mout,
	   "limit=i"=>\$dlimit,
	   "verbose"=>\$verbose,
	   "stdout|noprint"=>\$stdout,
	   "help"=>\$help);
if ( $help ) { usage() }

if ( $stdout ) { $dlm='	'; } else { $dlm='|'; }

sub cleanurl {
   my($url) = @_;
   $url =~ s!^https?://(?:www\.)?(?:apps\.)?!!i;   
   $url =~ s!/.*!!;
   $url =~ s/[\?\#\:].*//;
   $cnt = $url =~ tr/\./\./;
   if($cnt > 2 ) {
        @spl=split(/\./,$url,$cnt-1);
        $url = $spl[$cnt-2];
        }
   return $url;
}

sub tmpstamp {
($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst)=localtime(time);
printf OUTPUT "# %s %4d-%02d-%02d %02d:%02d:%02d\n",$ARGV,$year+1900,$mon+1,$mday,$hour,$min,$sec;
}

sub msg {
my($msg,$forceprint)=@_;
if ( $verbose || $forceprint ) {
print "$msg\n";
}
}

sub myopen {
my($filename)=@_;
$table = $filename;
$table =~ s/\.txt//;
$table =~ s/\.tmp//;
if ( $filename =~ /.txt/ ) { $path=$dout; } else { $path=$mout; }
#&msg("printing $table");
if ( $filename =~ /.txt/ ) {
open(OUTPUT,">",$path."/$filename") or die "Unable to open $path/$filename:$!\n";
}
if ( $filename =~ /.tmp/ ) {
open(OUTPUT,">>",$path."/$filename") or die "Unable to open $path/$filename:$!\n";
}
if ( $stdout ) {
&msg("\n$table\n---------------",1);
open(OUTPUT,">&STDOUT") or die "Unable to print to STDOUT:$!\n";
}
}

sub myclose {
if ( $stdout ) {
close(OUTPUT); print "\n"; 
}
else { close(OUTPUT); }
}

sub myprint {
my($str,@args)=@_;
if ( $stdout ) { $str =~ s/\|/	/; } 
printf OUTPUT $str,@args;
}

while(<>) {
#check whether we're reading dansguardian logs or squid logs
unless ($fileformat > 0 ) {
	if (/TCP_/ && /DEFAULT_PARENT/) {
	#ok we're dealing with squid logs
	#define fields
	&msg("parsing squid log");
	$fileformat=1;
	$bytefield=9;
	$serverfield=3;
	$userfield=7;
	$methodfield=8;
	$urlfield=11;
	$bannedkeyword="TCP_DENIED/403"; 
	}

	else {
	#define fields
	&msg("parsing dansguardian log");
	$fileformat=2;
	$bytefield=11;
	$bytefield_exception=15;
	$serverfield=3;
	$userfield=8;
	$methodfield=10;
	$urlfield=9;
	$blockedcategoryfield=17;
	$bannedkeyword="*DENIED*";
        $exceptionkeyword="*EXCEPTION*"; 
	}
	}
if (/dansguardian/) {{
next if /Ignorable/;
next if /clamd\[/;
next if /last message repeated/;
next if /Started sucessfully./;
if ( $lines =~ m/000+$/ ) { &msg("$lines lines parsed so far...\n"); }
	$lines++;
if ($fileformat == 1) {
	#start parsing
    	$totalbytes+=(split)[$bytefield];	
    	$servers{substr((split)[$serverfield],0,7)}++;
    	$users{(split)[$userfield]}++;
    	$usersbytes{(split)[$userfield]} += (split)[$bytefield];
	if ((split)[$methodfield] eq $bannedkeyword ) { $blockedurls{&cleanurl((split)[$urlfield])}++; }
	else { $allowedurls{&cleanurl((split)[$urlfield])}++; $allowedurlsbytes{&cleanurl((split)[$urlfield])} += (split)[$bytefield] }
	}
elsif ($fileformat == 2) {
	#start parsing
	my @tabfields=split(/\t/,$_);
    	$totalbytes+=(split)[$bytefield];	
    	$servers{substr((split)[$serverfield],0,7)}++;
    	$serversbytes{substr((split)[$serverfield],0,7)} += (split)[$bytefield];
	$users{(split)[$userfield]}++;
    	$usersbytes{(split)[$userfield]} += (split)[$bytefield];
	if ($tabfields[13] =~ 'profile') { 	
						$profiles{$tabfields[13]}++;
						$profilesbytes{$tabfields[13]} += (split)[$bytefield];
					 	}
	if ((split)[$methodfield] eq $bannedkeyword ) { 
							$totalblocked++;
							$blockedurls{&cleanurl((split)[$urlfield])}++; 
							$blockedcategory{$tabfields[8]}++;
							$serversblocked{substr((split)[$serverfield],0,7)}++;
							if ($tabfields[13] =~ 'profile') { $profilesblocked{$tabfields[13]}++; }
							}
	else { 
                $allowedurls{&cleanurl((split)[$urlfield])}++; 
                if ((split)[$methodfield] eq $exceptionkeyword ) { 
                $allowedurlsbytes{&cleanurl((split)[$urlfield])} += (split)[$bytefield_exception] }
                else {
                $allowedurlsbytes{&cleanurl((split)[$urlfield])} += (split)[$bytefield]
                }
        }
        }
}} 
if (/clamd/) {{
	if (/FOUND/) {{
		$viruses++;
		$virusname{(split)[6]}++
	}}
}}
}
&msg("total parsed $., total valid $lines lines");
if ( $dout or $stdout ) {
#print daily stats output into text files
#print numbers as strings and use php to format them later
&msg("printing daily stats files");
&myopen("serverhits.txt");
$count=1;
for (sort {$a cmp $b} keys %servers){
	myprint "%s|%s\n",$_,$servers{$_}; $count++;
	}
	myprint "Total|%s",$lines;
&myclose;

&myopen("allowedhits.txt");
$count=1;
for (sort {$allowedurls{$b} <=> $allowedurls{$a}||$a cmp $b} keys %allowedurls){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$allowedurls{$_};
    $count++;
}
	myprint "Total|%s",scalar keys %allowedurls;
&myclose;
&myopen("allowedbytes.txt");
$count=1;
for (sort {$allowedurlsbytes{$b} <=> $allowedurlsbytes{$a}||$a cmp $b} keys %allowedurlsbytes){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$allowedurlsbytes{$_};
    $count++;
}
	myprint "Total|%s",$totalbytes;
&myclose;
&myopen("blockedhits.txt");
$count=1;
for (sort {$blockedurls{$b} <=> $blockedurls{$a}||$a cmp $b} keys %blockedurls){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$blockedurls{$_};
    $count++;
}
	myprint "Total|%s",scalar keys %blockedurls;
&myclose;
&myopen("blockedcategories.txt");
$count=1;
for (sort {$blockedcategory{$b} <=> $blockedcategory{$a}||$a cmp $b} keys %blockedcategory){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$blockedcategory{$_};
    $count++;
}
&myclose;
&myopen("userhits.txt");
$count=1;
for (sort {$users{$b} <=> $users{$a}||$a cmp $b} keys %users){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$users{$_};
    $count++;
}
	myprint "Total|%s",scalar keys %users;
&myclose;
&myopen("usersbytes.txt");
$count=1;
for (sort {$usersbytes{$b} <=> $usersbytes{$a}||$a cmp $b} keys %usersbytes){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$usersbytes{$_};
    $count++;
}
	myprint "Total|%s",$totalbytes;
&myclose;
&myopen("serversbytes.txt");
$count=1;
for (sort {$serversbytes{$b} <=> $serversbytes{$a}||$a cmp $b} keys %serversbytes){
    myprint "%s|%s\n",$_,$serversbytes{$_};
    $count++;
}
	myprint "Total|%s",$totalbytes;
&myclose;
&myopen("profilesbytes.txt");
$count=1;
for (sort {$profilesbytes{$b} <=> $profilesbytes{$a}||$a cmp $b} keys %profilesbytes){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$profilesbytes{$_};
    $count++;
}
	myprint "Total|%s",$totalbytes;
&myclose;
&myopen("profiles.txt");
$count=1;
for (sort {$profiles{$b} <=> $profiles{$a}||$a cmp $b} keys %profiles){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$profiles{$_};
    $count++;
}
	myprint "Total|%s",$lines;
&myclose;
&myopen("serversblocked.txt");
$count=1;
for (sort {$serversblocked{$b} <=> $serversblocked{$a}||$a cmp $b} keys %serversblocked){
    myprint "%s|%s\n",$_,$serversblocked{$_};
    $count++;
}
	myprint "Total|%s",$totalblocked;
&myclose;
&myopen("profilesblocked.txt");
$count=1;
for (sort {$profilesblocked{$b} <=> $profilesblocked{$a}||$a cmp $b} keys %profilesblocked){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$profilesblocked{$_};
    $count++;
    $totalprofilesblocked+=$profilesblocked{$_};
}
	myprint "Total|%s",$totalprofilesblocked;
&myclose;
&myopen("viruses.txt");
$count=1;
for (sort {$virusname{$b} <=> $virusname{$a}||$a cmp $b} keys %virusname){
    last if ($count > $dlimit);	
    myprint "%s|%s\n",$_,$virusname{$_};
    $count++;
}
	myprint "Total|%s",$viruses;
&myclose;
}

if ( $mout ) {
#print monthly temp files
&msg("printing monthly temporary files");
&myopen("serverhits.tmp");
&tmpstamp;
$count=1;
for (sort {$a cmp $b} keys %servers){
	myprint "%s|%s\n",$_,$servers{$_}; $count++;
	}
&myclose;

&myopen("allowedhits.tmp");
&tmpstamp;
$count=1;
for (sort {$allowedurls{$b} <=> $allowedurls{$a}||$a cmp $b} keys %allowedurls){
    last if ($count > $mlimit);
    myprint "%s|%s\n",$_,$allowedurls{$_};	
    $count++;
}
&myclose;
&myopen("allowedbytes.tmp");
&tmpstamp;
$count=1;
for (sort {$allowedurlsbytes{$b} <=> $allowedurlsbytes{$a}||$a cmp $b} keys %allowedurlsbytes){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$allowedurlsbytes{$_};	
    $count++;
}
&myclose;
&myopen("blockedhits.tmp");
&tmpstamp;
$count=1;
for (sort {$blockedurls{$b} <=> $blockedurls{$a}||$a cmp $b} keys %blockedurls){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$blockedurls{$_};	
    $count++;
}
&myclose;
&myopen("blockedcategories.tmp");
&tmpstamp;
$count=1;
for (sort {$blockedcategory{$b} <=> $blockedcategory{$a}||$a cmp $b} keys %blockedcategory){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$blockedcategory{$_};	
    $count++;
}
&myclose;
&myopen("userhits.tmp");
&tmpstamp;
$count=1;
for (sort {$users{$b} <=> $users{$a}||$a cmp $b} keys %users){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$users{$_};	
    $count++;
}
&myclose;
&myopen("usersbytes.tmp");
&tmpstamp;
$count=1;
for (sort {$usersbytes{$b} <=> $usersbytes{$a}||$a cmp $b} keys %usersbytes){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$usersbytes{$_};	
    $count++;
}
&myclose;
&myopen("serversbytes.tmp");
&tmpstamp;
$count=1;
for (sort {$serversbytes{$b} <=> $serversbytes{$a}||$a cmp $b} keys %serversbytes){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$serversbytes{$_};	
    $count++;
}
&myclose;
&myopen("profilesbytes.tmp");
&tmpstamp;
$count=1;
for (sort {$profilesbytes{$b} <=> $profilesbytes{$a}||$a cmp $b} keys %profilesbytes){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$profilesbytes{$_};	
    $count++;
}
&myclose;
&myopen("profiles.tmp");
&tmpstamp;
$count=1;
for (sort {$profiles{$b} <=> $profiles{$a}||$a cmp $b} keys %profiles){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$profiles{$_};	
    $count++;
}
&myclose;
&myopen("serversblocked.tmp");
&tmpstamp;
$count=1;
for (sort {$serversblocked{$b} <=> $serversblocked{$a}||$a cmp $b} keys %serversblocked){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$serversblocked{$_};	
    $count++;
}
&myclose;
&myopen("profilesblocked.tmp");
&tmpstamp;
$count=1;
for (sort {$profilesblocked{$b} <=> $profilesblocked{$a}||$a cmp $b} keys %profilesblocked){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$profilesblocked{$_};	
    $count++;
}
&myclose;
&myopen("viruses.tmp");
&tmpstamp;
$count=1;
for (sort {$virusname{$b} <=> $virusname{$a}||$a cmp $b} keys %virusname){
    last if ($count > $mlimit);	
    myprint "%s|%s\n",$_,$virusname{$_};	
    $count++;
}
&myclose;
}
sub usage {
print <<EOF;
logparser.pl --daily --monthly --verbose --limit --stdout|noprint [input_filename]
This program parses dansguardian logs and it can automatically detect whether if they are in squid format or dansguardian format.
It can either accept a filename as a command line argument or input via STDIN.
--help		prints this help screen
--daily		daily stats output directory
--monthly 	monthly temporary files output directory
--verbose 	print verbose messages
--limit		how many lines to print in each table. Note that it does not apply to tables about
			server statistics (hits per server, bytes per server etc) where it will always display
			all servers.
--stdout|noprint - print results in screen not in files
EOF
exit 1;
}
