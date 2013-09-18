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
$curr = current($rulesets);
$file = $curr["file"];
$read = $curr["read"];

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
  <link rel="stylesheet" type="text/css" href="lib/bootstrap/css/bootstrap.css" />
  <link rel="stylesheet" type="text/css" href="patience.css" />
</head>
<body data-standard="<?php echo $file ?>">
  <div id="page">
  <div id="controls" class="">
    <span class="btn-group">
    <button id="prev" class="btn btn-default glyphicon glyphicon-arrow-left" title="Undo"></button>
    <button id="next" class="btn btn-default glyphicon glyphicon-arrow-right" title="Redo"></button>
    </span>
    <select id="ruleset" class="form-control">
<?php
foreach($rulesets as $key => $value) {
?>
        <option <?php if($key == $rs) echo 'selected="selected" '; 
        ?>value="<?php echo $value['file'] ?>"><?php echo $value["read"]; ?></option>
<?php 
} ?>
    </select>
    <span id="help" class="info" title="Rules (own window)">?</span>
    <button id="newgame" class="btn btn-default glyphicon glyphicon-repeat" title="New game"></button>
    <span id="remaining" class="info">Tail:<span class="data">0</span></span>
    <span id="moves" class="info">Moves:<span class="data">0</span></span>
    <span id="points" class="info">Score:<span class="data"></span></span>
    <span id="time" class="info">Time:<span class="data"></span></span>
    <select id="language" class="form-control input-sm" title="Language">
<?php
foreach($languages as $key => $value) {
?>
        <option <?php if($key == $rs) echo 'selected="selected" '; 
        ?>value="<?php echo $value; ?>"><?php echo $key; ?></option>
<?php 
} ?>
    </select>
  </div>
  <div id="notice">
    <h2>Sorry, your browser is too old for this game</h2>
    <p>Please use a modern browser. This game is tested to work with:</p>
    <ul><li>Internet Explorer 9 and newer (not available for Windows XP)</li>
    <li>Chrome 5 and newer</li>
    <li>Firefox 4 and newer</li>
    <li>Safari 5 and newer</li>
    <li>Opera 11.6 and newer</li></ul>
  </div>
  <div id="area">
  </div>
  </div>
  <script>
try {
    var pad = d3.select("#area");
    var infos = d3.selectAll(".info");
    var standard = d3.select("body").attr("data-standard");
    var area = new Area(pad, infos, standard);
} catch (e) {
    document.getElementById("notice").setAttribute("style", "display:block;");
}
  </script>
</body>
</html>
