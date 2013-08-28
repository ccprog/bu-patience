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
<html lang="de" dir="ltr" charset="utf-8">
<head>
<meta charset="UTF-8">
<title>Patience</title>
  <script type="application/ecmascript" charset="utf-8" src="lib/d3.v3.js" ></script>
  <script type="application/ecmascript" src="patience.js" ></script>
  <style>
body { font-family:sans-serif;background-color:#005010;margin:0; }
div#controls { margin:1.5em 1em;font-size:1.15em; }
div#area { position:fixed;top:4em;bottom:0;left:0;right:0; }
.stack{position:absolute;z-index:1;}
img {
  position:absolute;
  width:101px;
  height:156px;
}
.stack>img {
  -moz-user-select: none;
  -webkit-user-select: none;
  -ms-user-select: none;
}
form { display:inline; }
button, select, input { margin:0 0.2em;font-size:1em; }
span.info {
  display:inline-block;
  position:relative;
  margin:0 0.2em;
  padding: 0.1em 0.3em;
  background-color:#a0c9a8;
  width:7em; 
}
span.win {
  background-color:white;
}
span.data {
  position:absolute;
  right:0;
  padding-right:0.3em;
}
#help {
    width:auto;
    cursor:pointer;
}

select { width:10em; }
  </style>
</head>
<body onload="init('<?php echo $file ?>')">
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
</body>
</html>
