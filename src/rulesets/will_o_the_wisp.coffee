sp_point_rule =
    both:
        cards:
            roles: [ { heap: "self", part: "faceup" } ]
            cards: [
                pairwise_tests: [
                    prop: "suit"
                ,
                    prop: "value"
                    operator: "diff"
                    value: 1
                ]
            ]

ruleset = {
    title: "Will o' the Wisp"
    help: "https://help.gnome.org/users/aisleriot/stable/Will_O_The_Wisp.html"
    set: 52
    count: 1
    point_target: 48
    pilegroups: [
            pileclass: "Foundation"
            options:
                fill: 
                    method: "once"
                    dir: "desc"
                point_rule: sp_point_rule
            piles: [
                    position: { x: 3, y: 0 }
                ,
                    position: { x: 4, y: 0 }
                ,
                    position: { x: 5, y: 0 }
                ,
                    position: { x: 6, y: 0 }
            ]
        ,
            pileclass: "Tableau"
            options:
                spread: 3
                initial_facedown: 2
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
                    name: "or"
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
                                prop: "value"
                                operator: "diff"
                                value: 1
                            ]
                    ]
                point_rule: sp_point_rule
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
            ]
        ,
            pileclass: "Stock"
            options:
                click: 
                    relations: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Tableau" 
                        ]
                    ]
                click_rule:
                    name: "pile_sequence"
                    rule:
                        select: [
                            single_tests: [
                                prop: "pileclass"
                                value: "Tableau"
                            ,
                                prop: "total_length"
                                value: 0
                            ]
                        ]
                        count:
                            value: 0
            piles: [
                    position: { x: 0, y: 0 }
            ]
    ]
}
