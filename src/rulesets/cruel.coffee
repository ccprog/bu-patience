ruleset = {
    title: "Cruel"
    help: "https://help.gnome.org/users/aisleriot/stable/Cruel.html"
    set: 52
    count: 1
    point_target: 48
    pilegroups: [
        pileclass: "Foundation"
        options:
            initial_faceup: 1
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "faceup" } ]
                    operator: "diff"
                    value: 1
        piles: [
            position: { x: 2, y: 0 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 4, y: 0 }
        ,
            position: { x: 5, y: 0 }
        ]
    ,
        pileclass: "Reserve"
        options:
            initial_faceup: 4
            build_rule:
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
                                dir: "recto"
                                position: 0
                    tests: [
                        prop: "suit"
                    ,
                        prop: "value"
                        operator: "diff"
                        value: 1
                    ]
        piles: [
            position: { x: 0, y: 1 }
        ,
            position: { x: 1, y: 1 }
        ,
            position: { x: 2, y: 1 }
        ,
            position: { x: 3, y: 1 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 5, y: 1 }
        ,
            position: { x: 0, y: 2 }
        ,
            position: { x: 1, y: 2 }
        ,
            position: { x: 2, y: 2 }
        ,
            position: { x: 3, y: 2 }
        ,
            position: { x: 4, y: 2 }
        ,
            position: { x: 5, y: 2 }
        ]
    ,
        pileclass: "Stock"
        options:
            action: [
                on: "click"
                name: "iterate"
                rule: [
                    name: "move"
                    rule:
                        first:
                            pile: [
                                single_tests: [
                                    prop: "pileclass"
                                    value: "Reserve"
                                ,
                                    prop: "faceup_length"
                                    value: 0
                                    compare: ">"
                                ]
                            ]
                            priority:
                                dir: "verso"
                                position: 0
                        second:
                            pile: [
                                single_tests: [
                                    prop: "pileclass"
                                    value: "Stock"
                                ]
                            ]
                            priority:
                                position: 0
                ,
                    name: "move"
                    rule:
                        first:
                            pile: [
                                single_tests: [
                                    prop: "pileclass"
                                    value: "Stock"
                                ,
                                    prop: "facedown_length"
                                    value: 0
                                    compare: ">"
                                ]
                            ]
                            priority:
                                position: 0
                        second:
                            pile: [
                                single_tests: [
                                    prop: "pileclass"
                                    value: "Reserve"
                                ,
                                    prop: "faceup_length"
                                    value: 0
                                ]
                            ]
                            priority:
                                position: 0
                        number: 4
                ]
            ]
        piles: [
            position: { x: 0, y: 0 }
        ]
    ]
    deal_action:
        name: "swap"
        rule:
            first:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Foundation"
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            compare: "!="
                            value: 1
                        ]
                    ]
                priority:
                    dir: "random"
            second:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Reserve"
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            value: 1
                        ]
                    ]
                priority:
                    dir: "random"
}
