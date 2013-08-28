ruleset = {
    title: "Doublets"
    help: "https://help.gnome.org/users/aisleriot/stable/Doublets.html"
    set: 52
    count: 1
    point_target: 48
    pilegroups: [
        pileclass: "Foundation"
        options:
            initial_faceup: 1
            fill:
                method: "other"
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
                        prop: "value"
                        operator: "division"
                        value: 2
                    ]
        piles: [
            position: { x: 3, y: 2 }
        ]
    ,
        pileclass: "Cell"
        options:
            initial_faceup: 1
            autofill:
                relations: [
                    single_tests: [
                        prop: "pileclass"
                        value: "Waste" 
                    ]
                ,
                    single_tests: [
                        prop: "pileclass"
                        value: "Stock" 
                    ]
                ]
                number: 1
            drag_rule:
                name: "one_card"
                rule:
                    select:
                        role: { heap: "self", part: "faceup" }
                        card:
                            position:
                                dir: "recto"
                                position: 0
                    tests: [
                        prop: "value"
                        compare: "!="
                        value: 13
                    ]
        piles: [
            position: { x: 2, y: 0 }
        ,
            position: { x: 2, y: 1 }
        ,
            position: { x: 2, y: 2 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 4, y: 0 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 4, y: 2 }
        ]
    ,
        pileclass: "Waste"
        options:
            countdown:
                which: "click"
                number: 2
        piles: [
            position: { x: 1, y: 0 }
        ]
    ,
        pileclass: "Stock"
        piles: [
            position: { x: 0, y: 0 }
        ]
    ],
    deal_action:
        name: "swap"
        rule:
            first:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Cell"
                        ]
                    ,
                        single_tests: [
                            prop: "pileclass"
                            value: "Foundation"
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            value: 13
                        ]
                    ]
                priority:
                    dir: "random"
            second:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Stock"
                        ]
                    ]
                    parts: [ "facedown" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            value: 13
                            compare: "!="
                        ]
                    ]
                priority:
                    dir: "random"
}
