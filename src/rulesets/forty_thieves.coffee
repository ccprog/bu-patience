ruleset = {
    title: "Forty Thieves"
    help: "https://help.gnome.org/users/aisleriot/stable/Forty_Thieves.html"
    set: 52
    count: 2
    point_target: 1000
    pilegroups: [
        pileclass: "Foundation"
        options:
            action: [
                on: "dblclick"
                name: "move"
                rule:
                    first:
                        pile: [
                            comparator:
                                role: "self"
                            comparison_tests: [
                                prop: "pileclass"
                                compare: "!="
                            ,
                                card:
                                    parts: [ "faceup" ]
                                    card:
                                        position:
                                            dir: "verso"
                                            position: 0
                                    prop: "suit"
                            ,
                                card:
                                    parts: [ "faceup" ]
                                    card:
                                        position:
                                            dir: "verso"
                                            position: 0
                                    prop: "value"
                                operator: "diff"
                                value: -1
                            ]
                        ]
                        priority:
                            dir: "recto"
                            position: 0
                    second:
                        pile: [
                            single_tests: [
                                prop: "role"
                                value: "self"
                            ,
                                prop: "faceup_length"
                                compare: ">"
                                value: 0
                            ]
                        ]
                        priority:
                            dir: "recto"
                            position: 0
            ]
            point_rule:
                both: [
                    cards:
                        roles: [ { heap: "self", part: "faceup" } ]
                    operator: "multi"
                    value: 5
                ,
                    piles: [
                        single_tests: [
                            prop: "role"
                            value: "self"
                        ,
                            count:
                                parts: [ "faceup" ]
                                card_list: [
                                    pairwise_tests: [
                                        prop: "suit"
                                    ]
                                ]
                            value: 12
                        ]
                    ]
                    evaluate: "length"
                    value: 60
                    operator: "multi"
                ]
        piles: [
            position: { x: 2, y: 0 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 4, y: 0}
        ,
            position: { x: 5, y: 0 }
        ,
            position: { x: 6, y: 0 }
        ,
            position: { x: 7, y: 0 }
        ,
            position: { x: 8, y: 0 }
        ,
            position: { x: 9, y: 0 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 0
            direction: "right"
            spread: 10
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
                        value: "Stock"
                    ]
        piles: [
            position: { x: 0, y: 1 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 4
            drag_rule:
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "cards" } ]
                    pairwise_tests: [
                        prop: "suit"
                    ,
                        prop: "value"
                        operator: "diff"
                        value: 1
                    ]
            build_rule:
                name: "and"
                rule: [
                    name: "or"
                    rule: [
                        name: "card_sequence"
                        rule:
                            select:
                                roles: [ { heap: "self", part: "faceup" } ]
                            count:
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
                                prop: "suit"
                            ,
                                prop: "value"
                                operator: "diff"
                                value: 1
                            ]
                    ]
                ,
                    name: "two_sequence"
                    rule:
                        first_cards:
                            roles: [ { heap: "cards" } ]
                        second_piles: [
                            single_tests: [
                                prop: "index"
                                value: 8
                                compare: "!="
                            ,
                                prop: "pileclass"
                                value: "Tableau"
                            ,
                                prop: "role"
                                value: "none"
                            ,
                                prop: "faceup_length"
                                value: 0
                            ]
                        ]
                        count:
                            operator: "diff"
                            compare: "<="
                            value: 1
                ]
        piles: [
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
        ,
            position: { x: 6, y: 2 }
        ,
            position: { x: 7, y: 2 }
        ,
            position: { x: 8, y: 2 }
        ,
            position: { x: 9, y: 2 }
        ]
    ,
        pileclass: "Stock"
        options:
            click:
                relations: [
                    single_tests: [
                        prop: "index"
                        value: 8
                    ]
                ]
            build_rule:
                name: "none"
        piles: [
            position: { x: 0, y: 0 }
        ]
    ]
}
