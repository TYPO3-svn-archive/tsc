<html>
<body>
<h1>Demonstration of the TypoScript Compiler</h1>
<?php controller(); ?>
</body>
</html>
<?php

function controller() {
	require_once('../class.tx_tsc.php');
	exec('ls *.ts', $files);
	foreach($files as $file) {
		print view(model($file));
	}
}

function model($file) {
	$compiler = '../src/tsc';
	$out['file'] = $file;
	foreach(file($file) as $line) {
		$out['typoLines']  .= sprintf("%5d  %s",  ++$i, $line);
		$out['typoScript'] .= $line;
	}
	list($out['array'], $out['errors']) = tx_tsc::compile($out['typoScript'], $compiler);
	return $out;
}

function view($model) {
	extract($model);	
	return sprintf('<h2>Example: %s</h2><h3>Input: </h3><pre>%s</pre><h3>Output: </h3><pre>%s</pre><h3>Errors: </h3><pre>%s</pre>',
				$file, $typoLines,  print_r($array, 1), print_r($errors ? $errors : 'No errors', 1));
}

?>
