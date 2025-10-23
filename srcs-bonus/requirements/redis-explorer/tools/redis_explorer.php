<?php

# backend logic to handle Redis commands
# process user-submitted commands, establish connection to Redis server,
# execute commands and capture the result or any errors.

$host = 'redis';
$port = 6379;
$output = '';

if ($_SERVER['REQUEST_METHOD'] === 'POST' && !empty($_POST['command'])) { # Listen for POST request with 'command' parameter
	$command_line = trim($_POST['command']);
	$parts = preg_split('/\s+/', $command_line); // \s : whitespace character; + : one or more; / : delimiter

	try {
		$redis = new Redis();
		$redis->connect($host, $port); // connect to Redis server

		// Execute the command dynamically using the array of arguments
		$result = call_user_func_array([$redis, 'rawCommand'], $parts);

		// capture the output as a human-readable string
		$output = print_r($result, true);

	} catch (RedisException $e) {
		$output = 'REDIS CONNECTION ERROR: ' . $e->getMessage();
	} catch (Exception $e) {
		$output = 'PHP ERROR: ' . $e->getMessage();
	}
}

?>
<!DOCTYPE html> <!-- HTML structure for the web interface -->
<html>
<head>
	<title>Redis CLI Explorer</title>
	<style>
		body { font-family: monospace; padding: 20px; }
		.container { max-width: 800px; margin: 0 auto; }
		textarea, input[type="text"] { width: 100%; padding: 10px; margin-bottom: 10px; box-sizing: border-box; } /* input field */
		input[type="submit"] { background-color: #f44336; color: white; padding: 10px 15px; border: none; cursor: pointer; } /* button */
		pre { background-color: #eee; padding: 10px; border: 1px solid #ccc; white-space: pre-wrap; overflow-wrap: break-word; } /* output area */
		.title { color: #f44336; }
	</style>
</head>

<body> <!-- Start of visible HTML content -->
	<div class="container">
		<h2 class="title">Redis CLI Explorer</h2>
		<p>Connected to: **<?php echo htmlspecialchars("{$host}:{$port}"); ?>**</p> <!-- htmlspecialchars to prevent code injection -->

		<form method="POST"> <!-- POST form to submit Redis commands, triggers PHP script above -->
			<label for="command">Enter Redis Command (e.g., GET mykey, KEYS *, INFO):</label>
			<input type="text" id="command" name="command" value="<?php echo htmlspecialchars($command_line ?? ''); ?>" required>
			<input type="submit" value="Execute">
		</form>

		<?php if ($output): ?> <!-- if there is output, display it -->
			<h3>Output:</h3>
			<pre><?php echo htmlspecialchars($output); ?></pre>
		<?php endif; ?>
	</div>

</body>
</html>
