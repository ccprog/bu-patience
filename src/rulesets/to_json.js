#!/usr/bin/nodejs

var fs = require('fs');
var path = require('path');
var CoffeeScript = require('coffeescript');

process.chdir(path.dirname(process.argv[1]));

var source = fs.readFileSync(process.argv[2], "utf-8");
var script = CoffeeScript.compile(source, { bare: true });

eval(script);

var json = JSON.stringify(ruleset);
var name = process.argv[3] + path.basename(process.argv[2], ".coffee") + ".json";
fs.writeFileSync(name, json);
