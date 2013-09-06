# grafical gamepad, view part of the app
class Area
    addr = ["cards/card_", ".png"]
    raster =
        x: 110
        y: 165
        space: 10
        fan_x: 20
        fan_y: 26

    # counstruct simplified object for d3 data from pile
    to_view = (pile) ->
        dl = pile.facedown_cards.length
        pile.facedown_cards.map( (card, i) ->
            key: "#{pile.position.x*100 + pile.position.y}_b_#{i}"
            ref: addr[0] + "back" + addr[1],
            back: true,
            x: 0,
            y: 0
        ).concat(pile.faceup_cards.map (card, i) ->
            key: "#{pile.position.x*100 + pile.position.y}_#{card.value}_#{card.suit}_#{i + dl}"
            ref: addr[0] + "#{card.value}_#{card.suit}" + addr[1]
            back: false
            x: 0,
            y: 0
        )

    # identify the stack a hovering group of cards is over
    # uses unscaled coordinates
    is_over = (stacks, rx, ry) ->
        stacks.filter( (s, i) ->
            switch s.pile.direction
                when "down"
                    Math.abs(s.x - rx) < raster.x / 2 && -0.5 < (ry - s.y) / raster.y < s.pile.spread - 0.5
                when "up"
                    Math.abs(s.x - rx) < raster.x / 2 && 0.5 - s.pile.spread < (ry - s.y) / raster.y < 0.5
                when "left"
                    0.5 - s.pile.spread < (rx - s.x) / raster.x < 0.5 && Math.abs(s.y - ry) < raster.y / 2
                when "right"
                    -0.5 < (rx - s.x) / raster.x < s.pile.spread - 0.5 && Math.abs(s.y - ry) < raster.y / 2
                else
                    Math.abs(s.x - rx) < raster.x / 2 && Math.abs(s.y - ry) < raster.y / 2
        )[0]

    # show a single card on top of its pile
    set_flashing =  (d) ->
        d.flashing = true
        d3.event.preventDefault()
        d3.select(this).style "z-index", "5"

    # stick the flashing card back in its place
    remove_flashing = (d) ->
        if d.flashing
            d3.select(this).style "z-index", null
        d.flashing = false

    # callback on receiving a new ruleset by xhr
    # sets informations and inits a new Game object
    on_ruleset = (ruleset) ->
        d3.select("title").text("Patience: " + ruleset.title)
        d3.select("#newgame").on "click", () =>
            @new_game ruleset
        @infos.filter("#help").on "click", () ->
            if not @help_window? or @help_window.closed
                @help_window = window.open ruleset.help
            else
                @help_window.location = ruleset.help
         @new_game ruleset

    resize_timeout = null

    # preparatory: insert dynamic style rule, identify initial ruleset and load it
    constructor: (@pad, @infos, standard_url) ->
        sheet = d3.select("head").append("style").property("sheet")
        sheet.insertRule "img {}", 0
        @rule = sheet.cssRules[0]

        try
            rs_url = localStorage.getItem("ruleset")
        catch e
            rs_url = standard_url
        if not rs_url
            rs_url = standard_url
        @selector = d3.select("select#ruleset")
            .property("value", rs_url)
            .on("change", () =>
                rs_url = @selector.property "value"
                @change_game(rs_url)
            )
        @change_game(rs_url)

    # load a ruleset and store its name persistently
    change_game: (rs_url) ->
        try
            localStorage.setItem "ruleset", rs_url
        catch e

        d3.json(rs_url, (e, ruleset) =>
            if e
                throw new Error "no ruleset received\n" + e.message
            else
                on_ruleset.call @, ruleset
        )

    # exchange the Game object
    new_game: (ruleset) ->
        @game?.destroy()
        @game = new Game @, ruleset

    # prepare the pad for a new game
    initialize: (game, size) ->
        d3.select("button#prev").on "click", -> game.undo()
        d3.select("button#next").on "click", -> game.redo()
        @pad.selectAll("div").remove()
        @stacks = []
        @hover = false

        @width = raster.x * size.x + raster.space
        @height = raster.y * size.y
        @scale = 1
        d3.select(window).on "resize", () =>
            if resize_timeout
                clearTimeout resize_timeout
            resize_timeout = setTimeout( () =>
                @resize()
                resize_timeout = null
            , 100)
        @resize()

    # itentify the stack presenting a pile data object
    get_stack: (pile) ->
        @stacks.filter( (s) ->
            s.pile is pile
        )[0]

    # set stack positions and card sizes so that the game fits into the pad
    resize: ->
        @scale = Math.min @pad.property("clientWidth")/ @width, @pad.property("clientHeight")/ @height
        @rule.style.width = Math.round(101*@scale) + "px"
        @rule.style.height = Math.round(156*@scale) + "px"
        for stack in @stacks
            stack.outer.style("top", Math.round(@scale * stack.y) + "px")
        	    .style("left", Math.round(@scale * stack.x) + "px")
        	    @alter_pile stack.pile

    # insert a stack into the pad presenting a pile data object
    # init click and dblclick events and callbacks
    add_pile: (pile) ->
        stack =
            pile: pile
            x: raster.x * pile.position.x + raster.space
            y: raster.y * pile.position.y
            trans_x: 0
            trans_y: 0
        stack.outer = @pad.append("div")
        	.classed("stack", true)
        	.style("top", Math.round(@scale * stack.y) + "px")
        	.style("left", Math.round(@scale * stack.x) + "px")
        stack.outer.append("img")
            .attr("src", addr[0] + "empty" + addr[1])
            .on("dragstart", () ->
                d3.event.preventDefault()
            )
        stack.inner = stack.outer.append("div")
            .classed("stack", true)
        if pile.dblclick_targets?
            stack.inner.on("dblclick", -> pile.on_dblclick())
        if pile.click?
            stack.outer.on("click", -> pile.on_click())

        @stacks.push stack
        @alter_pile pile

    # update the cards depicted in a stack d3 data style
    # init right click and dragging events and callbacks
    alter_pile: (pile) ->
        can_drag = hg = undefined
        dragging = d3.behavior.drag()
            .origin(-> {x:0, y:0})
            .on("dragstart", (d, i) =>
                if d3.event.sourceEvent.button == 0 and pile.drag_rule(i)
                    can_drag = true
                    hg = stack.inner.selectAll("img").filter( (d, j) ->
                        j>=i
                    )
            ).on("drag", (d, i) =>
                if can_drag
                    if not @hover
                        stack.outer.style "z-index", "5"
                        @hover = true
                    d.x = d3.event.x
                    d.y = d3.event.y
                    for pre in [ "-moz-", "-webkit-", "" ]
                        hg.style(pre + "transform", "translate(#{d.x}px,#{d.y}px)")
            ).on("dragend", (d, i) =>
                if can_drag
                    rx = stack.x + (d.x / @scale) + i * stack.trans_x
                    ry = stack.y + (d.y / @scale) + i * stack.trans_y
                    over = is_over @stacks, rx, ry
                    d.x = 0
                    d.y = 0
                    for pre in [ "-moz-", "-webkit-", "" ]
                        hg.style(pre + "transform", null)
                    can_drag = @hover = false
                    stack.outer.style "z-index", null
                    if over && over.pile isnt pile
                        pile.on_drop over.pile, i
            )

        stack = @get_stack(pile)
        total = pile.total_length()
        switch pile.direction
            when "down"
                stack.trans_y = Math.min raster.fan_y, raster.y * (pile.spread - 1) / (total - 1)
            when "up"
                stack.trans_y = -Math.min raster.fan_y, raster.y * (pile.spread - 1) / (total - 1)
            when "right"
                stack.trans_x = Math.min raster.fan_x, raster.x * (pile.spread - 1) / (total - 1)
            when "left"
                stack.trans_x = -Math.min raster.fan_x, raster.x * (pile.spread - 1) / (total - 1)

        card_names = to_view pile
        gd = stack.inner.selectAll("img").data(card_names, (d) -> d.key)
        gd.enter().append("img")
        gd.attr("src", (d) -> d.ref)
            .style("left", (d, i) => (stack.trans_x * i * @scale).toFixed(2) + "px")
            .style("top", (d, i) => (stack.trans_y * i * @scale).toFixed(2) + "px")
            .call(dragging)
        gd.exit().remove()

        flashing = null
        gd.each( (d, i) ->
            card = d3.select this
            if d.back
                card.on("contextmenu", null)
                    .on("mouseup", null)
                    .on("mouseout", null)
            else
                card.on("contextmenu", set_flashing)
                    .on("mouseup", remove_flashing)
                    .on("mouseout", remove_flashing)
        )
        true

    # update an individual info span
    set_info: (id, value) ->
        @infos.classed "win", false
        @infos.filter("#" + id).select(".data").text value

    # mark appropriate info spans on a game win
    highlight_win: () ->
        @infos.filter("#time, #points").classed "win", true

# entry point
init = (standard_url) ->
    pad = d3.select("#area")
    infos = d3.selectAll(".info")
    area = new Area pad, infos, standard_url

