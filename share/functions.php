<?
//error_reporting(E_ALL);
//ini_set('display_errors', '1');

function myrow($myfile,$myheader,$istraffic,$totaldesc) {
global $y,$m,$d;
$encheader=str_replace(" ","+",$myheader);
echo "<tr><td>";
mytable($myfile,$myheader,$istraffic,$totaldesc);
if ($istraffic == 1) {
echo "</td><td><img align=center src=/stats/bars1.php?y=$y&m=$m&d=$d&file=$myfile&title=$encheader&istraffic=1></td></tr>"; }
else {
echo "</td><td><img align=center src=/stats/bars1.php?y=$y&m=$m&d=$d&file=$myfile&title=$encheader></td></tr>"; }
}

function mytable($myfile,$myheader,$istraffic,$totaldesc) {
$linenum=1;
$myclass="";
global $y,$m,$d;
echo "<table border=0 align=center>";
echo "<tr class=toprow align=center><th colspan=3>$myheader</th></tr>";
$lines = file('../data/'.$y.'/'.$m.'/'.$d.'/'.$myfile.'.txt',FILE_IGNORE_NEW_LINES | FILE_SKIP_EMPTY_LINES);
foreach ($lines as $line_num => $line) {
    $data = explode("|",$line);
if ($data[0] != "Total") {
	if(($linenum%2)!=1) {$myclass="toprow";} else {$myclass="";} ?>
	<tr class=<?=$myclass?>><td><?=$linenum?></td>
	<td><?=$data[0]?></td>
		<? if ($istraffic == "1") {
			$traff=(real)$data[1];
			if ($traff > 1024*1024*1024) {echo "<td>".number_format($traff/1024/1024/1024,2)." GB</td>";}
			elseif ($traff > 1024*1024) {echo "<td>".number_format($traff/1024/1024,2)." MB</td>";}
			else  {echo "<td>".number_format($traff/1024,2)." KB</td>";} 
			}
		else {echo "<td>".number_format($data[1])."</td>";}

?>
	</tr>
	<? $linenum++; }
else {
	echo "<tr class=toprow><th colspan=2 align=right>$totaldesc</th>";
		if ($istraffic == "1") {
		$traff=(real)$data[1];	
		echo "<th>".number_format($traff/1024/1024/1024,2)." GB</th></tr>";} 
	else {echo "<th>".number_format($data[1])."</th></tr>"; }
}
}
echo "</table>";
}

?>
