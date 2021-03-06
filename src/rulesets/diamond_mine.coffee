ruleset = {
    title: "Diamond Mine"
    help: "https://help.gnome.org/users/aisleriot/stable/Diamond_Mine.html"
    set: 52
    count: 1
    point_target: 100
    pilegroups: [
        pileclass: "Foundation"
        options:
            fill:
                method: "other"
            build_rule:
                name: "and"
                rule: [
                    name: "one_card"
                    rule:
                        select:
                            role: { heap: "cards" }
                            card:
                                position:
                                    dir: "recto"
                                    position: 0
                        tests: [
                            prop: "suit"
                            value: "diamond"
                        ]
                ,
                    name: "card_sequence"
                    rule:
                        select:
                            roles: [ { heap: "self", part: "faceup" }, { heap: "cards" } ]
                        pairwise_tests: [
                            prop: "value"
                            operator: "wrapped_diff"
                            value: -1
                        ]
                ]
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "faceup" } ]
                    evaluate: "value"
        piles: [
            position: { x: 6, y: 0 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_facedown: 3
            drag_rule:
                name: "or"
                rule: [
                    name: "card_sequence"
                    rule:
                        select:
                            roles: [ { heap: "cards" } ]
                        count:
                            value: 1
                ,
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
                ]
            build_rule:
                name: "and"
                rule: [
                    name: "one_card"
                    rule:
                        select:
                            role: { heap: "cards" }
                            card:
                                position:
                                    dir: "recto"
                                    position: 0
                        tests: [
                            prop: "suit"
                            compare: "!="
                            value: "diamond"
                        ]
                ,
                    name: "or"
                    rule: [
                        name: "card_sequence"
                        rule:
                            select:
                                roles: [ { heap: "self", part: "faceup" } ]
                            count:
                                value: 0
                    ,
                        name: "and"
                        rule: [
                            name: "one_card"
                            rule:
                                select:
                                    role: { heap: "self", part: "faceup" }
                                    card:
                                        position:
                                            dir: "verso"
                                            position: 0
                                tests: [
                                    prop: "suit"
                                    compare: "!="
                                    value: "diamond"
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
                                            dir: "recto"
                                            position: 0
                                tests: [
                                    prop: "value"
                                    operator: "diff"
                                    value: 1
                                ]
                        ]
                    ]
                ]
            point_rule:
                both:
                    piles: [
                        single_tests: [
                            prop: "role"
                            value: "self"
                        ,
                            prop: "facedown_length"
                            value: 0
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
                    value: 3
                    operator: "multi"
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
            position: { x: 7, y: 1 }
        ,
            position: { x: 8, y: 1 }
        ,
            position: { x: 9, y: 1 }
        ,
            position: { x: 10, y: 1 }
        ,
            position: { x: 11, y: 1 }
        ,
            position: { x: 12, y: 1 }
        ]
    ]
}
