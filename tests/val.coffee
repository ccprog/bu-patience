fs = require('fs')
path = require('path')
CoffeeScript = require('coffeescript')
JaySchema = require('jayschema')

verify = (ruleset) ->
    decksize = ruleset.set * ruleset.count
    positions = []

    test_position = (pos, dir, spr) ->
        arr = []
        len = Math.max positions.length, pos.y * 2 + 1
        from = pos.y * 2
        to = pos.y * 2 + 2
        mask = 3 << (pos.x * 2)
        switch dir
            when "down"
                len = Math.max len, pos.y * 2 + spr
                to = (pos.y + spr) * 2
            when "up"
                if pos.y < 2
                    console.error "tableau too far up\n", pos
                    process.exit 1
                from = (pos.y - spr + 1) * 2
            when "right"
                mask = (4^spr-1) << (pos.x * 2)
            when "left"
                if pos.x < 1
                    console.error "tableau too far left\n", pos
                    process.exit 1
                mask = (4^sspr-1) << (pos.x * 2 - 2)
                
        for i in [0...len]
            line = if from <= i < to then mask else 0
            positions[i] ?= 0
            if (line & positions[i]) > 0
                console.error "overlapping position\n", pos
                process.exit 1
            positions[i] |= line

    for pg in ruleset.pilegroups
        for po in pg.piles
            if pg.pileclass is "Tableau"
                direction = po.options?.direction ? pg.options?.direction ? "down"
                spread = po.options?.spread ? pg.options?.spread ? (if direction == "down" then 3 else 2)
            else
                direction = undefined
                spread = undefined
            test_position(po.position, direction, spread)

            initial_facedown = po.options?.initial_facedown ? pg.options?.initial_facedown ? 0
            if pg.pileclass is "Stock" and initial_facedown == 0
                initial_facedown = decksize
            initial_faceup = po.options?.initial_faceup ? pg.options?.initial_faceup ? 0
            if pg.pileclass in ["Tableau", "Reserve"] and initial_faceup == 0
                initial_faceup = 1
            decksize -= initial_facedown + initial_faceup
            if decksize < 0
                console.error "deck couldnt fill pile\n", pile
                process.exit 1
    if decksize > 0
        console.error "deck is not exhausted\n", deck
        process.exit 1
    true

fn = process.argv[2]
source = fs.readFileSync(fn, "utf-8");
if path.extname(fn) is ".coffee"
    script = CoffeeScript.compile(source, { bare: true })
    eval script
else if path.extname(fn) is ".json"
    ruleset = JSON.parse source
else
    console.log "file #{fn} not identified"
    process.exit 1

js = new JaySchema();
list = {}
for part in ['ruleset', 'action', 'evaluate', 'point', 'lib']
    fileContent = fs.readFileSync('src/rulesets/' + part + '_schema', 'utf8')
    list[part] = JSON.parse fileContent
    js.register list[part]

if process.argv.length == 5
    rulepath = process.argv[3].split "/"
    for rp in rulepath
        ruleset = ruleset[rp]
        if not(ruleset?)
            console.log "property #{rp} not found"
            process.exit 1
    schemapath = process.argv[4].split "/"
    schema = list[schemapath.shift()]
    for sp in schemapath
        schema = schema[sp]
        if not(schema?)
            console.log "schema #{sp} not found"
            process.exit 1
else
    schema = list['ruleset']

result = js.validate ruleset, schema
if result[0]
    console.log result[0]
    process.exit 1
else
    console.log "successfully validated"
    if process.argv.length == 3
        verify ruleset
        console.log "successfully verified"
process.exit 0

