<?php
$dir = 'sound/';
$a = scandir($dir);
$b=count($a);
$res = array();
for($x=2;$x<$b;$x++)
   {
	  // $res.= ""
	 //$res.= $a[$x];
	 array_push($res,$a[$x]);

    // $res.= "<div class='filePass'>";
    // $res.= $a[$x];
    // $res.= "</div>";
   }
echo json_encode($res);

?>