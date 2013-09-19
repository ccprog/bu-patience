ruleset = {
    title: "Plait"
    help: "https://help.gnome.org/users/aisleriot/stable/Plait.html"
    set: 52
    count: 2
    point_target: 104
    pilegroups: [
        pileclass: "Foundation"
        options:
            fill:
                method: "other"
            build_rule:
                name: "or"
                rule: [
                    name: "or"
                    rule: [
                        name: "and"
                        rule: [
                            name: "card_sequence"
                            rule:
                                select:
                                    piles: [
                                        single_tests: [
                                            prop: "pileclass"
                                            value: "Foundation"
                                        ,
                                            prop: "faceup_length"
                                            value: 1
                                            compare: ">"
                                        ]
                                    ]
                                    parts: [ "faceup" ]
                                    cards: [
                                        range:
                                            to: 2
                                    ]
                                pairwise_tests: [
                                    prop: "value"
                                    operator: "wrapped_diff"
                                    value: 1
                                ]
                        ,
                            name: "two_card"
                            rule:
                                first:
                                    role: { heap: "self", part: "faceup" }
                                    card:
                                        position:
                                            position: 0
                                            dir: "verso"
                                second:
                                    role: { heap: "cards" }
                                    card:
                                        position:
                                            position: 0
                                            dir: "verso"
                                tests: [
                                    prop: "suit"
                                ,
                                    prop: "value"
                                    operator: "wrapped_diff"
                                    value: 1
                                ]
                        ]
                    ,
                        name: "and"
                        rule: [
                            name: "card_sequence"
                            rule:
                                select:
                                    piles: [
                                        single_tests: [
                                            prop: "pileclass"
                                            value: "Foundation"
                                        ,
                                            prop: "faceup_length"
                                            value: 1
                                            compare: ">"
                                        ]
                                    ]
                                    parts: [ "faceup" ]
                                    cards: [
                                        range:
                                            to: 2
                                    ]
                                pairwise_tests: [
                                    prop: "value"
                                    operator: "wrapped_diff"
                                    value: -1
                                ]
                        ,
                            name: "two_card"
                            rule:
                                first:
                                    role: { heap: "self", part: "faceup" }
                                    card:
                                        position:
                                            position: 0
                                            dir: "verso"
                                second:
                                    role: { heap: "cards" }
                                    card:
                                        position:
                                            position: 0
                                            dir: "verso"
                                tests: [
                                    prop: "suit"
                                ,
                                    prop: "value"
                                    operator: "wrapped_diff"
                                    value: -1
                                ]
                        ]
                    ,
                        name: "and"
                        rule: [
                             name: "pile_sequence"
                             rule:
                                select: [
                                    single_tests: [
                                        prop: "pileclass"
                                        value: "Foundation"
                                    ,
                                        prop: "faceup_length"
                                        value: 1
                                        compare: ">"
                                    ]
                                ]
                                count:
                                    value: 0
                        ,
                            name: "card_sequence"
                            rule:
                                select:
                                    roles: [ { heap: "self", part: "faceup" }, { heap: "cards" } ]
                                pairwise_tests: [
                                    prop: "suit"
                                ,
                                    prop: "value"
                                    operator: "wrapped_abs_diff"
                                    value: 1
                                ]
                        ]
                    ]
                ,
                    name: "and"
                    rule: [
                        name: "one_pile"
                        rule:
                            select:
                                role: "self"
                            tests: [
                                prop: "faceup_length"
                                value: 0
                            ]
                    ,
                        name: "two_card"
                        rule:
                            first:
                                role: { heap: "cards" }
                                card:
                                    position:
                                        dir: "recto"
                                        position: 0
                            second:
                                pile:
                                    single_tests: [
                                        prop: "pileclass"
                                        value: "Foundation"
                                    ]
                                parts: [ "faceup" ]
                                card:
                                    position:
                                        dir: "recto"
                                        position: 0
                            tests: [
                                prop: "value"
                            ]
                    ]
                ]
        piles: [
            position: { x: 8, y: 0 }
            options:
                initial_faceup: 1
        ,
            position: { x: 8, y: 1 }
        ,
            position: { x: 8, y: 2 }
        ,
            position: { x: 8, y: 3 }
        ,
            position: { x: 9, y: 0 }
        ,
            position: { x: 9, y: 1 }
        ,
            position: { x: 9, y: 2 }
        ,
            position: { x: 9, y: 3 }
        ]
    ,
        pileclass: "Cell"
        options:
            initial_faceup: 1
            build_rule:
                name: "one_pile"
                rule:
                    select:
                        role: "other"
                    tests: [
                        prop: "pileclass"
                        value: "Tableau"
                        compare: "!="
                    ]
        piles: [
            position: { x: 0, y: 1 }
        ,
            position: { x: 1, y: 1 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 5, y: 1 }
        ,
            position: { x: 0, y: 2 }
        ,
            position: { x: 1, y: 2 }
        ,
            position: { x: 4, y: 2 }
        ,
            position: { x: 5, y: 2 }
        ]
    ,
        pileclass: "Cell"
        options:
            initial_faceup: 1
            autofill:
                relations: [
                    single_tests: [
                        prop: "pileclass"
                        value: "Tableau" 
                    ]
                ]
                number: 1
        piles: [
            position: { x: 0.5, y: 0 }
        ,
            position: { x: 4.5, y: 0 }
        ,
            position: { x: 0.5, y: 3 }
        ,
            position: { x: 4.5, y: 3 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 20
            spread: 4
            drag_rule:
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "cards" } ]
                    count:
                        value: 1
            build_rule:
                name: "none"
        piles: [
            position: { x: 2.5, y: 0 }
        ]
    ,
        pileclass: "Waste"
        options:
                countdown:
                    which: "click"
                    number: 2
        piles: [
            position: { x: 6, y: 1.5 }
        ]
    ,
        pileclass: "Stock"
        piles: [
            position: { x: 7, y: 1.5 }
        ]
    ]
}

