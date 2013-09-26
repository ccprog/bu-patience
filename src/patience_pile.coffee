# abstract pile data model object
class Pile
    # default ruleset options (no cards, no possible action, no points awarded)
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

    # read options, splice initial cards from the deck
    # construct all evaluation/action/point rule functions from the rulefactory
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
        if options.pairing_rule?
            @pairing_rule = (cards, source) ->
                rulefactory.evaluate options.pairing_rule, cards, @, source, @game.piles
        @marked_withdraw = 0
        @actions = {}
        for a in options.action ? []
            @actions[a.on] = rulefactory.get_action a, @game.add_for_update
        @point_rule = (timing) ->
            rulefactory.points options.point_rule, timing, @, @game.piles

    # identify click target/autofill source piles
    # must be done only after all piles of a game exist, so not part of the constructor
    init_related: (piles) ->
        for r in [ "click", "autofill"]
            if @[r]?
                @[r].related = rulefactory.related @[r].relations, @, piles

    # combined number of facedown/faceup cards
    total_length: () ->
        @facedown_cards.length + @faceup_cards.length

    # shallow copy of the cards in the pile
    copy_all_cards: () ->
        down: @facedown_cards.concat()
        up: @faceup_cards.concat()

    # set all cards in one go
    set_all_cards: (cards) ->
        @facedown_cards = cards.down
        @faceup_cards = cards.up

    # split a number of cards to be withdrawn into faceup/facedown indices
    marked_indexes: () ->
        [ Math.min(@facedown_cards.length, @total_length() - @marked_withdraw),
            Math.max(0, @faceup_cards.length - @marked_withdraw) ]

    # prepare a tentative card list that would be withdrawn if a move would succeed
    # note the effective card removal count in @marked_withdraw
    show_withdraw: (number) ->
        end = @marked_indexes()
        @marked_withdraw += Math.min(number, @total_length() - @marked_withdraw)
        begin = @marked_indexes()
        @facedown_cards.slice(begin[0], end[0]).reverse().concat @faceup_cards.slice(begin[1], end[1])

    # splice the cards to be moved and call post-withdrawal actions
    exec_withdraw: () ->
        begin = @marked_indexes()
        @facedown_cards.splice begin[0], @facedown_cards.length
        @faceup_cards.splice begin[1], @faceup_cards.length
        @marked_withdraw = 0
        @on_withdraw()

    # reset @marked_withdraw
    cancel_withdraw: (number) ->
        @marked_withdraw -= number ? @marked_withdraw

    # add a group of cards to the faceup part of the pile
    exec_add: (cards) ->
        @faceup_cards = @faceup_cards.concat cards

    # identify a single card to be used in a swap
    show_swap: (part, index) ->
        @[part + "_cards"].slice(index, index + 1)[0]

    # exchange one card for another
    exec_swap: (part, index, card) ->
        @[part + "_cards"].splice(index, 1, card)[0]

    # post-withdrawal actions: execute autofill
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

    # click action:
    # test for countdown exhaustion and click evaluation rule
    # if allowed, move appropriate cards to target(s) and execute explicit click action
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

    # doubleclick action:
    # test for countdown exhaustion and available cards
    # if allowed, move appropriate cards to first available target and execute explicit dblclick action
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

    # dragend (drop) action:
    # if building the withdrawn cards on the target pile succeeds, execute withdrawal on the source pile
    # and trigger game update
    on_drop: (target, index) ->
        withdraw = @show_withdraw @total_length() - index
        if target.on_build(withdraw, @)
            @exec_withdraw()
            @actions.drop? @, target, @game.piles
            @game.update()
        else
            @cancel_withdraw()

    # try to add cards to the pile
    # successfull pairing removes the cards from both source and target pile,
    # else test for countdown exhaustion and build evaluation rule
    # if allowed execute explicit build action
    on_build: (cards, source) ->
        if @pairing_rule? and @faceup_cards.length >= 1
            @show_withdraw(1)
            test = (not (@countdown?.which is "build") or @countdown.number > 0) and
                cards.length == 1 and @pairing_rule?(cards, source)
            if test
                @exec_withdraw()
        else
            test = (not (@countdown?.which is "build") or @countdown.number > 0) and @build_rule cards, source
            if test
                @exec_add cards
        if test
            @actions.build? @, source, @game.piles
            if @countdown?.which is "build"
                @countdown.number--
        test

# "Cell" data object model
class Cell extends Pile
    classname: "Cell"

    # default ruleset options (drag allways allowed, Cell can only hold one faceup card)
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

    # for card pairing style games, construct rule function
    constructor: (game, options, deck) ->
        super game, options, deck

# "Cell" data object model
class Tableau extends Pile
    classname: "Tableau"

    # default ruleset options (cards spread out downwards, one initial faceup card,
    # all faceup cards can be dragged together)
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

    # read spread settings
    constructor: (game, options, deck) ->
        { @direction, @spread } = options
        super game, options, deck

    # if no faceup cards remain, flip the topmost facedown card
    on_withdraw: ->
        if not @faceup_cards.length and @facedown_cards.length
            @faceup_cards.push(@facedown_cards.pop())
        super

# "Stock" data object model
class Stock extends Pile
    classname: "Stock"

    # default ruleset options (click always possible and moves one card to the first Waste pile,
    # building only from a Waste pile and if the pile is empty)
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

    # if no explicit number is given, absorbs all remaining cards from the deck
    # and stacks them facedown.
    # For this reason, a Stock pile should always be the last listed in a ruleset.
    constructor: (game, options, deck) ->
        if options.initial_facedown == 0
            options.initial_facedown = deck.length
        super game, options, deck

    # all added cards go to the facedown part
    exec_add: (cards) ->
        @facedown_cards = @facedown_cards.concat cards

# "Waste" data object model
class Waste extends Pile
    classname: "Waste"

    # default ruleset options (drag always possible, click moves cards to the first Stock pile,
    # building only from a Stock pile)
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

    # click always withdraws all cards (provided it succeeds)
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

# "Reserve" data object model
class Reserve extends Pile
    classname: "Reserve"

    # default ruleset options (one initial faceup card, dragging always succeeds,
    # cards can be built only from Stock)
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

    # if no faceup cards remain, flip the topmost facedown card
    on_withdraw: ->
        if not @faceup_cards.length and @facedown_cards.length
            @faceup_cards.push(@facedown_cards.pop())
        super

# "Reserve" data object model
class Foundation extends Pile
    classname: "Foundation"

    # partial components for the build rule
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

    # construct the build rule from the options.fill object
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

    # default ruleset options (incremental, ascending fill,
    # award one point for each (faceup) card in the pile)
    default_options:
        fill:
            method: "incremental"
            dir: "asc"
        point_rule:
            both:
                cards:
                    roles: [ { heap: "self", part: "faceup" } ]

    # if fill.method is "other", leave the build rule in options intact,
    # otherwise replace it with one of the standard rules
    constructor: (game, options, deck) ->
        if options.fill.method != "other"
            @fill = options.fill.method
            options.build_rule = foundation_rule options.fill
        super game, options, deck

    # doubleclick never has targets, but could trigger a custom action
    on_dblclick: ->
        if @actions.dblclick? and (not (@countdown?.which is "dblclick") or @countdown.number > 0)
            @actions.dblclick? @, null, @game.piles
            @game.update()

