class Game
            
    advise = (self, pile) ->
        for name, funct of pile
            if name.search(/^exec_/) == 0 then do (name, funct) ->
                point = funct
                pile[name] = ->
                    old_step = new Step pile, "old"
                    doublet = self.pending.filter (entry) ->
                        entry.pile is pile
                    if not doublet.length
                        self.pending.push(old_step)
                    point.apply pile, arguments

    constructor: (@area, ruleset) ->
#        try
            deck = []
            @piles = []

            smallest = 14 - Math.floor ruleset.set / 4
            for c in [0...ruleset.count]
                for s in base.suit_names
                    for v in [smallest..13]
                        deck.push(new Card s, v)
                if ruleset.set % 4 == 2
                    deck.push(new Card 'joker', 1)
                    deck.push(new Card 'joker', 2)
            base.shuffle deck

            size = { x: 0, y: 0 }
            @pending = []
            @history = []
            @history_pointer = 0
            @point_target = ruleset.point_target
            @points = 0

            for pg in ruleset.pilegroups
                for po in pg.piles
                    options = rulefactory.merge(
                        Pile::default_options, base.pile_classes[pg.pileclass]::default_options
                    )
                    options = rulefactory.merge options, (pg.options ? {})
                    options = rulefactory.merge options, po.options ? {}
                    if pg.pileclass is "Tableau"
                        options.direction ?= "down"
                        options.spread ?= if options.direction == "down" then 3 else 2
                    size.x = Math.max(size.x, po.position.x + 
                        (if options.direction == "right" then options.spread else 1))
                    size.y = Math.max(size.y, po.position.y + 
                        (if options.direction == "down" then options.spread else 1))

                    pile = new base.pile_classes[pg.pileclass] @, options, deck
                    pile.position = po.position
                    advise @, pile
                    @piles.push pile

            if ruleset.deal_action?
                action = rulefactory.get_action ruleset.deal_action, () ->
                action null, null, @piles

            @area.initialize @, size
            for pile in @piles
                pile.init_related @piles
                if not (pile.classname is "Foundation")
                    pile.dblclick_targets = @piles.filter( (p) ->
                        p.classname is "Foundation"
                    )
                @area.add_pile pile
                @points += pile.point_rule("new")

            @set_all_infos()
            @timer = new Timer @area
#        catch e
#            console.log e.message, e.object

    update: () ->
        steps = @pending.map (entry) ->
            { old: entry, new: entry.to_new() }
        @pending = []
        for entry in steps
            @area.alter_pile entry.new.pile
            @points += entry.new.point_delta
        @history.splice @history_pointer
        @history_pointer++
        @history.push steps
        @set_all_infos()
        if not @timer.running
            @timer.start()
        else if @points == @point_target
            @timer.stop()
            @area.highlight_win()

    move = (timing) ->
        step_list = @history[@history_pointer - (if timing is "old" then 1 else 0)]
        for entry in step_list
            step = entry[timing]
            step.pile.set_all_cards step.cards
            if step.countdown?
                step.pile.countdown.number = step.countdown
            @area.alter_pile step.pile
            @points += step.point_delta

    undo: ->
        if @history_pointer == 0 then return -1
        move.call @, "old"
        @history_pointer--
        @set_all_infos()

    redo: ->
        if @history_pointer == @history.length then return -1
        move.call @, "new"
        @history_pointer++
        @set_all_infos()

    alter_points: (delta) ->
        @points += delta

    set_all_infos: () ->
        stock_count = 0
        @piles.forEach( (p) ->
            if p instanceof Stock
                stock_count += p.facedown_cards.length
        )
        @area.set_info "remaining", stock_count
        @area.set_info "moves", @history_pointer
        @area.set_info "points", @points

    destroy: () ->
        if @timer?
            @timer.reset()
            @timer = undefined

class Card
    constructor: (suit, value) ->
        @suit = suit
        @value = value

    getColor: () ->
        switch @suit
            when 'club', 'spade' then "black"
            else "red"

class Step
    constructor: (pile, timing) ->
        @cards = pile.copy_all_cards()
        @pile = pile
        @countdown = pile.countdown?.number
        @point_delta = pile.point_rule(timing)

    to_new: () ->
        after = new Step @pile, "new"
        @point_delta -= after.point_delta
        after.point_delta = -@point_delta
        after

class Timer
    constructor: (a) ->
        @format = d3.time.format.utc "%X"
        @area = a
        @reset()

    poll: =>
        dif = new Date Date.now() - @start_time
        @area.set_info "time", @format dif

    start: ->
        @running = true
        @start_time = Date.now()
        @loop = setInterval @poll, 500

    stop: ->
        clearInterval @loop

    reset: ->
        @running = false
        clearInterval @loop
        @area.set_info "time", '00:00:00'

