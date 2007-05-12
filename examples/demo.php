<?php

define('COMPILER',  '../src/tsc');
define('LIBRARY',  '../class.tx_tsc.php');

function controller() {
	require_once(LIBRARY);
	exec('ls *.ts', $files);
	foreach($files as $file) {
		print view(model($file));
	}
}

function model($file) {
	$out['file'] = $file;
	foreach(file($file) as $line) {
		$out['typoLines']  .= sprintf("%5d  %s",  ++$i, $line);
		$out['typoScript'] .= $line;
	}
	list($out['array'], $out['errors']) = tx_tsc::compile($out['typoScript'], COMPILER);
	return $out;
}

function view($model) {
	extract($model);	
	return sprintf('<h2>Example: %s</h2><h3>Input: </h3><pre>%s</pre><h3>Output: </h3><pre>%s</pre><h3>Errors: </h3><pre>%s</pre>',
				$file, $typoLines,  print_r($array, 1), print_r($errors ? $errors : 'No errors', 1));
}

?>
<html>
<body>
<h1>Demonstration of the TypoScript Compiler</h1>
<?php controller(); ?>
</body>
</html>
