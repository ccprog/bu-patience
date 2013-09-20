## On compilation, this file is splitted:
## parts between output-start rulefactory and output-end rulefactory comments
## form a coffeescript compiled as part of the patience.js file,
## containing the base and rulefactory objects
## parts between output-start validate and output-end validate comments
## are first compiled from coffescript and then directly interpreted as a nodejs module
## The exported objects are the recorded as the json schema files used to validate
## json ruleset files

## base structures

# output-start rulefactory
base =
    pile_classes:
        "Cell": Cell,
        "Foundation": Foundation,
        "Tableau": Tableau,
        "Stock": Stock,
        "Waste": Waste
        "Reserve": Reserve

    suit_names: ["club", "diamond", "heart", "spade"]

    shuffle: (array) ->
        m = array.length
        while m
            i = Math.floor Math.random() * m--
            t = array[m]
            array[m] = array[i]
            array[i] = t
        array
# output-end rulefactory

## A number of name lists are reused in the validation of rulesets, so these are doubled up
## for schema objects

# output-start validate
names = do () ->
# output-end validate
# output-start rulefactory
rulefactory = do () ->
# output-start validate

## compare function
    compare =
        "==": (val1, val2) -> val1 == val2
        "!=": (val1, val2) -> val1 != val2
        "<": (val1, val2) -> val1 < val2
        "<=": (val1, val2) -> val1 <= val2
        ">": (val1, val2) -> val1 > val2
        ">=": (val1, val2) -> val1 >= val2

## computation functions
    operator =
        "plus": (val1, val2) ->
            val1 + val2
        "diff": (val1, val2) ->
            val1 - val2
        "abs_diff": (val1, val2) ->
            Math.abs(val1 - val2)
        "wrapped_diff": (val1, val2, neg) ->
            (val1 - val2 + 13) % 13 - if neg then 13 else 0
        "wrapped_abs_diff": (val1, val2) ->
            d = Math.abs(val1 - val2) % 13
            Math.min(d, 13 - d)
        "multi": (val1, val2) ->
            val1 * val2
        "division": (val1, val2) ->
            if val2 < val1 then (val2 + 13) / val1 else val2 / val1
        "max": (val1, val2) ->
            Math.max(val1, val2)
        "min": (val1, val2) ->
            Math.min(val1, val2)

## card properties
    numeric_card_props =
        "value": (card) -> card.value

    numeric_card_prop_names = Object.keys numeric_card_props

    string_card_props =
        "color": (card) -> card.getColor()
        "suit": (card) -> card.suit

## pile properties
    numeric_pile_props =
        "index": (pile, piles) -> piles.indexOf pile
        "position_x": (pile, piles) -> pile.position.x
        "position_y": (pile, piles) -> pile.position.y
        "facedown_length": (pile, piles) -> pile.facedown_cards.length
        "faceup_length": (pile, piles) -> pile.faceup_cards.length
        "total_length": (pile, piles) -> pile.total_length()

    numeric_pile_prop_names = Object.keys numeric_pile_props

    pile_role_names = ["self", "other"]

    string_pile_props =
        "pileclass": (pile, self, other) -> pile.classname
        "role": (pile, self, other) ->
                if pile is self
                    pile_role_names[0]
                else if pile is other
                    pile_role_names[1]
                else
                    "none"
# output-end rulefactory

## export string enumerations
    return {
        suit: ["club", "diamond", "heart", "spade"]
        color: ["red", "black"]
        pileclass: ["Cell", "Foundation", "Tableau", "Stock", "Waste", "Reserve"]

        compare: Object.keys compare
        operator: Object.keys operator

        numeric_card_prop: numeric_card_prop_names
        string_card_prop: Object.keys string_card_props

        numeric_pile_prop: numeric_pile_prop_names
        string_pile_prop: Object.keys string_pile_props

        pile_role: pile_role_names
        pile_part: ["facedown", "faceup"]

        direction: ["recto", "verso"]

        action: ["click", "dblclick", "build"]
    }

## schema library

lib_schema =
    $schema: "http://json-schema.org/draft-04/schema#"
    id: "http://patience.intern/rulesets/lib_schema#"
    definitions: {}

## shorthands

lib_direction =
    enum: names.direction
    default: "recto"

lib_posint_0 =
    type: "integer"
    minimum: 0

lib_posint_1 =
    type: "integer"
    minimum: 0

## select one entry in an array by numerical position

lib_schema.definitions.position =
    type: "object"
    oneOf: [
        required: [ "position" ]
        additionalProperties: false
        properties:
            dir: lib_direction
            position: lib_posint_0
    ,
        required: [ "dir" ]
        additionalProperties: false
        properties:
            dir:
                enum: [ "random" ]
    ]
# output-end validate
# output-start rulefactory
    position = (sel, array) ->
        if not array.length then return null
        if sel.dir is "random"
            pos = Math.floor(Math.random() * array.length)
        else if sel.dir is "verso"
            pos = array.length - 1 - sel.position
        else
            pos = sel.position
        array[pos]
# output-end rulefactory

## return a slice of an array

# output-start validate
lib_schema.definitions.range =
    type: "object"
    additionalProperties: false
    properties:
        from: lib_posint_0
        to: lib_posint_0
        dir: lib_direction
    anyOf: [
        { required: [ "from" ] },
        { required: [ "to" ] }
    ]
# output-end validate
# output-start rulefactory
    range = (sel, array) ->
        from = sel.from ? 0
        to = sel.to ? array.length
        if sel.dir is "verso"
            array.slice(array.length - to, array.length - from)
        else
            array.slice(from, to)
# output-end rulefactory

## names for comparisons and computations

# output-start validate
lib_schema.definitions.compare =
    enum: names.compare
    default: "=="

lib_schema.definitions.operator =
    enum: names.operator

## restrictions for values used in computations

lib_schema.definitions.length_compute =
    type: "integer"
lib_schema.definitions.card_compute =
    type: "integer"
lib_schema.definitions.pile_compute =
    type: "number"
    multipleOf: 0.5

lib_schema.definitions.length = lib_posint_0

lib_schema.definitions.card_value =
    oneOf: [
        type: "integer"
        minimum: 1
        maximum: 13
    ,
        enum: names.suit.concat names.color
    ]

## return a card property

lib_schema.definitions.card_prop =
    enum: names.card_prop
# output-end validate
# output-start rulefactory
    card_prop = (prop, card) ->
        if numeric_card_prop_names.indexOf(prop) > -1
            numeric_card_props[prop](card)
        else
            string_card_props[prop](card)
# output-end rulefactory

## test one card for a property

# output-start validate
lib_schema.definitions.card_test =
    type: "object"
    required: [ "prop", "value" ]
    additionalProperties: false
    properties:
        prop: { $ref: "#/definitions/card_prop" }
        compare: { $ref: "#/definitions/compare" }
        value: { $ref: "#/definitions/card_value" }
# output-end validate
# output-start rulefactory
    card_test = (test, card) ->
        val = card_prop(test.prop, card)
        compare[test.compare ? "=="](val, test.value)
# output-end rulefactory

## test one card for a list of properties

# output-start validate
lib_schema.definitions.card_test_list =
    type: "array"
    items: { $ref: "#/definitions/card_test" }
# output-end validate
# output-start rulefactory
    card_test_list = (tests, card) ->
        test = true
        for t in tests
            test &&= card_test t, card
            if not test then return false
        test
# output-end rulefactory

## compare two cards in regard to a property

# output-start validate
lib_schema.definitions.card_pair_test =
    type: "object"
    required: [ "prop" ]
    additionalProperties: false
    properties:
        prop: { $ref: "#/definitions/card_prop" }
        compare: { $ref: "#/definitions/compare" }
        operator: { $ref: "#/definitions/operator" }
        value: { $ref: "#/definitions/card_compute" }
    dependencies:
        value: [ "operator" ]
# output-end validate
# output-start rulefactory
    card_pair_test = (test, card1, card2) ->
        val1 = card_prop test.prop, card1
        val2 = card_prop test.prop, card2
        if test.operator?
            res = operator[test.operator](val1, val2, test.value < 0)
            compare[test.compare ? "=="](res, test.value)
        else
            compare[test.compare ? "=="](val1, val2)
# output-end rulefactory

## compare two cards in regard to a list of properties

# output-start validate
lib_schema.definitions.card_pair_test_list =
    type: "array"
    items: { $ref: "#/definitions/card_pair_test" }
# output-end validate
# output-start rulefactory
    card_pair_test_list = (tests, card1, card2) ->
        test = true
        for t in tests
            test &&= card_pair_test t, card1, card2
            if not test then return false
        test
# output-end rulefactory

## select one card from a list of cards, either by property or by position in the list

# output-start validate
lib_schema.definitions.single_card =
    type: "object"
    additionalProperties: false
    maxProperties: 1
    properties:
        single_tests: { $ref: "#/definitions/card_test_list" }
        position: { $ref: "#/definitions/position" }
    oneOf: [
        { required: [ "single_tests" ] },
        { required: [ "position" ] }
    ]
# output-end validate
# output-start rulefactory
    single_card = (sel, cards) ->
        if sel.position?
            return position sel.position, cards
        else
            for card in cards
                if card_test_list sel.single_tests, card
                    return card
            return null
# output-end rulefactory

## filter a list of cards by one criterium:
## range: positional selection
## single_tests: selection by a list of card properties
## pairwise_tests: compare two adjoining cards and select one
## comparison_tests: compare any two cards and select one
## dir: recto selects the first, verso the second in array order

# output-start validate
lib_schema.definitions.card_selection =
    type: "object"
    additionalProperties: false
    properties:
        range: { $ref: "#/definitions/range" }
        single_tests: { $ref: "#/definitions/card_test_list" }
        pairwise_tests: { $ref: "#/definitions/card_pair_test_list" }
        comparison_tests: { $ref: "#/definitions/card_pair_test_list" }
        dir: lib_direction
    oneOf: [
        required: [ "range" ]
        maxProperties: 1
    ,
        required: [ "single_tests" ]
        maxProperties: 1
    ,
        required: [ "pairwise_tests" ]
        maxProperties: 2
        dependencies: # not enough
            dir: [ "pairwise_tests" ]
    ,
        required: [ "comparison_tests" ]
        maxProperties: 2
        dependencies:
            dir: [ "comparison_tests" ]
    ]
# output-end validate
# output-start rulefactory
    card_selection = (sel, card_infos) ->
        list = []
        if sel.range?
            return range sel.range, card_infos
        else if sel.single_tests?
            for entry in card_infos
                if card_test_list sel.single_tests, entry.card
                    list.push entry
        else if sel.comparison_tests?
            for e2, i2 in card_infos[1..]
                for e1, i1 in card_infos[0..i2]
                    if card_pair_test_list sel.comparison_tests, e1.card, e2.card
                        entry = if sel.dir is "verso" then e2 else e1
                        list.push entry
        else if sel.pairwise_tests?
            for e, i in card_infos[1..]
                if card_pair_test_list sel.pairwise_tests, card_infos[i].card, e.card
                    entry = if sel.dir is "verso" then e else card_infos[i]
                    list.push entry
        list
# output-end rulefactory

## concatenate multiple filtered card lists

# output-start validate
lib_schema.definitions.card_selection_list =
    type: "array"
    items: { $ref: "#/definitions/card_selection" }
# output-end validate
# output-start rulefactory
    card_selection_list = (selections, card_infos) ->
        list = []
        for sel in selections
            list = list.concat card_selection(sel, card_infos)
        list
# output-end rulefactory

## compare the length of a list of cards to a value

# output-start validate
lib_schema.definitions.card_sequence_count =
    type: "object"
    required: [ "value" ]
    additionalProperties: false
    properties:
        compare: { $ref: "#/definitions/compare" }
        value: { $ref: "#/definitions/length" }
# output-end validate
# output-start rulefactory
    card_sequence_count = (test, cards) ->
        compare[test.compare ? "=="](cards.length, test.value)
# output-end rulefactory

## return either all facedown or all faceup cards in a pile,
## cards a wrapped in an object describing their position in the game

# output-start validate
lib_schema.definitions.part_selection =
    enum: names.pile_part
# output-end validate
# output-start rulefactory
    part_selection = (name, pile, piles) -> # existence of piles is a flag
        if piles?
            list = []
            for card, i in pile[name + "_cards"]
                list.push
                    card: card
                    pile: pile
                    part: name
                    index: i
            list
        else
            pile[name + "_cards"]
# output-end rulefactory

## same as above but optionally concatenate both parts of the pile

# output-start validate
lib_schema.definitions.part_selection_list =
    type: "array"
    items: { $ref: "#/definitions/part_selection" }
# output-end validate
# output-start rulefactory
    part_selection_list = (selections, pile, piles) -> # existence of piles is a flag
        list = []
        for sel in selections
            list = list.concat part_selection(sel, pile, piles)
        list
# output-end rulefactory

## return a pile property

# output-start validate
lib_schema.definitions.pile_value =
    oneOf: [
        type: "number"
        multipleOf: 0.5
        minimum: 0
    ,
        enum: names.pileclass.concat(names.pile_role).concat "none"
    ]

lib_schema.definitions.pile_prop =
    enum: names.pile_prop
# output-end validate
# output-start rulefactory
    pile_prop = (prop, pile, self, other, piles) ->
        if numeric_pile_prop_names.indexOf(prop) > -1
            numeric_pile_props[prop](pile, piles)
        else
            string_pile_props[prop](pile, self, other)
# output-end rulefactory

## return a property of a card in a pile

# output-start validate
lib_schema.definitions.pile_card_prop =
    type: "object"
    required: [ "parts", "card", "prop" ]
    additionalProperties: false
    properties:
        parts: { $ref: "#/definitions/part_selection_list" }
        card: { $ref: "#/definitions/single_card" }
        prop: { $ref: "#/definitions/card_prop" }
# output-end validate
# output-start rulefactory
    pile_card_prop = (sel, pile, piles) ->
        cards = part_selection_list sel.parts, pile
        card = single_card sel.card, cards
        if not card? then return null
        card_prop sel.prop, card
# output-end rulefactory

## count cards satisfying some criteria in a pile part

# output-start validate
lib_schema.definitions.pile_card_count =
    type: "object"
    required: [ "parts", "card_list" ]
    additionalProperties: false
    properties:
        parts: { $ref: "#/definitions/part_selection_list" }
        card_list: { $ref: "#/definitions/card_selection_list" }
# output-end validate
# output-start rulefactory
    pile_card_count = (sel, pile, piles) ->
        cards = part_selection_list sel.parts, pile, piles
        card_selection_list(sel.card_list, cards).length
# output-end rulefactory

## test a pile for a criterium
## prop: a pile property
## card: for the property of a card in the pile
## count: for the number of cards satisfying some criteria

# output-start validate
lib_schema.definitions.pile_test =
    type: "object"
    required: [ "value" ]
    additionalProperties: false
    maxProperties: 3 # not enough
    properties:
        prop: { $ref: "#/definitions/pile_prop" }
        card: { $ref: "#/definitions/pile_card_prop" }
        count: { $ref: "#/definitions/pile_card_count" }
        compare: { $ref: "#/definitions/compare" }
        value: {}
    oneOf: [
        { required: [ "prop" ] },
        { required: [ "card" ] },
        { required: [ "count" ] }
    ],
    dependencies:
        prop:
            properties:
                value: { $ref: "#/definitions/pile_value" }
        card:
            properties:
                value: { $ref: "#/definitions/card_value" }
        count:
            properties:
                value: { $ref: "#/definitions/length" }
# output-end validate
# output-start rulefactory
    pile_test = (test, pile, self, other, piles) ->
        if test.prop?
            val = pile_prop(test.prop, pile, self, other, piles)
        else if test.card?
            val = pile_card_prop(test.card, pile)
        else if test.count?
            val = pile_card_count(test.count, pile, piles)
        compare[test.compare ? "=="](val, test.value)
# output-end rulefactory

## test a pile for multiple criteria

# output-start validate
lib_schema.definitions.pile_test_list =
    type: "array"
    items: { $ref: "#/definitions/pile_test" }
# output-end validate
# output-start rulefactory
    pile_test_list = (tests, pile, self, other, piles) ->
        test = true
        for t in tests
            test &&= pile_test t, pile, self, other, piles
            if not test then return false
        test
# output-end rulefactory

## compare two piles regarding a criterium, as described above

# output-start validate
lib_schema.definitions.pile_pair_test =
    type: "object"
    additionalProperties: false # not enough
    properties:
        prop: { $ref: "#/definitions/pile_prop" }
        card: { $ref: "#/definitions/pile_card_prop" }
        count: { $ref: "#/definitions/pile_card_count" }
        compare: { $ref: "#/definitions/compare" }
        operator: { $ref: "#/definitions/operator" }
        value: {}
    oneOf: [
        { required: [ "prop" ] },
        { required: [ "card" ] },
        { required: [ "count" ] }
    ],
    dependencies:
        prop:
            properties:
                value: { $ref: "#/definitions/pile_compute" }
        card:
            properties:
                value: { $ref: "#/definitions/card_compute" }
        count:
            properties:
                value: { $ref: "#/definitions/length_compute" }
        value: [ "operator" ]
# output-end validate
# output-start rulefactory
    pile_pair_test = (test, pile1, pile2, self, other, piles) ->
        if test.prop?
            val1 = pile_prop(test.prop, pile1, self, other, piles)
            val2 = pile_prop(test.prop, pile2, self, other, piles)
        else if test.card?
            val1 = pile_card_prop(test.card, pile1, piles)
            val2 = pile_card_prop(test.card, pile2, piles)
        else if test.count?
            val1 = pile_card_count(test.count, pile1, piles)
            val2 = pile_card_count(test.count, pile2, piles)
        if test.operator?
            res = operator[test.operator](val1, val2, test.value < 0)
            compare[test.compare ? "=="](res, test.value)
        else
            compare[test.compare ? "=="](val1, val2)
# output-end rulefactory

## compare two piles regarding multiple criteria, as described above

# output-start validate
lib_schema.definitions.pile_pair_test_list =
    type: "array"
    items: { $ref: "#/definitions/pile_pair_test" }
# output-end validate
# output-start rulefactory
    pile_pair_test_list = (tests, pile1, pile2, self, other, piles) ->
        test = true
        for t in tests
            test &&= pile_pair_test t, pile1, pile2, self, other, piles
            if not test then return false
        test
# output-end rulefactory

## select one pile, either by criteria or by position in the game

# output-start validate
lib_schema.definitions.single_pile =
    type: "object"
    maxProperties: 1
    additionalProperties: false
    properties:
        role:
            enum: names.pile_role
        single_tests: { $ref: "#/definitions/pile_test_list" }
        position:{ $ref: "#/definitions/position" }
    oneOf: [
        { required: [ "role" ] },
        { required: [ "single_tests" ] },
        { required: [ "position" ] }
    ]
# output-end validate
# output-start rulefactory
    single_pile = (sel, self, other, piles) ->
        if sel.role?
            if sel.role is "self" then return self
            if sel.role is "other" then return other
        if sel.position?
            return position sel.position, piles
        else
            for pile in piles
                if pile_test_list sel.single_tests, pile, self, other, piles
                    return pile
            return null
# output-end rulefactory

## filter piles by a criterium
## range: positional selection
## single_tests: selection by a list of pile criteria
## pairwise_tests: compare two adjoining piles (in ruleset listing order) and select one respectively
## comparison_tests comes in two flavors:
##   if comparator is set: compare all piles to one and select those that fit
##   else: compare any two piles and select one respectively
## dir: recto selects the first, verso the second in ruleset listing order

# output-start validate
lib_schema.definitions.pile_selection =
    type: "object"
    additionalProperties: false
    properties:
        range: { $ref: "#/definitions/range" }
        single_tests: { $ref: "#/definitions/pile_test_list" }
        pairwise_tests: { $ref: "#/definitions/pile_pair_test_list" }
        comparison_tests: { $ref: "#/definitions/pile_pair_test_list" }
        comparator: { $ref: "#/definitions/single_pile" }
        dir: lib_direction
    oneOf: [
        required: [ "range" ]
        maxProperties: 1
    ,
        required: [ "single_tests" ]
        maxProperties: 1
    ,
        required: [ "pairwise_tests" ]
        maxProperties: 2
        dependencies: # not enough
            dir: [ "pairwise_tests" ]
    ,
        required: [ "comparison_tests" ]
        maxProperties: 2
        not:
            allOf: [
                required: [ "comparator" ]
            ,
                required: [ "dir" ]
            ]
    ]
# output-end validate
# output-start rulefactory
    pile_selection = (sel, self, other, piles) ->
        list = []
        if sel.range?
            return range sel.range, piles
        else if sel.single_tests?
            for pile in piles
                if pile_test_list sel.single_tests, pile, self, other, piles
                    list.push pile
        else if sel.pairwise_tests?
            for p, i in piles[1..]
                if pile_pair_test_list sel.pairwise_tests, piles[i], p, self, other, piles
                    pile = if sel.dir is "verso" then p else piles[i]
                    list.push pile
        else if sel.comparison_tests?
            if sel.comparator?
                comp = single_pile sel.comparator, self, other, piles
                if not comp? then return list
                for pile in piles
                    if pile_pair_test_list sel.comparison_tests, comp, pile, self, other, piles
                        list.push pile
            else
                for p2, i2 in piles[1..]
                    for p1, i1 in piles[0..i2]
                        if pile_pair_test_list sel.comparison_tests, p1, p2, self, other, piles
                            pile = if sel.dir is "verso" then p2 else p1
                            list.push pile
        list
# output-end rulefactory

## concatenate multiple filtered pile lists

# output-start validate
lib_schema.definitions.pile_selection_list = # order of entries is important!
    type: "array"
    items: { $ref: "#/definitions/pile_selection" }
# output-end validate
# output-start rulefactory
    pile_selection_list = (selections, self, other, piles) ->
        list = []
        for sel in selections
            list = list.concat pile_selection sel, self, other, piles
        list
# output-end rulefactory

## compare the length of a list of piles to a value

# output-start validate
lib_schema.definitions.pile_sequence_count =
    type: "object"
    required: [ "value" ]
    additionalProperties: false
    properties:
        compare: { $ref: "#/definitions/compare" }
        value: { $ref: "#/definitions/length" }
# output-end validate
# output-start rulefactory
    pile_sequence_count = (test, pile_list) ->
        compare[test.compare ? "=="](pile_list.length, test.value)
# output-end rulefactory

## pick one pile of a filtered pile list by priority rule

# output-start validate
lib_schema.definitions.priority_pile =
    type: "object"
    required: [ "pile", "priority" ]
    additionalProperties: false
    properties:
        pile: { $ref: "#/definitions/pile_selection_list" }
        priority: { $ref: "#/definitions/position" }
# output-end validate
# output-start rulefactory
    priority_pile = (sel, self, other, piles) ->
        list = pile_selection_list sel.pile, self, other, piles
        position sel.priority, list
# output-end rulefactory

## select a card sequence by their role in a game action

# output-start validate
lib_schema.definitions.single_role =
    type: "object"
    required: [ "heap" ]
    oneOf: [
        required: [ "part" ]
        additionalProperties: false
        properties:
            heap:
                enum: names.pile_role
            part: { "$ref": "#/definitions/part_selection" }
    ,
        additionalProperties: false
        properties:
            heap:
                enum: [ "cards" ]
    ]
# output-end validate
# output-start rulefactory
    single_role = (sel, cards, self, other, piles) -> # existence of piles is a flag
        switch sel.heap
            when "cards"
                if piles?
                    list = []
                    for c in cards
                        list.push { card: c }
                    list
                else
                    cards
            when "self"
                part_selection sel.part, self, piles
            when "other"
                part_selection sel.part, other, piles
# output-end rulefactory

## select a card sequence by their role in a game action

# output-start validate
lib_schema.definitions.role_list =
    type: "array"
    items:  { $ref: "#/definitions/single_role" }
# output-end validate
# output-start rulefactory
    role_list = (sels, cards, self, other, piles) -> # existence of piles is a flag
        list = []
        for sel in sels
            list = list.concat single_role(sel, cards, self, other, piles)
        list
# output-end rulefactory

## select a card by specifying first their position in the game and then selecting by critera

# output-start validate
lib_schema.definitions.card_extract =
    type: "object"
    required: [ "card" ]
    additionalProperties: false # not enough
    properties:
        role: { $ref: "#/definitions/single_role" }
        pile: { $ref: "#/definitions/single_pile" }
        parts: { $ref: "#/definitions/part_selection_list" }
        card: { $ref: "#/definitions/single_card" }
    oneOf: [
        { required: [ "role" ] },
        { required: [ "pile", "parts" ] }
    ]
# output-end validate
# output-start rulefactory
    card_extract = (sel, cards, self, other, piles) ->
        if sel.role?
            card_list = single_role sel.role, cards, self, other
        else
            pile = single_pile sel.pile, self, other, piles
            if not pile? then return null
            card_list = part_selection_list sel.parts, pile
        single_card sel.card, card_list
# output-end rulefactory

## select multiple cards by specifying first their position in the game and then filtering by critera

# output-start validate
lib_schema.definitions.sequence_extract =
    type: "object"
    additionalProperties: false # not enough
    properties:
        roles: { $ref: "#/definitions/role_list" }
        piles: { $ref: "#/definitions/pile_selection_list" }
        parts: { $ref: "#/definitions/part_selection_list" }
        cards: { $ref: "#/definitions/card_selection_list" }
    oneOf: [
        { required: [ "roles" ] },
        { required: [ "piles", "parts" ] }
    ]
# output-end validate
# output-start rulefactory
    sequence_position_extract = (rule, cards, self, other, piles) ->
        if rule.roles?
            list = role_list(rule.roles, cards, self, other, piles)
        else
            list = []
            for pile in pile_selection_list rule.piles, self, other, piles
                list = list.concat part_selection_list(rule.parts, pile, piles)
        if rule.cards?
            list = card_selection_list rule.cards, list
        list

    sequence_extract = (rule, cards, self, other, piles) ->
        list = []
        for e in sequence_position_extract(rule, cards, self, other, piles)
            list.push e.card
        list
# output-end rulefactory

## pick one card of a filtered card list by priority rule

# output-start validate
lib_schema.definitions.priority_sequence =
    type: "object"
    required: [ "card", "priority" ]
    additionalProperties: false
    properties:
        card: { $ref: "#/definitions/sequence_extract" }
        priority: { $ref: "#/definitions/position" }
# output-end validate
# output-start rulefactory
    priority_sequence = (sel, self, other, piles) ->
        list = sequence_position_extract sel.card, null, self, other, piles
        position sel.priority, list
# output-end rulefactory

## compare the length of two list of cards or piles

# output-start validate
lib_schema.definitions.pair_count =
    type: "object"
    additionalProperties: false
    properties:
        compare: { $ref: "#/definitions/compare" }
        operator: { $ref: "#/definitions/operator" }
        value: { $ref: "#/definitions/length_compute" }
    dependencies:
        value: [ "operator" ]
# output-end validate
# output-start rulefactory
    pair_count = (test, list1, list2) ->
        if test.operator?
            res = operator[test.operator](list1.length, list2.length, test.value < 0)
            compare[test.compare ? "=="](res, test.value)
        else
            compare[test.compare ? "=="](list1.length, list2.length)

## evaluation rules return boolean

    evaluator = {
# output-end rulefactory

# output-start validate
evaluate_schema_definitions = {}

evaluate_schema_definitions.and_or =
    properties:
        name:
            enum: [ "and", "or" ]
        rule:
            type: "array"
            items: { $ref: "#" }
            minItems: 2
# output-end validate

## test for multiple rules

# output-start rulefactory
        and: (rule, cards, self, other, piles) ->
            test = true
            for r in rule
                test &&= evaluator[r.name](r.rule, cards, self, other, piles)
                if not test then break
            test

## test for one of multiple rules

        or: (rule, cards, self, other, piles) ->
            test = false
            for r in rule
                test ||= evaluator[r.name](r.rule, cards, self, other, piles)
                if test then break
            test
# output-end rulefactory

## test concerning one card

# output-start validate
evaluate_schema_definitions.one_card =
    properties:
        name:
            enum: [ "one_card" ]
        rule:
            type: "object"
            required: [ "select", "tests" ]
            maxProperties: 2
            properties:
                select: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_extract" }
                tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_test_list" }
# output-end validate
# output-start rulefactory
        one_card: (rule, cards, self, other, piles) ->
            card = card_extract rule.select, cards, self, other, piles
            if not card? then return false
            card_test_list rule.tests, card
# output-end rulefactory

## test concerning the comparison of two cards

# output-start validate
evaluate_schema_definitions.two_card =
    properties:
        name:
            enum: [ "two_card" ]
        rule:
            type: "object"
            required: [ "first", "second", "tests" ]
            maxProperties: 3
            properties:
                first: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_extract" }
                second: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_extract" }
                tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_pair_test_list" }
# output-end validate
# output-start rulefactory
        two_card: (rule, cards, self, other, piles) ->
            first = card_extract rule.first, cards, self, other, piles
            if not first? then return false
            second = card_extract rule.second, cards, self, other, piles
            if not second? then return false
            card_pair_test_list rule.tests, first, second
# output-end rulefactory

## test concerning a card sequence

# output-start validate
evaluate_schema_definitions.card_sequence =
    properties:
        name:
            enum: [ "card_sequence" ]
        rule:
            type: "object"
            maxProperties: 2
            properties:
                select: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/sequence_extract" }
                all_tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_test_list" }
                pairwise_tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_pair_test_list" }
                count: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_sequence_count" }
            oneOf: [
                { required: [ "select", "all_tests" ] },
                { required: [ "select", "pairwise_tests" ] },
                { required: [ "select", "count" ] }
            ]
# output-end validate
# output-start rulefactory
        card_sequence: (rule, cards, self, other, piles) ->
            card_list = sequence_extract rule.select, cards, self, other, piles
            test = true
            if rule.all_tests?
                for card in card_list
                    test &&= card_test_list rule.all_tests, card
                    if not test then break
            else if rule.pairwise_tests?
                for c, i in card_list[1..]
                    test &&= card_pair_test_list rule.pairwise_tests, card_list[i], c
                    if not test then break
            else
                test = card_sequence_count rule.count, card_list
            test
# output-end rulefactory

## test concerning one pile

# output-start validate
evaluate_schema_definitions.one_pile =
    properties:
        name:
            enum: [ "one_pile" ]
        rule:
            type: "object"
            required: [ "select", "tests" ]
            maxProperties: 2
            properties:
                select: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/single_pile" }
                tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_test_list" }
# output-end validate
# output-start rulefactory
        one_pile: (rule, cards, self, other, piles) ->
            pile = single_pile rule.select, self, other, piles
            if not pile? then return false
            pile_test_list rule.tests, pile, self, other, piles
# output-end rulefactory

## test concerning the comparison of two piles

# output-start validate
evaluate_schema_definitions.two_pile =
    properties:
        name:
            enum: [ "two_pile" ]
        rule:
            type: "object"
            required: [ "first", "second", "tests" ]
            maxProperties: 3
            properties:
                first: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/single_pile" }
                second: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/single_pile" }
                tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_pair_test_list" }
# output-end validate
# output-start rulefactory
        two_pile: (rule, cards, self, other, piles) ->
            first = single_pile rule.first, self, other, piles
            if not first? then return false
            second = single_pile rule.second, self, other, piles
            if not second? then return false
            pile_pair_test_list rule.tests, first, second, self, other, piles
# output-end rulefactory

## test concerning a pile sequence

# output-start validate
evaluate_schema_definitions.pile_sequence =
    properties:
        name:
            enum: [ "pile_sequence" ]
        rule:
            type: "object"
            maxProperties: 2
            properties:
                select: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_selection_list" }
                all_tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_test_list" }
                pairwise_tests: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_pair_test_list" }
                count: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_sequence_count" }
            oneOf: [
                { required: [ "select", "all_tests" ] },
                { required: [ "select", "pairwise_tests" ] },
                { required: [ "select", "count" ] }
            ]
# output-end validate
# output-start rulefactory
        pile_sequence: (rule, cards, self, other, piles) ->
            pile_list = pile_selection_list rule.select, self, other, piles
            test = true
            if rule.all_tests?
                for pile in pile_list
                    test &&= pile_test_list rule.all_tests, pile
                    if not test then break
            else if rule.pairwise_tests?
                for p, i in pile_list[1..]
                    test &&= pile_pair_test_list rule.pairwise_tests, pile_list[i], p
                    if not test then break
            else
                test = pile_sequence_count rule.count, pile_list
            test
# output-end rulefactory

## test concerning two card/pile sequences (read: compare their length)

# output-start validate
evaluate_schema_definitions.two_sequence =
    properties:
        name:
            enum: [ "two_sequence" ]
        rule:
            type: "object"
            required: [ "count" ]
            maxProperties: 3
            additionalProperties: false
            properties:
                count: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pair_count" }
            patternProperties:
                "[first|second]_cards": { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/sequence_extract" }
                "[first|second]_piles": { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_selection_list" }
            allOf: [
                patternProperties: { "first_[cards|piles]": {} }
            ,
                patternProperties: { "second_[cards|piles]": {} }
            ]
# output-end validate
# output-start rulefactory
        two_sequence: (rule, cards, self, other, piles) ->
            if rule.first_cards?
                first_list = sequence_extract rule.first_cards, cards, self, other, piles
            if rule.second_cards?
                second_list = sequence_extract rule.second_cards, cards, self, other, piles
            if rule.first_piles?
                first_list = pile_selection_list rule.first_piles, self, other, piles
            if rule.second_piles?
                second_list = pile_selection_list rule.second_piles, self, other, piles
            pair_count rule.count, first_list, second_list

## unconditional test results

        all: () -> true
        none: () -> false
    }

## action functions change the order of cards in the game

    do_swap = (pair) ->
        swapping = pair[0].pile.show_swap pair[0].part, pair[0].index
        swapping = pair[1].pile.exec_swap pair[1].part, pair[1].index, swapping
        pair[0].pile.exec_swap pair[0].part, pair[0].index, swapping

    mover = {
# output-end rulefactory

## execute multiple actions

# output-start validate
action_schema_definitions = {}

action_schema_definitions.iterate =
    properties:
        name:
            enum: [ "iterate" ]
        rule:
            type: "array"
            items: { $ref: "#/deal_action" }
            minItems: 2
# output-end validate
# output-start rulefactory
        iterate: (rule, self, other, piles) ->
            for r in rule
                mover[r.name](r.rule, self, other, piles)
# output-end rulefactory

## move cards from the top of one pile to another
## takes two filtered pile lists for movement from - to,
## and repeats moving one card until one pile description is exhausted

# output-start validate
action_schema_definitions.move =
    properties:
        name:
            enum: [ "move" ]
        rule:
            type: "object"
            required: [ "first", "second" ]
            additionalProperties: false
            properties:
                first: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/priority_pile" }
                second: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/priority_pile" }
                number:
                    type: "integer"
                    minimum: 1
                    default: 1
# output-end validate
# output-start rulefactory
        move: (rule, self, other, piles) ->
            loop
                pair = []
                for ord in ["first", "second"]
                    prio = priority_pile rule[ord], self, other, piles
                    if not prio then return
                    pair.push prio
                removed = pair[0].show_withdraw(rule.number ? 1)
                pair[0].exec_withdraw()
                pair[1].exec_add removed
# output-end rulefactory

## swap the position of two cards in the game
## takes two filtered card lists for swap partners,
## and repeats swapping until one partner description is exhausted

# output-start validate
action_schema_definitions.swap =
    properties:
        name:
            enum: [ "swap" ]
        rule:
            type: "object"
            required: [ "first", "second" ]
            additionalProperties: false
            properties:
                first: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/priority_sequence" }
                second: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/priority_sequence" }
# output-end validate
# output-start rulefactory
        swap: (rule, self, other, piles) ->
            loop
                pair = []
                for ord in ["first", "second"]
                    prio = priority_sequence rule[ord], self, other, piles
                    if not prio then return
                    pair.push prio
                do_swap pair
# output-end rulefactory

## shuffle a selection of cards in the game

# output-start validate
action_schema_definitions.shuffle =
    properties:
        name:
            enum: [ "shuffle" ]
        rule:
            type: "object"
            required: [ "select" ]
            additionalProperties: false
            properties:
                select: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/sequence_extract" }
# output-end validate
# output-start rulefactory
        shuffle: (rule, self, other, piles) ->
            list = sequence_position_extract rule.select, null, self, other, piles
            sorted = list.slice 0
            base.shuffle list
            for c, i in sorted
                do_swap [list[i], c]
    }
# output-end rulefactory

## point model returns a number
## it can consist of one point count rule given as an object, or an array of point count rules
## in this case, the result of each rule is added up

# output-start validate
point_schema_definitions = {}

point_schema_definitions.point_model =
    oneOf: [
        type: "array"
        items: { $ref: "#/definitions/point_count" }
    ,
        $ref: "#/definitions/point_count"
    ]
# output-end validate
# output-start rulefactory
    point_model = (rule, self, other, piles) ->
        if Array.isArray(rule)
            points = 0
            for entry in rule
                points += point_count entry, self, other, piles
            points
        else
            point_count rule, self, other, piles
# output-end rulefactory

## point count returns a number evaluating one pile
## point rules are executed for each pile, but can evaluate multiple piles in correlation
## dir: if the final is the result of a computation, describe the sequence of operands:
##      recto: count left in operation and value right, verso: count right

# output-start validate
point_schema_definitions.point_count =
    type: "object"
    additionalProperties: false
    properties:
        fixed:
            type: "integer"
        piles: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_selection_list" }
        cards: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/sequence_extract" }
        operator: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/operator" }
        dir: lib_direction
        evaluate: {}
        value: {}
    oneof: [
        { required: [ "fixed" ] },
        { required: [ "piles" ] },
        { required: [ "cards" ] }
    ]
    dependencies:
        piles:
            properties:
                evaluate:
                    enum: names.numeric_pile_prop.concat [ "length" ]
                    default: "length"
                value: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_compute" }
        cards:
            properties:
                evaluate:
                    enum: names.numeric_card_prop.concat ["length"]
                    default: "length"
                value: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/card_compute" }
        operator: [ "value" ]
# output-end validate
# output-start rulefactory
    point_count = (rule, self, other, piles) ->
        if rule.fixed? then return rule.fixed
        else if rule.piles?
            selected = pile_selection_list rule.piles, self, other, piles
            if rule.evaluate? and rule.evaluate isnt "length"
                count = 0
                for pile in selected
                    count += pile_prop rule.evaluate, pile
            else
                count = selected.length
        else if rule.cards?
            selected = sequence_extract rule.cards, null, self, other, piles
            if rule.evaluate? and rule.evaluate isnt "length"
                count = 0
                for card in selected
                    count += card_prop rule.evaluate, card
            else
                count = selected.length
        if rule.operator?
            if rule.dir is "verso"
                operator[rule.operator](rule.value, count)
            else
                operator[rule.operator](count, rule.value)
        else
            count
# output-end rulefactory

## top-level schemas

# output-start validate
ruleset_schema =
    $schema: "http://json-schema.org/draft-04/schema#"
    id: "http://patience.intern/rulesets/ruleset_schema#"
    type: "object"
    required: [ "title", "help",  "set",  "count",  "point_target",  "pilegroups" ]
    additionalProperties: false
    properties:
        title:
            type: "string"
        help:
            type: "string"
            format: "uri"
        set:
            type: "integer"
            multipleOf: 2
            minimum: 4
            maximum: 54
        count: lib_posint_1
        point_target: lib_posint_1
        pilegroups:
            type: "array"
            items:
                type: "object"
                required: [ "pileclass", "piles" ]
                additionalProperties: false
                properties:
                    pileclass:
                        type: "string"
                        enum: names.pileclass
                    options: { $ref: "#/definitions/options" }
                    piles:
                        type: "array"
                        items:
                            type: "object"
                            required: [ "position" ]
                            additionalProperties: false
                            properties:
                                position:
                                    type: "object"
                                    required: [ "x", "y" ]
                                    additionalProperties: false
                                    properties:
                                        x:
                                            type: "number"
                                            multipleOf: 0.5
                                            minimum: 0
                                        y:
                                            type: "number"
                                            multipleOf: 0.5
                                            minimum: 0
                                options: { $ref: "#/definitions/options" }
        deal_action: { $ref: "http://patience.intern/rulesets/action_schema#/deal_action" }
    definitions:
## pile option schema
        options:
            type: "object"
            additionalProperties: false
            properties:
                direction:
                    enum: [ "up", "down", "left", "right" ]
                    default: "down"
                spread:
                    type: "number",
                    multipleOf: 0.5,
                    minimum: 1
                initial_facedown: lib_posint_0
                initial_faceup: lib_posint_0
                click: { $ref: "#/definitions/related" }
                autofill: { $ref: "#/definitions/related" }
                fill:
                    type: "object"
                    additionalProperties: false
                    properties:
                        method:
                            enum: ["incremental", "once", "other"]
                            default: "incremental"
                        dir:
                            enum: ["asc", "desc"]
                            default: "asc"
                        base:
                            type: "integer"
                            minimum: 1
                            maximum: 13
                countdown:
                    type: "object"
                    required: [ "which", "number" ]
                    additionalProperties: false
                    properties:
                        which:
                            enum: names.action
                        number: lib_posint_0
                action: { $ref: "http://patience.intern/rulesets/action_schema#/pile_action" }
                click_rule: { $ref: "http://patience.intern/rulesets/evaluate_schema#" }
                drag_rule: { $ref: "http://patience.intern/rulesets/evaluate_schema#" }
                build_rule: { $ref: "http://patience.intern/rulesets/evaluate_schema#" }
                pairing_rule: { $ref: "http://patience.intern/rulesets/evaluate_schema#" }
                point_rule: { $ref: "http://patience.intern/rulesets/point_schema#" }
            dependencies:
                direction: [ "spread" ]
# output-end validate

## public functions

# output-start rulefactory
    return {
# output-end rulefactory

## return an evaluation function
## this function returns a boolean to indicate whether an action (click, dblclick, drag, build) is allowed

# output-start validate
evaluate_schema =
    $schema: "http://json-schema.org/draft-04/schema#"
    id: "http://patience.intern/rulesets/evaluate_schema#"
    type: "object"
    required: [ "name" ]
    additionalProperties: false
    properties:
        name: {}
        rule: {}
    oneOf: [
        maxProperties: 1
        properties:
            name:
                enum: [ "all", "none" ]
    ,
        required: [ "rule" ]
        oneOf: [
            { "$ref": "#/definitions/and_or" },
            { "$ref": "#/definitions/one_card" },
            { "$ref": "#/definitions/two_card" },
            { "$ref": "#/definitions/card_sequence" },
            { "$ref": "#/definitions/one_pile" },
            { "$ref": "#/definitions/two_pile" },
            { "$ref": "#/definitions/pile_sequence" },
            { "$ref": "#/definitions/two_sequence" }
        ]
    ]
    definitions: evaluate_schema_definitions
# output-end validate
# output-start rulefactory
        evaluate: (rule, cards, self, other, piles) ->
            evaluator[rule.name](rule.rule, cards, self, other, piles)
# output-end rulefactory

## return a move function
## this function moves cards in or between piles

# output-start validate
action_schema =
    $schema: "http://json-schema.org/draft-04/schema#"
    id: "http://patience.intern/rulesets/action_schema#"
    pile_action:
        type: "array"
        items:
            type: "object"
            required: [ "on", "name", "rule" ]
            additionalProperties: false
            properties:
                on:
                    enum: names.action
                name: {}
                rule: {}
            allOf: [ $ref: "#/definitions/selector" ]
    deal_action:
        type: "object"
        required: [ "name", "rule" ]
        additionalProperties: false
        properties:
            name: {}
            rule: {}
        allOf: [ $ref: "#/definitions/selector" ]
    definitions: action_schema_definitions

action_schema.definitions.selector =
    oneOf: [
        { "$ref": "#/definitions/iterate" },
        { "$ref": "#/definitions/move" },
        { "$ref": "#/definitions/swap" },
        { "$ref": "#/definitions/shuffle" }
    ]
# output-end validate

## return a number of points awarded for a pile state
## if a "both" rule is defined, points are awarded for the state of the pile at any time
## if an "old" rule is defined, it is possible to state a virtual number of points that
## the pile had before it changes (and that are substracted from the point total)
## and a new number awarded after the move (that are added to the point total)

# output-start rulefactory
        get_action: (rule) ->
            return (self, other, piles) ->
                mover[rule.name](rule.rule, self, other, piles)
# output-end rulefactory
# output-start validate
point_schema =
    $schema: "http://json-schema.org/draft-04/schema#"
    id: "http://patience.intern/rulesets/point_schema#"
    type: "object"
    properties:
        new: { $ref: "#/definitions/point_model" }
        old: { $ref: "#/definitions/point_model" }
        both: { $ref: "#/definitions/point_model" }
    oneOf: [
        required: [ "new", "old" ]
        maxProperties: 2
    ,
        required: [ "both" ]
        maxProperties: 1
    ]
    definitions: point_schema_definitions
# output-end validate
# output-start rulefactory
        points: (rule, timing, pile, piles) ->
            if not rule[timing]? and not rule.both? then return 0
            point_model(rule[timing] ? rule.both, pile, null, piles)
# output-end rulefactory

## return a list of piles used as targets for a click action or sources for an autofill action

# output-start validate
ruleset_schema.definitions.related =
    type: "object"
    required: [ "relations" ]
    additionalProperties: false
    properties:
        relations: { $ref: "http://patience.intern/rulesets/lib_schema#/definitions/pile_selection_list" }
        number: lib_posint_1
# output-end validate
# output-start rulefactory
        related: (rule, pile, piles) ->
            pile_selection_list(rule, pile, null, piles)

        merge: (obj1, obj2) ->
            result = {}
            for own prop of obj2
                if typeof obj2[prop] is "object" and not((obj2[prop] instanceof Array) or prop is "rule")
                    result[prop] = @merge obj1[prop] ? {}, obj2[prop]
                else
                    result[prop] = obj2[prop]
            for own prop of obj1
                if not obj2[prop]?
                    if typeof obj1[prop] is "object" and not((obj1[prop] instanceof Array) or prop is "rule")
                        result[prop] = @merge obj1[prop], {}
                    else
                        result[prop] = obj1[prop]
            result
    }
# output-end rulefactory

## node.js module binding

# output-start validate
exports.ruleset_schema = ruleset_schema
exports.point_schema = point_schema
exports.action_schema = action_schema
exports.evaluate_schema = evaluate_schema
exports.lib_schema = lib_schema
# output-end validate

