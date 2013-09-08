<?php 
$dir = "rulesets";
$files = scandir($dir);
$rulesets = array();
foreach($files as $entry) {
    if (preg_match('/(.*)\\.json$/', $entry, $match)) {
        $content = file_get_contents($dir . "/" . $entry);
        $rulesets[$match[1]] = array(
            "file" => $dir . "/" . $entry,
            "read" => json_decode($content)->title
        );
    }
}

$rs = key($rulesets);
$file = current($rulesets)["file"];
$read = current($rulesets)["read"];

$dir = "lang";
$files = scandir($dir);
$languages = array();
foreach($files as $entry) {
    if (preg_match('/(.*)\\.json$/', $entry, $match)) {
        $languages[$match[1]] =  $dir . "/" . $entry;
    }
}

$lg = "en";

?>
<!DOCTYPE html>
<html dir="ltr" charset="utf-8" manifest="patience.appcache">
<head>
<meta charset="UTF-8">
<title>Patience</title>
  <script type="application/ecmascript" charset="utf-8" src="lib/d3.v3.js" ></script>
  <script type="application/ecmascript" src="patience.js" ></script>
  <link rel="stylesheet" type="text/css" href="patience.css" />
</head>
<body onload="init('<?php echo $file ?>')">
  <div id="page">
  <div id="controls">
    <button id="prev" title="Undo">&#8592;</button>
    <button id="next" title="Redo">&#8594;</button>
    <select id="ruleset">
<?php
foreach($rulesets as $key => $value) {
?>
        <option <?php if($key == $rs) echo 'selected="selected" '; 
        ?>value="<?php echo $value['file'] ?>"><?php echo $value["read"]; ?></option>
<?php 
} ?>
    </select>
    <span id="help" class="info" title="Rules (own window)">?</span>
    <button id="newgame" title="New game">&#8634;</button>
    <span id="remaining" class="info">Tail:<span class="data">0</span></span>
    <span id="moves" class="info">Moves:<span class="data">0</span></span>
    <span id="points" class="info">Score:<span class="data"></span></span>
    <span id="time" class="info">Time:<span class="data"></span></span>
    <select id="language" title="Language">
<?php
foreach($languages as $key => $value) {
?>
        <option <?php if($key == $rs) echo 'selected="selected" '; 
        ?>value="<?php echo $value; ?>"><?php echo $key; ?></option>
<?php 
} ?>
    </select>
  </div>
  <div id="area">
  </div>
  </div>
</body>
</html>
