<?php
// $myfile = fopen("fopentest.txt", "w","/testOut");

$filename = $_POST['filename'];
$data = $_POST['filedata'];

try{
//$myfile = fopen("data/Phase1Data.txt", "a+") ;
// int fwrite ( resource $myfile , string $data );
file_put_contents($filename, $data);
//fwrite($myfile,$data);
//fclose($myfile);
chmod($filename,0770);
echo("hi");


}catch(Exception $ex){
	echo("break");
}

?>
