<?php 

function get_preset ( $param ) {
    if ( isset($_GET[$param]) ) {
        $preset = urldecode( $_GET[$param] );
        $preset = preg_replace( '/_/', ' ', $preset );
        return strtolower( $preset );
    } else {
        return null;
    }
}

$dataset = '';

function scan_options ( $dir, $param, $callback ) {
    global $dataset;
    $current = null;
    $preset =  get_preset($param);

    $files = scandir($dir);
    $items = array();
    foreach($files as $entry) {
        if (preg_match('/(.*)\\.json$/', $entry, $match)) {
            $item = call_user_func( $callback, $dir, $entry, $match[1]);
            $items[$match[1]] = $item;

            if ( $preset == strtolower($item['read']) ) {
                $current = $match[1];
                $dataset .= 'data-' . $param . '="' . $item['file'] . '" ';
            }
        }
    }

    if (!$current) {
        $current = key($items);
        if ('ruleset' == $param) {
            $dataset .= 'data-standard="' . $items[$current]['file'] . '" ';
        }
    }

    return array(
        'items' => $items,
        'selected' => $current
    );
}

$rules = scan_options('rulesets', 'ruleset', function ($dir, $entry, $key) {
    $content = file_get_contents($dir . "/" . $entry);
    $read = json_decode($content)->title;
    return array(
        "file" => $dir . "/" . $entry,
        "read" => $read
    );
});
$languages = scan_options('lang', 'language', function ($dir, $entry, $key) {
    return array(
        "file" => $dir . "/" . $entry,
        "read" => $key
    );
});

?>
<!DOCTYPE html>
<html dir="ltr" charset="utf-8">
<head>
<meta charset="UTF-8">
<title>Patience</title>
  <script type="application/ecmascript" charset="utf-8" src="lib/d3.v3.js" ></script>
  <script type="application/ecmascript" src="patience.js" ></script>
  <link rel="stylesheet" type="text/css" href="lib/bootstrap/css/bootstrap.css" />
  <link rel="stylesheet" type="text/css" href="patience.css" />
</head>
<body <?php echo $dataset ?>>
  <div id="page">
  <div id="controls" class="">
    <span class="btn-group">
    <button id="prev" class="btn btn-default glyphicon glyphicon-arrow-left" title="Undo"></button>
    <button id="next" class="btn btn-default glyphicon glyphicon-arrow-right" title="Redo"></button>
    </span>
    <select id="ruleset" class="form-control">
<?php
foreach($rules['items'] as $key => $value) {
?>
        <option <?php if($key == $rules['selected']) echo 'selected="selected" ';
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
foreach($languages['items'] as $key => $value) {
?>
        <option <?php if($key == $languages['selected']) echo 'selected="selected" '; 
        ?>value="<?php echo $value['file'] ?>"><?php echo $value["read"]; ?></option>
<?php 
} ?>
    </select>
  </div>
  <div id="notice">
    <h2>Sorry, your browser is too old for this game</h2>
    <p>Please use a modern browser. This game is tested to work with:</p>
    <ul><li>Internet Explorer 11 and Edge</li>
    <li>Chrome 8 and newer</li>
    <li>Firefox 6 and newer</li>
    <li>Safari 6 and newer</li>
    <li>Opera 12 and newer</li></ul>
  </div>
  <div id="area">
  </div>
  </div>
  <script>
try {
    var pad = d3.select("#area");
    var infos = d3.selectAll(".info");
    var presets = d3.select("body").property("dataset");
    var area = new Area(pad, infos, presets);
} catch (e) {
    document.getElementById("notice").setAttribute("style", "display:block;");
}
  </script>
</body>
</html>
