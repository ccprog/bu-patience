ruleset = {
    title: "Ten Across"
    help: "https://help.gnome.org/users/aisleriot/stable/Ten_Across.html"
    set: 52
    count: 1
    point_target: 48
    pilegroups: [
        pileclass: "Cell"
        options:
            initial_faceup: 1
        piles: [
            position: { x: 1, y: 0 }
        ,
            position: { x: 2, y: 0 }
        ]
    ,
        pileclass: "Tableau"
        options:
            spread: 4
            build_rule:
                name: "or"
                rule: [
                    name: "and"
                    rule: [
                        name: "card_sequence"
                        rule:
                            select:
                                roles: [ { heap: "self", part: "faceup" } ]
                            count:
                                value: 0
                    ,
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
                                value: 13
                            ]
                    ]
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
                                    position: 0
                        tests: [
                            prop: "suit"
                        ,
                            prop: "value"
                            operator: "diff"
                            value: 1
                        ]
                ]
            point_rule:
                both:
                    cards:
                        roles: [ heap: "self", part: "faceup" ]
                        cards: [
                            pairwise_tests: [
                                prop: "suit"
                            ,
                                prop: "value"
                                operator: "diff"
                                value: 1
                            ]
                        ]
        piles: [
            position: { x: 0, y: 1 }
            options:
                initial_facedown: 0
                initial_faceup: 5
        ,
            position: { x: 1, y: 1 }
            options:
                initial_facedown: 1
                initial_faceup: 4
        ,
            position: { x: 2, y: 1 }
            options:
                initial_facedown: 2
                initial_faceup: 3
        ,
            position: { x: 3, y: 1 }
            options:
                initial_facedown: 3
                initial_faceup: 2
        ,
            position: { x: 4, y: 1 }
            options:
                initial_facedown: 4
                initial_faceup: 1
        ,
            position: { x: 5, y: 1 }
            options:
                initial_facedown: 4
                initial_faceup: 1
        ,
            position: { x: 6, y: 1 }
            options:
                initial_facedown: 3
                initial_faceup: 2
        ,
            position: { x: 7, y: 1 }
            options:
                initial_facedown: 2
                initial_faceup: 3
        ,
            position: { x: 8, y: 1 }
            options:
                initial_facedown: 1
                initial_faceup: 4
        ,
            position: { x: 9, y: 1 }
            options:
                initial_facedown: 0
                initial_faceup: 5
        ]
    ]
}
