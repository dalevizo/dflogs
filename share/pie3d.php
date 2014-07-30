<?
include ("jpgraph/src/jpgraph.php");
include ("jpgraph/src/jpgraph_pie.php");
include ("jpgraph/src/jpgraph_pie3d.php");
$y=$_GET["y"];
$m=$_GET["m"];
$d=$_GET["d"];
$file=$_GET["file"];
$title=$_GET["title"];

$graphdata=array();
$graphlegends=array();
$lines = file('../data/'.$y.'/'.$m.'/'.$d.'/'.$file.'.txt', FILE_IGNORE_NEW_LINES);
foreach ($lines as $line_num => $line) {
    $data = explode(" ",$line);
    if ($data[0] != "Total") {
	array_push($graphlegends,$data[0]);
        array_push($graphdata,$data[1]); }
    }
//print_r($graphlegends);
//print_r($graphdata);
// Create the Pie Graph.
$graph = new PieGraph(400,250,"auto");
$graph->SetShadow();

// Set A title for the plot
$graph->title->Set($title);
$graph->title->SetFont(FF_VERA,FS_NORMAL,16);
$graph->title->SetColor("darkblue");
$graph->legend->Pos(0.015,0.2);

// Create pie plot
$p1 = new PiePlot3d($graphdata);
$p1->SetTheme("earth");
$p1->SetCenter(0.44);
//$p1->SetAngle(45);
$p1->value->SetFont(FF_VERA,FS_NORMAL,10);
$p1->SetLegends($graphlegends);

$graph->Add($p1);
$graph->Stroke();

?>
