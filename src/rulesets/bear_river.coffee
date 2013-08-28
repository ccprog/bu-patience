br_rules_basic =
    name: "and"
    rule: [
        name: "card_sequence"
        rule:
            select:
                roles: [ { heap: "self", part: "faceup" }, { heap: "cards" } ]
            count:
                compare: "<="
                value: 3
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
                operator: "wrapped_abs_diff"
                value: 1
            ]
    ]

br_rules_none =
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
        br_rules_basic
    ]

br_rules_all =
    name: "or"
    rule: [
        name: "card_sequence"
        rule:
            select:
                roles: [ { heap: "self", part: "faceup" } ]
            count:
                value: 0
    ,
        br_rules_basic
    ]

ruleset = {
    title: "Bear River"
    help: "https://help.gnome.org/users/aisleriot/stable/Bear_River.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
            pileclass: "Foundation"
            options:
                fill:
                    method: "other"
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
                    position: { x: 1.5, y: 0 }
                    options:
                        initial_faceup: 1
                ,
                    position: { x: 3, y: 0 }
                ,
                    position: { x: 4.5, y: 0 }
                ,
                    position: { x: 6, y: 0 }
            ]
        ,
            pileclass: "Tableau"
            options:
                initial_faceup: 3
                direction: "right"
                spread: 1.5
                drag_rule:
                    name: "card_sequence"
                    rule:
                        select:
                            roles: [ { heap: "cards" } ]
                        count:
                            value: 1
                build_rule: br_rules_none
            piles: [
                    position: { x: 0, y: 1 }
                ,
                    position: { x: 1.5, y: 1 }
                ,
                    position: { x: 3, y: 1 }
                ,
                    position: { x: 4.5, y: 1 }
                ,
                    position: { x: 6, y: 1 }
                ,
                    position: { x: 7.5, y: 1 }
                    options:
                        initial_faceup: 2
                        build_rule: br_rules_all
                ,
                    position: { x: 0, y: 2 }
                ,
                    position: { x: 1.5, y: 2 }
                ,
                    position: { x: 3, y: 2 }
                ,
                    position: { x: 4.5, y: 2 }
                ,
                    position: { x: 6, y: 2 }
                ,
                    position: { x: 7.5, y: 2 }
                    options:
                        initial_faceup: 2
                        build_rule: br_rules_all
                ,
                    position: { x: 0, y: 3 }
                ,
                    position: { x: 1.5, y: 3 }
                ,
                    position: { x: 3, y: 3 }
                ,
                    position: { x: 4.5, y: 3 }
                ,
                    position: { x: 6, y: 3 }
                ,
                    position: { x: 7.5, y: 3 }
                    options:
                        initial_faceup: 2
                        build_rule: br_rules_all
            ]
    ]
}
