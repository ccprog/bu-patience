var CoffeeScript, JaySchema, fileContent, fn, fs, js, list, part, path, result, rp, rulepath, ruleset, schema, schemapath, script, source, sp, verify, _i, _j, _k, _len, _len1, _len2, _ref;

fs = require('fs');

path = require('path');

CoffeeScript = require('coffeescript');

JaySchema = require('jayschema');

verify = function(ruleset) {
  var decksize, direction, initial_facedown, initial_faceup, pg, po, positions, spread, test_position, _i, _j, _len, _len1, _ref, _ref1, _ref10, _ref11, _ref12, _ref13, _ref14, _ref15, _ref16, _ref17, _ref18, _ref2, _ref3, _ref4, _ref5, _ref6, _ref7, _ref8, _ref9;
  decksize = ruleset.set * ruleset.count;
  positions = [];
  test_position = function(pos, dir, spr) {
    var arr, from, i, len, line, mask, to, _i, _results;
    arr = [];
    len = Math.max(positions.length, pos.y * 2 + 1);
    from = pos.y * 2;
    to = pos.y * 2 + 2;
    mask = 3 << (pos.x * 2);
    switch (dir) {
      case "down":
        len = Math.max(len, pos.y * 2 + spr);
        to = (pos.y + spr) * 2;
        break;
      case "up":
        if (pos.y < 2) {
          console.error("tableau too far up\n", pos);
          process.exit(1);
        }
        from = (pos.y - spr + 1) * 2;
        break;
      case "right":
        mask = (4 ^ spr - 1) << (pos.x * 2);
        break;
      case "left":
        if (pos.x < 1) {
          console.error("tableau too far left\n", pos);
          process.exit(1);
        }
        mask = (4 ^ sspr - 1) << (pos.x * 2 - 2);
    }
    _results = [];
    for (i = _i = 0; 0 <= len ? _i < len : _i > len; i = 0 <= len ? ++_i : --_i) {
      line = (from <= i && i < to) ? mask : 0;
      if (positions[i] == null) {
        positions[i] = 0;
      }
      if ((line & positions[i]) > 0) {
        console.error("overlapping position\n", pos);
        process.exit(1);
      }
      _results.push(positions[i] |= line);
    }
    return _results;
  };
  _ref = ruleset.pilegroups;
  for (_i = 0, _len = _ref.length; _i < _len; _i++) {
    pg = _ref[_i];
    _ref1 = pg.piles;
    for (_j = 0, _len1 = _ref1.length; _j < _len1; _j++) {
      po = _ref1[_j];
      if (pg.pileclass === "Tableau") {
        direction = (_ref2 = (_ref3 = (_ref4 = po.options) != null ? _ref4.direction : void 0) != null ? _ref3 : (_ref5 = pg.options) != null ? _ref5.direction : void 0) != null ? _ref2 : "down";
        spread = (_ref6 = (_ref7 = (_ref8 = po.options) != null ? _ref8.spread : void 0) != null ? _ref7 : (_ref9 = pg.options) != null ? _ref9.spread : void 0) != null ? _ref6 : (direction === "down" ? 3 : 2);
      } else {
        direction = void 0;
        spread = void 0;
      }
      test_position(po.position, direction, spread);
      initial_facedown = (_ref10 = (_ref11 = (_ref12 = po.options) != null ? _ref12.initial_facedown : void 0) != null ? _ref11 : (_ref13 = pg.options) != null ? _ref13.initial_facedown : void 0) != null ? _ref10 : 0;
      if (pg.pileclass === "Stock" && initial_facedown === 0) {
        initial_facedown = decksize;
      }
      initial_faceup = (_ref14 = (_ref15 = (_ref16 = po.options) != null ? _ref16.initial_faceup : void 0) != null ? _ref15 : (_ref17 = pg.options) != null ? _ref17.initial_faceup : void 0) != null ? _ref14 : 0;
      if (((_ref18 = pg.pileclass) === "Tableau" || _ref18 === "Reserve") && initial_faceup === 0) {
        initial_faceup = 1;
      }
      decksize -= initial_facedown + initial_faceup;
      if (decksize < 0) {
        console.error("deck couldnt fill pile\n", pile);
        process.exit(1);
      }
    }
  }
  if (decksize > 0) {
    console.error("deck is not exhausted\n", deck);
    process.exit(1);
  }
  return true;
};

fn = process.argv[2];

source = fs.readFileSync(fn, "utf-8");

if (path.extname(fn) === ".coffee") {
  script = CoffeeScript.compile(source, {
    bare: true
  });
  eval(script);
} else if (path.extname(fn) === ".json") {
  ruleset = JSON.parse(source);
} else {
  console.log("file " + fn + " not identified");
  process.exit(1);
}

js = new JaySchema();

list = {};

_ref = ['ruleset', 'action', 'evaluate', 'point', 'lib'];
for (_i = 0, _len = _ref.length; _i < _len; _i++) {
  part = _ref[_i];
  fileContent = fs.readFileSync('src/rulesets/' + part + '_schema', 'utf8');
  list[part] = JSON.parse(fileContent);
  js.register(list[part]);
}

if (process.argv.length === 5) {
  rulepath = process.argv[3].split("/");
  for (_j = 0, _len1 = rulepath.length; _j < _len1; _j++) {
    rp = rulepath[_j];
    ruleset = ruleset[rp];
    if (!(ruleset != null)) {
      console.log("property " + rp + " not found");
      process.exit(1);
    }
  }
  schemapath = process.argv[4].split("/");
  schema = list[schemapath.shift()];
  for (_k = 0, _len2 = schemapath.length; _k < _len2; _k++) {
    sp = schemapath[_k];
    schema = schema[sp];
    if (!(schema != null)) {
      console.log("schema " + sp + " not found");
      process.exit(1);
    }
  }
} else {
  schema = list['ruleset'];
}

result = js.validate(ruleset, schema);

if (result[0]) {
  console.log(result[0]);
  process.exit(1);
} else {
  console.log("successfully validated");
  if (process.argv.length === 3) {
    verify(ruleset);
    console.log("successfully verified");
  }
}

process.exit(0);
