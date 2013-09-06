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

?>
<!DOCTYPE html>
<html lang="de" dir="ltr" charset="utf-8" manifest="patience.appcache">
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
    <button id="prev" title="Rückgängig">&#8592;</button>
    <button id="next" title="Wiederholen">&#8594;</button>
    <select id="ruleset">
<?php
foreach($rulesets as $key => $value) {
?>
        <option <?php if($key == $rs) echo 'selected="selected" '; 
        ?>value="<?php echo $value['file'] ?>"><?php echo $value["read"]; ?></option>
<?php 
} ?>
    </select>
    <span id="help" class="info" title="Regeln (eigenes Fenster)" style="">?</span>
    <button id="newgame" title="Neues Spiel">&#8634;</button>
    <span id="remaining" class="info">Rest:<span class="data">0</span></span>
    <span id="moves" class="info">Züge:<span class="data">0</span></span>
    <span id="points" class="info">Punkte:<span class="data"></span></span>
    <span id="time" class="info">Zeit:<span class="data"></span></span>
  </div>
  <div id="area">
  </div>
  </div>
</body>
</html>
