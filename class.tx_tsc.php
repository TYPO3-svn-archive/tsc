<?php

class tx_tsc {
	
	//----------------------------------------------------------------------
	// Static functions
	//----------------------------------------------------------------------

	/**
	 * Compile TS to a PHP array 
	 *
	 * Call as T3 plugin tx_tsc::compile($typoScript);
	 * Call as independent compiler tx_tsc::compile($typoScript, '/path/to/tsc');
	 *
	 * @param    string     Typoscript
	 * @param    string    	Path to the compiler, empty when used as T3 plugin  
	 * @return   array      First entry: PHP array, second: error string. 
	 */

	function compile($typoScript, $compilerPath = NULL) {
		if(!$compilerPath) exit('TODO: Code the call as T3 Plugin path.');
		$errors = '';
		$command = $compilerPath;  	
		$descriptorspec = array(
				0 => array("pipe", "r"),  // stdin is a pipe that the child will read from
				1 => array("pipe", "w"),  // stdout is a pipe that the child will write to
				2 => array("pipe", "w") 	// stderr is  a pipe that the child will write to
				);
		if(!($process = proc_open($command, $descriptorspec, $pipes))) {
			$errors = 'Could not start the TypoScript Compiler.';
		} 
		if(!$errors) {
			$errors = tx_tsc::_writeTypoScript($pipes[0], $typoScript);	
		}
		if(!$errors) {
			$array = tx_tsc::_readArray($pipes[1]);	
			$errors = tx_tsc::_readErrors($pipes[2]);	
		}
		proc_close($process);	
		return array($array, $errors);				
	}

	function _writeTypoScript($pipe, $typoScript) {
		// Write TS
		if(fwrite($pipe, $typoScript)===FALSE){
			$errors = 'Can\'t write to TS Compiler.';
		}	
		fclose($pipe);
		return $errors;
	}

	function _readArray($pipe){
		// Read TS array string
		while(!feof($pipe)){
			$arrayString .= fgets($pipe, 4096);
		}	
		fclose($pipe);

		// Evaluate the array
		$TS = array();
		eval($arrayString);
		return $TS;
	}

	function _readErrors($pipe){
		while(!feof($pipe)){
			$errors .= fgets($pipe, 4096);
		}	
		fclose($pipe);	
		return $errors;
	}
}


?>
