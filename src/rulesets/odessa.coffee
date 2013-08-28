ruleset = {
    title: "Odessa"
    help: "https://help.gnome.org/users/aisleriot/stable/Odessa.html"
    set: 52
    count: 1
    point_target: 412
    pilegroups: [
        pileclass: "Foundation"
        piles: [
            position: { x: 0, y: 0 }
        ,
            position: { x: 0, y: 1 }
        ,
            position: { x: 0, y: 2 }
        ,
            position: { x: 0, y: 3 }
        ]
    ,
        pileclass: "Tableau"
        options:
            spread: 4
            initial_facedown: 3
            initial_faceup: 5
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
                old:
                    fixed: 0
                new:
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
            position: { x: 1, y: 0 }
            options:
                initial_faceup: 3
        ,
            position: { x: 2, y: 0 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 4, y: 0 }
        ,
            position: { x: 5, y: 0 }
        ,
            position: { x: 6, y: 0 }
        ,
            position: { x: 7, y: 0 }
            options:
                initial_faceup: 3
        ]
    ]
}
