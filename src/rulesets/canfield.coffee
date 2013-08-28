ruleset = {
    title: "Canfield"
    help: "https://help.gnome.org/users/aisleriot/stable/Canfield.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
            pileclass: "Foundation"
            options:
                fill:
                    method: "other"
                drag_rule:
                    name: "all"
                build_rule:
                    name: "and",
                    rule: [
                        name: "card_sequence"
                        rule:
                            select:
                                roles: [ { heap: "self", part: "faceup" }, { heap: "cards" } ]
                            pairwise_tests: [
                                prop: "suit"
                            ,
                                prop: "value"
                                operator: "wrapped_diff"
                                value: -1
                            ]
                    ,
                        name: "or"
                        rule: [
                            name: "card_sequence",
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
                    position: { x: 3, y: 0 }
                    options:
                        initial_faceup: 1
                ,
                    position: { x: 4, y: 0}
                ,
                    position: { x: 5, y: 0 }
                ,
                    position: { x: 6, y: 0 }
            ]
        ,
            pileclass: "Tableau"
            options:
                autofill:
                    relations: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Reserve" 
                        ]
                    ]
                    number: 1
                drag_rule:
                    name: "all"
                build_rule:
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
                                prop: "color"
                                compare: "!="
                            ,
                                prop: "value"
                                operator: "wrapped_diff"
                                value: 1
                            ]
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
            pileclass: "Waste"
            options:
                countdown:
                    which: "click"
                    number: 100
            piles: [
                    position: { x: 1, y: 0 }
            ]
        ,
            pileclass: "Reserve"
            options:
                initial_facedown: 12
            piles: [
                    position: { x: 0, y: 1 }
            ]
        ,
            pileclass: "Stock"
            options:
                click:
                    relations: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Waste" 
                        ]
                    ]
                    number: 3
            piles: [
                    position: { x: 0, y: 0 }
            ]
    ]
}
