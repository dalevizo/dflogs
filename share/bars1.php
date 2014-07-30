<?php
//error_reporting(E_ALL);
//ini_set('display_errors', '1');
include ("jpgraph/src/jpgraph.php");
include ("jpgraph/src/jpgraph_bar.php");
$y=$_GET["y"];
$m=$_GET["m"];
$d=$_GET["d"];
$file=$_GET["file"];
$title=$_GET["title"];
if ($_GET["istraffic"] == "") $istraffic=0; else $istraffic=$_GET["istraffic"];
$graphdata=array();
$graphlegends=array();
$lines = file('../data/'.$y.'/'.$m.'/'.$d.'/'.$file.'.txt', FILE_IGNORE_NEW_LINES);
foreach ($lines as $line_num => $line) {
    $data = explode("|",$line);
	if ($data[0] != "Total") {
    	    array_push($graphlegends,$data[0]);
       	         if ($istraffic == "1") {
       	                 $traff=(real)$data[1]/1024/1024;
       	                 array_push($graphdata,($traff));
       	                 }
       	         else {array_push($graphdata,(int)$data[1]);}
   	 }
}

if(empty($graphlegends)) $graphlegends[0]="N/A";
if(empty($graphdata)) $graphdata[0]="0";

//print_r($graphlegends);
//print_r($graphdata);
// Set the basic parameters of the graph 
$graph = new Graph(650,250,'auto');
$graph->SetScale("textlin");

$graph->Set90AndMargin();

$graph->title->Set($title);
$graph->title->SetFont(FF_VERA,FS_BOLD,10);
$graph->SetFrame(false);
$graph->xaxis->SetTickLabels($graphlegends);
$graph->xaxis->SetFont(FF_VERA,FS_NORMAL,8);
//$graph->yaxis->SetPos('max');
$graph->SetTickDensity(TICKD_SPARSE);


// Some extra margin looks nicer
$graph->xaxis->SetLabelMargin(10);
$graph->SetBox();

// Label align for X-axis
$graph->xaxis->SetLabelAlign('right','center');

// Add some grace to y-axis so the bars doesn't go
// all the way to the end of the plot area
$graph->yaxis->scale->SetGrace(10);

// Now create a bar pot
$bplot = new BarPlot($graphdata);
//$bplot->SetFillColor("lightskyblue");
//$bplot->SetFillGradient('darkred','yellow',GRAD_HOR);
$bplot->SetFillGradient("navy","#EEEEEE",GRAD_LEFT_REFLECTION);

//You can change the width of the bars if you like
$bplot->SetWidth(0.7);

// We want to display the value of each bar at the top
//$bplot->value->Show();
//$bplot->value->SetFont(FF_VERA,FS_NORMAL,10);
//$bplot->value->SetAlign('left','center');
//$bplot->value->SetColor("black","darkred");
//$bplot->value->SetFormat('%.1f');

// Add the bar to the graph
$graph->Add($bplot);

// .. and stroke the graph
$graph->Stroke();

?>
