<?
//error_reporting(E_ALL);
//ini_set('display_errors', '1');
require("functions.php");
$y=$_GET["y"];
$m=$_GET["m"];
if ( $y == "" ) { $y=date("Y"); }
if ( $m == "" ) { $m=date("m",mktime(0, 0, 0, date("m"),date("d"),date("Y"))); }
?>

<html>
<head>
<meta http-equiv="content-type" content="text/html; charset=utf-8">
<title>Syzefxis Content Filtering Reports</title>
<link rel="stylesheet" href="/stats/squid.css" type="text/css">
</head>
<body>
<div id="header">Statistics for month <?=date("M Y", mktime(0, 0, 0, $m, 1, $y))?><br>
<a href=/stats/monthly/<?=date("Y/m/", mktime(0, 0, 0, $m-1, 1, $y))?>>Prev Month</a>&nbsp;&nbsp;<a href=/stats/monthly/<?=date("Y/m/", mktime(0, 0, 0, $m+1, 1, $y))?>>Next Month</a><br><br><br>
<div id="container">
<table border=0 align=center>
<?=myrow('serverhits','Hits per server',0,'Total')?>
<?=myrow('serversbytes','Bytes per server',1,'Total')?>
<?=myrow('serversblocked','Blocked per server',0,'Total')?>
<?=myrow('allowedhits','Allowed Domain Hits',0,'Total')?>
<?=myrow('allowedbytes','Allowed Domain Traffic',1,'Total')?>
<?=myrow('userhits','Top users per hit number',0,'Total unique users')?>
<?=myrow('usersbytes','Top users per traffic',1,'Total')?>
<?=myrow('blockedhits','Blocked domain hits',0,'Total blocked domains')?>
<?=myrow('blockedcategories','Blocked categories',0,'Total')?>
<?=myrow('profiles','Hits per profile',0,'Total')?>
<?=myrow('profilesbytes','Bytes per profile',1,'Total')?>
<?=myrow('profilesblocked','Blocked per profile',0,'Total')?>
<?=myrow('viruses','Viruses found',0,'Total')?>
</table>
</div>
<br style="clear: both;" />
</div>
<?#echo "<img src=/stats/pie3d.php?y=$y&m=$m&d=$d&file=serverhits&title=Hits+per+server>"?>
</body>
</html>
