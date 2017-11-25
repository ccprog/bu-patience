#!/usr/bin/nodejs

var fs   = require('fs');
var path = require('path');
var CoffeeScript = require('coffeescript');

process.chdir(path.dirname(process.argv[1]));

var source = fs.readFileSync("rulefactory.coffee", "utf-8");

var rx_schema = /# output-start validate\n([^]+?)# output-end validate/g;
var schema = "", res = [];
while (true) {
    res = rx_schema.exec(source);
    if (!res) {
        break; 
    }
    schema += res[1];
}

var script = CoffeeScript.compile(schema, { bare: true });
eval(script);
for (name in exports) {
    var json = JSON.stringify(exports[name], null, 2);
    fs.writeFileSync("../src/rulesets/" + name, json);
}

var rx_factory = /# output-start rulefactory\n([^]+?)# output-end rulefactory/g;
var factory = "", res = [];
while (true) {
    res = rx_factory.exec(source);
    if (!res) {
        break; 
    }
    factory += res[1];
}

fs.writeFileSync("patience_factory.coffee", factory);
