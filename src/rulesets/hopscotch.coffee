get_hs_foundation_rule = (nr) ->
    {
        name: "two_card"
        rule:
            first:
                role: { heap: "self", part: "faceup" }
                card:
                    position:
                        dir: "verso"
                        position: 0
            second:
                role: { heap: "cards" }
                card:
                    position:
                        position: 0
            tests: [
                prop: "value"
                operator: "wrapped_diff"
                value: -nr
            ]
    }
    
get_hs_swap_rule = (nr) ->
    {
        name: "swap"
        rule:
            first:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Foundation"
                        ,
                            prop: "position_x"
                            value: nr + 2
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "suit"
                            value: "club"
                            compare: "!="
                        ]
                    ,
                        single_tests: [
                            prop: "value"
                            value: nr
                            compare: "!="
                        ]
                    ]
                priority:
                    position: 0
            second:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Stock"
                        ]
                    ,
                        single_tests: [
                            prop: "pileclass"
                            value: "Foundation"
                        ,
                            prop: "position_x"
                            compare: "!="
                            value: nr + 2
                        ]
                    ]
                    parts: [ "facedown", "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "suit"
                            value: "club"
                        ,
                            prop: "value"
                            value: nr
                        ]
                    ]
                priority:
                    dir: "recto"
                    position: 0
    }

ruleset = {
    title: "Hopscotch"
    help: "https://help.gnome.org/users/aisleriot/stable/Hopscotch.html"
    set: 52
    count: 1
    point_target: 48
    pilegroups: [
        pileclass: "Foundation"
        options:
            initial_faceup: 1
            fill:
                method: "other"
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "faceup" } ]
                    evaluate: "length"
                    value: -1
                    operator: "plus"
        piles: [
            position: { x: 3, y: 0 }
            options:
                build_rule: get_hs_foundation_rule(1)
        ,
            position: { x: 4, y: 0 }
            options:
                build_rule: get_hs_foundation_rule(2)
        ,
            position: { x: 5, y: 0 }
            options:
                build_rule: get_hs_foundation_rule(3)
        ,
            position: { x: 6, y: 0 }
            options:
                build_rule: get_hs_foundation_rule(4)
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 0
            drag_rule:
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "cards" } ]
                    count:
                        value: 1
            build_rule:
                name: "one_pile"
                rule:
                    select:
                        role: "other"
                    tests: [
                        prop: "pileclass"
                        value: "Cell"
                    ]
        piles: [
            position: { x: 3, y: 1 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 5, y: 1 }
        ,
            position: { x: 6, y: 1 }
        ]
    ,
        pileclass: "Cell"
        options:
            build_rule:
                name: "and"
                rule: [
                    name: "one_pile"
                    rule:
                        select:
                            role: "other"
                        tests: [
                            prop: "pileclass"
                            value: "Stock"
                        ]
                ,
                    name: "one_pile"
                    rule:
                        select:
                            role: "self"
                        tests: [
                            prop: "faceup_length"
                            value: 0
                        ]
                ]
        piles: [
            position: { x: 1, y: 0 }
        ]
    ,
        pileclass: "Stock"
        options:
            click: 
                relations: [
                    single_tests: [
                        prop: "pileclass"
                        value: "Cell" 
                    ]
                ]
        piles: [
            position: { x: 0, y: 0 }
        ]
    ]
    deal_action:
        name: "iterate"
        rule: [
            get_hs_swap_rule(1)
        ,
            get_hs_swap_rule(2)
        ,
            get_hs_swap_rule(3)
        ,
            get_hs_swap_rule(4)
        ]
}
