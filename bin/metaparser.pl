#!/usr/bin/perl
use Getopt::Long;
GetOptions("output=s"=>\$output,
	   "help"=>\$help);
if ( $help ) { usage() }

#variables
$limit=10; #defines how many rows to display in every file
 
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

open(INPUT,"<",$output."/serverhits.tmp") or die "Unable to open $output/serverhits.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$servers{$field} += $data;
	$totalservers += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/allowedhits.tmp") or die "Unable to open $output/allowedhits.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$allowedurls{$field} += $data;
	$totalhits += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/allowedbytes.tmp") or die "Unable to open $output/allowedbytes.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$allowedurlsbytes{$field} += $data;
	$totalbytes += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/blockedhits.tmp") or die "Unable to open $output/blockedhits.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$blockedurls{$field} += $data;
	$totalblocked ++;
	}
close(INPUT);
open(INPUT,"<",$output."/blockedcategories.tmp") or die "Unable to open $output/blockedcategories.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$blockedcategories{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/userhits.tmp") or die "Unable to open $output/userhits.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$users{$field} += $data;
	$totalusers++;
	}
close(INPUT);
open(INPUT,"<",$output."/usersbytes.tmp") or die "Unable to open $output/usersbytes.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$usersbytes{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/serversbytes.tmp") or die "Unable to open $output/serversbytes.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$serversbytes{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/profilesbytes.tmp") or die "Unable to open $output/profilesbytes.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$profilesbytes{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/profiles.tmp") or die "Unable to open $output/profiles.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$profiles{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/serversblocked.tmp") or die "Unable to open $output/serversblocked.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$serversblocked{$field} += $data;
	}
close(INPUT);
open(INPUT,"<",$output."/profilesblocked.tmp") or die "Unable to open $output/profilesblocked.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$profilesblocked{$field} += $data;
	$totalprofilesblocked++;
	}
close(INPUT);
open(INPUT,"<",$output."/viruses.tmp") or die "Unable to open $output/viruses.tmp:$!\n";
while(<INPUT>) {
next if /^#/;
	my($field,$data)=split(/\|/,$_);
	$virusname{$field} += $data;
	$viruses++;
	}
close(INPUT);

open(OUTPUT,">",$output."/serverhits.txt") or die "Unable to open $output/serverhits.txt:$!\n";
$count=1;
for (sort {$a cmp $b} keys %servers){
	printf OUTPUT "%s|%s\n",$_,$servers{$_}; $count++;
	}
	printf OUTPUT "Total|%s\n",$totalservers;
close(OUTPUT);

open(OUTPUT,">",$output."/allowedhits.txt") or die "Unable to open $output/allowedhits.txt:$!\n";
$count=1;
for (sort {$allowedurls{$b} <=> $allowedurls{$a}||$a cmp $b} keys %allowedurls){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$allowedurls{$_};
    $count++;
}
	printf OUTPUT "Total|%s",$totalhits;
close(OUTPUT);
open(OUTPUT,">",$output."/allowedbytes.txt") or die "Unable to open $output/allowedbytes.txt:$!\n";
$count=1;
for (sort {$allowedurlsbytes{$b} <=> $allowedurlsbytes{$a}||$a cmp $b} keys %allowedurlsbytes){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$allowedurlsbytes{$_};
    $count++;
}
	printf OUTPUT "Total|%s",$totalbytes;
close(OUTPUT);
open(OUTPUT,">",$output."/blockedhits.txt") or die "Unable to open $output/blockedhits.txt:$!\n";
$count=1;
for (sort {$blockedurls{$b} <=> $blockedurls{$a}||$a cmp $b} keys %blockedurls){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$blockedurls{$_};
    $count++;
}
	printf OUTPUT "Total|%s",$totalblocked;
close(OUTPUT);
open(OUTPUT,">",$output."/blockedcategories.txt") or die "Unable to open $output/blockedcategories.txt:$!\n";
$count=1;
for (sort {$blockedcategories{$b} <=> $blockedcategories{$a}||$a cmp $b} keys %blockedcategories){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$blockedcategories{$_};
    $count++;
}
close(OUTPUT);
open(OUTPUT,">",$output."/userhits.txt") or die "Unable to open $output/userhits.txt:$!\n";
$count=1;
for (sort {$users{$b} <=> $users{$a}||$a cmp $b} keys %users){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$users{$_};
    $count++;
}
	printf OUTPUT "Total|%s",$totalusers;
close(OUTPUT);
open(OUTPUT,">",$output."/usersbytes.txt") or die "Unable to open $output/usersbytes.txt:$!\n";
$count=1;
for (sort {$usersbytes{$b} <=> $usersbytes{$a}||$a cmp $b} keys %usersbytes){
    last if ($count > $limit);	
    printf OUTPUT "%s|%s\n",$_,$usersbytes{$_};
    $count++;
}
	printf OUTPUT "Total|%s",$totalbytes;
close(OUTPUT);
open(OUTPUT,">",$output."/serversbytes.txt") or die "Unable to open $output/serversbytes.txt:$!\n";
$count=1;
for (sort {$serversbytes{$b} <=> $serversbytes{$a}||$a cmp $b} keys %serversbytes){
    printf OUTPUT "%s|%s\n",$_,$serversbytes{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$totalbytes;
close(OUTPUT);
open(OUTPUT,">",$output."/profilesbytes.txt") or die "Unable to open $output/profilesbytes.txt:$!\n";
$count=1;
for (sort {$profilesbytes{$b} <=> $profilesbytes{$a}||$a cmp $b} keys %profilesbytes){
    last if ($count > $limit);
    printf OUTPUT "%s|%s\n",$_,$profilesbytes{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$totalbytes;
close(OUTPUT);
open(OUTPUT,">",$output."/profiles.txt") or die "Unable to open $output/profiles.txt:$!\n";
$count=1;
for (sort {$profiles{$b} <=> $profiles{$a}||$a cmp $b} keys %profiles){
    last if ($count > $limit);
    printf OUTPUT "%s|%s\n",$_,$profiles{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$lines;
close(OUTPUT);
open(OUTPUT,">",$output."/serversblocked.txt") or die "Unable to open $output/serversblocked.txt:$!\n";
$count=1;
for (sort {$serversblocked{$b} <=> $serversblocked{$a}||$a cmp $b} keys %serversblocked){
    printf OUTPUT "%s|%s\n",$_,$serversblocked{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$totalblocked;
close(OUTPUT);
open(OUTPUT,">",$output."/profilesblocked.txt") or die "Unable to open $output/profilesblocked.txt:$!\n";
$count=1;
for (sort {$profilesblocked{$b} <=> $profilesblocked{$a}||$a cmp $b} keys %profilesblocked){
    last if ($count > $limit);
    printf OUTPUT "%s|%s\n",$_,$profilesblocked{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$totalprofilesblocked;
close(OUTPUT);
open(OUTPUT,">",$output."/viruses.txt") or die "Unable to open $output/viruses.txt:$!\n";
$count=1;
for (sort {$virusname{$b} <=> $virusname{$a}||$a cmp $b} keys %virusname){
    last if ($count > $limit);
    printf OUTPUT "%s|%s\n",$_,$virusname{$_};
    $count++;
}
        printf OUTPUT "Total|%s",$viruses;
close(OUTPUT);

sub usage {
print <<EOF;
Parses .tmp files from monthlogparser.pl and outputs .txt files in the same directory
--help - print this help screen
--output - output (in this case also input) directory
EOF
exit 1;
}

