class Pile

    default_options:
        initial_facedown: 0
        initial_faceup: 0
        click_rule:
            name: "none"
        drag_rule:
            name: "none"
        build_rule:
            name: "none"
        point_rule: {}

    constructor: (game, options, deck) ->
        @game = game
        {
            @countdown,
            @click,
            @autofill
        } = options
        @facedown_cards = deck.splice 0, options.initial_facedown
        @faceup_cards = deck.splice 0, options.initial_faceup
        @click_rule = ->
            rulefactory.evaluate options.click_rule, [], @, null, @game.piles
        @drag_rule = (index) ->
            index_up = Math.max 0, index - @facedown_cards.length
            cards = @facedown_cards.slice(index).concat(@faceup_cards.slice index_up)
            rulefactory.evaluate options.drag_rule, cards, @, null, @game.piles
        @build_rule = (cards, source) ->
            rulefactory.evaluate options.build_rule, cards, @, source, @game.piles
        @marked_withdraw = 0
        @actions = {}
        for a in options.action ? []
            @actions[a.on] = rulefactory.get_action a, @game.add_for_update
        @point_rule = (timing) ->
            rulefactory.points options.point_rule, timing, @, @game.piles

    total_length: () ->
        @facedown_cards.length + @faceup_cards.length

    copy_all_cards: () ->
        down: @facedown_cards.concat()
        up: @faceup_cards.concat()

    set_all_cards: (cards) ->
        @facedown_cards = cards.down
        @faceup_cards = cards.up

    marked_indexes: () ->
        [ Math.min(@facedown_cards.length, @total_length() - @marked_withdraw),
            Math.max(0, @faceup_cards.length - @marked_withdraw) ]

    init_related: (piles) ->
        for r in [ "click", "autofill"]
            if @[r]?
                @[r].related = rulefactory.related @[r].relations, @, piles

    show_withdraw: (number) ->
        end = @marked_indexes()
        @marked_withdraw += Math.min(number, @total_length())
        begin = @marked_indexes()
        @facedown_cards.slice(begin[0], end[0]).reverse().concat @faceup_cards.slice(begin[1], end[1])

    exec_withdraw: () ->
        begin = @marked_indexes()
        @facedown_cards.splice begin[0], @facedown_cards.length
        @faceup_cards.splice begin[1], @faceup_cards.length
        @marked_withdraw = 0
        @on_withdraw()

    cancel_withdraw: (number) ->
        @marked_withdraw -= number ? @marked_withdraw

    exec_add: (cards) ->
        @faceup_cards = @faceup_cards.concat cards

    show_swap: (part, index) ->
        @[part + "_cards"].slice(index, index + 1)[0]

    exec_swap: (part, index, card) ->
        @[part + "_cards"].splice(index, 1, card)[0]

    on_withdraw: () ->
        if @total_length() == 0 and @autofill?
            number = @autofill.number
            for source in @autofill.related
                drawn = source.show_withdraw number
                if drawn.length > 0
                    number -=drawn.length
                    source.exec_withdraw()
                    @exec_add drawn.reverse()
                if number == 0 then break

    on_click: ->
        if (not (@countdown?.which is "click") or @countdown.number > 0) and @click_rule()
            test = 0
            if @click?
                for target in @click.related
                    number = @click.number ? @total_length()
                    withdraw = @show_withdraw(number)
                    if target.on_build(withdraw, @)
                        test++
                        if @countdown?.which is "click"
                            @countdown.number--
                    else
                        @cancel_withdraw(number)
            if test or @actions.click?
                @exec_withdraw()
                @actions.click? @, null, @game.piles
                @game.update()

    on_dblclick: ->
        if (not (@countdown?.which is "dblclick") or @countdown.number > 0) and @faceup_cards.length
            test = false
            for target in @dblclick_targets
                number = if target.fill is "once" then 13 else 1
                withdraw = @show_withdraw (number)
                if target.on_build withdraw, @
                    if @countdown?.which is "dblclick"
                        @countdown.number--
                    test = true
                    break
                else
                    @cancel_withdraw(number)
            if test or @actions.dblclick?
                @exec_withdraw()
                @actions.dblclick? @, null, @game.piles
                @game.update()
            else
                @cancel_withdraw()

    on_drop: (target, index) ->
        withdraw = @show_withdraw @total_length() - index
        if target.on_build(withdraw, @)
            @exec_withdraw()
            @actions.drop? @, target, @game.piles
            @game.update()
        else
            @cancel_withdraw()

    on_build: (cards, source) ->
        test = (not (@countdown?.which is "build") or @countdown.number > 0) and @build_rule cards, source
        if test
            @exec_add cards
            @actions.build? @, source, @game.piles
            if @countdown?.which is "build"
                @countdown.number--
        test

class Cell extends Pile
    classname: "Cell"

    default_options:
        drag_rule:
            name: "all"
        build_rule:
            name: "card_sequence"
            rule:
                select:
                    roles: [ 
                        { heap: "self", part: "facedown" },
                        { heap: "self", part: "faceup" },
                        { heap: "cards" }
                    ]
                count:
                    compare: "<="
                    value: 1

    constructor: (game, options, deck) ->
        if options.pairing_rule?
            @pairing_rule = (cards, source) ->
                rulefactory.evaluate options.pairing_rule, cards, @, source, @game.piles
        super game, options, deck

    on_build: (cards, source) ->
        if @pairing_rule? and @faceup_cards.length == 1
            @show_withdraw(1)
            test = (not (@countdown?.which is "build") or @countdown.number > 0) and
                cards.length == 1 and @pairing_rule?(cards, source)
            if test
                @exec_withdraw()
                @actions.build? @, source, @game.piles
                if @countdown?.which is "build"
                    @countdown.number--
            test
        else
            super cards, source

class Tableau extends Pile
    classname: "Tableau"

    default_options:
        initial_faceup: 1
        direction: "down"
        drag_rule:
            name: "two_sequence"
            rule:
                first_cards:
                    roles: [ { heap: "cards" } ]
                second_cards:
                    roles: [ { heap: "self", part: "faceup" } ]
                count:
                    compare: "<="

    constructor: (game, options, deck) ->
        { @direction, @spread } = options
        super game, options, deck

    on_withdraw: ->
        if not @faceup_cards.length and @facedown_cards.length
            @faceup_cards.push(@facedown_cards.pop())
        super

class Stock extends Pile
    classname: "Stock"

    default_options:
        click: 
            relations: [
                single_tests: [
                    prop: "pileclass"
                    value: "Waste" 
                ]
            ]
            number: 1
        click_rule:
            name: "all"
        build_rule:
            name: "and"
            rule: [
                name: "one_pile"
                rule:
                    select:
                        role: "other"
                    tests: [
                        prop: "pileclass"
                        value: "Waste"
                    ]
            ,
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "self", part: "facedown" } ]
                    count:
                        value: 0
            ]

    constructor: (game, options, deck) ->
        if options.initial_facedown == 0
            options.initial_facedown = deck.length
        super game, options, deck

    exec_add: (cards) ->
        @facedown_cards = @facedown_cards.concat cards

class Waste extends Pile
    classname: "Waste"

    default_options:
        countdown:
            which: "click"
            number: 0
        click: 
            relations: [
                single_tests: [
                    prop: "pileclass"
                    value: "Stock" 
                ]
            ]
        click_rule:
            name: "all"
        drag_rule:
            name: "all"
        build_rule:
            name: "one_pile"
            rule:
                select:
                    role: "other"
                tests: [
                    prop: "pileclass"
                    value: "Stock"
                ]

    constructor: (game, options, deck) ->
        super game, options, deck

    on_click: ->
        if @countdown.number > 0 and @click_rule()
            target = @click.related[0]
            withdraw = @show_withdraw @total_length()
            if target.on_build(withdraw.reverse(), @)
                @exec_withdraw()
                if @countdown?.which is "click"
                    @countdown.number--
                @game.update()
            else
                @cancel_withdraw()

class Reserve extends Pile
    classname: "Reserve"

    default_options:
        initial_faceup: 1
        drag_rule:
            name: "all"
        build_rule:
            name: "one_pile"
            rule:
                select:
                    role: "other"
                tests: [
                    prop: "pileclass"
                    value: "Stock"
                ]

    constructor: (game, options, deck) ->
        super game, options, deck

    on_withdraw: ->
        if not @faceup_cards.length and @facedown_cards.length
            @faceup_cards.push(@facedown_cards.pop())
        super

class Foundation extends Pile
    classname: "Foundation"

    component =
        sequence:
            name: "card_sequence"
            rule:
                select:
                    roles: [
                        { heap: "self", part: "faceup" },
                        { heap: "cards" }
                    ]
                pairwise_tests: [
                    prop: "suit"
                ,
                    prop: "value"
                ]
        bottom:
            name: "one_card"
            rule:
                select: 
                    role: { heap: "cards" }
                    card:
                        position:
                            dir: "recto"
                            position: 0
                tests: [
                    prop: "value"
                ]
        nonempty:
            name: "card_sequence"
            rule:
                select:
                    roles: [ { heap: "self", part: "faceup" } ]
                count:
                    compare: ">"
                    value: 0
        length:
            name: "card_sequence"
            rule:
                select:
                    roles: [ { heap: "cards" } ]
                count:
                    value: 13
        empty:
            name: "card_sequence"
            rule:
                select:
                    roles: [ { heap: "self", part: "faceup" } ]
                count:
                    value: 0

    foundation_rule = (fill) ->
        r = []
        component.bottom.rule.tests[0].value = fill.base ? (if fill.dir is "asc" then 1 else 13)
        component.sequence.rule.pairwise_tests[1].operator = if fill.base? then "wrapped_diff" else "diff"
        component.sequence.rule.pairwise_tests[1].value = if fill.dir is "asc" then -1 else 1
        if fill.method is "once"
            r.push component.empty
            r.push component.length
            r.push component.bottom
        r.push component.sequence
        if fill.method is "incremental"
            r.push(
                name: "or"
                rule: [component.nonempty, component.bottom]
            )
        {
            name: "and"
            rule: r
        }

    default_options:
        fill:
            method: "incremental"
            dir: "asc"
        point_rule:
            both:
                cards:
                    roles: [ { heap: "self", part: "faceup" } ]

    constructor: (game, options, deck) ->
        if options.fill.method != "other"
            @fill = options.fill.method
            options.build_rule = foundation_rule options.fill
        super game, options, deck

    on_dblclick: ->

