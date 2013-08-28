ruleset = {
    title: "Bakers Dozen"
    help: "https://help.gnome.org/users/aisleriot/stable/Bakers_Dozen.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
        pileclass: "Foundation"
        piles: [
            position: { x: 0, y: 0 }
        ,
            position: { x: 2, y: 0 }
        ,
            position: { x: 4, y: 0 }
        ,
            position: { x: 6, y: 0 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 4
            spread: 2
            drag_rule:
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "cards" } ]
                    count:
                        value: 1
            build_rule:
                name: "and"
                rule: [
                    name: "card_sequence"
                    rule:
                        select:
                            roles: [ { heap: "self", part: "faceup" } ]
                        count:
                            compare: ">"
                            value: 0
                ,
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
                            operator: "diff"
                            value: 1
                        ]
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
            position: { x: 6, y: 1 }
        ,
            position: { x: 0, y: 3 }
        ,
            position: { x: 1, y: 3 }
        ,
            position: { x: 2, y: 3 }
        ,
            position: { x: 3, y: 3 }
        ,
            position: { x: 4, y: 3 }
        ,
            position: { x: 5, y: 3 }
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
                            value: "Tableau"
                        ,
                            count:
                                parts: [ "faceup" ]
                                card_list: [
                                    comparison_tests: [
                                        prop: "value"
                                        operator: "max"
                                        value: 13
                                    ,
                                        prop: "value"
                                        compare: "<"
                                    ]
                                ]
                            value: 0
                            compare: ">"
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        comparison_tests: [
                            prop: "value"
                            operator: "max"
                            value: 13
                        ,
                            prop: "value"
                            compare: "<"
                        ]
                    ]
                priority:
                    dir: "recto"
                    position: 0
            second:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Tableau"
                        ,
                            count:
                                parts: [ "faceup" ]
                                card_list: [
                                    comparison_tests: [
                                        prop: "value"
                                        operator: "max"
                                        value: 13
                                    ,
                                        prop: "value"
                                        compare: "<"
                                    ]
                                ]
                            value: 0
                            compare: ">"
                        ]
                    ]
                    parts:  [ "faceup" ]
                    cards: [
                        comparison_tests: [
                            prop: "value"
                            operator: "max"
                            value: 13
                        ,
                            prop: "value"
                            compare: "<"
                        ]
                        dir: "verso"
                    ]
                priority:
                    dir: "recto"
                    position: 0
}
