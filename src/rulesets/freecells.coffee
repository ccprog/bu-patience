ruleset = {
    title: "Freecell"
    help: "https://help.gnome.org/users/aisleriot/stable/Freecell.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
            pileclass: "Cell"
            piles:[
                    position: { x: 0, y: 0 }
                ,
                    position: { x: 1, y: 0 }
                ,
                    position: { x: 2, y: 0 }
                ,
                    position: { x: 3, y: 0 }
            ]
        ,
            pileclass: "Foundation"
            piles: [
                    position: { x: 4, y: 0 }
                ,
                    position: { x: 5, y: 0 }
                ,
                    position: { x: 6, y: 0 }
                ,
                    position: { x: 7, y: 0 }
            ]
        ,
            pileclass: "Tableau"
            options:
                initial_facedown: 0
                initial_faceup: 6
                drag_rule:
                    name: "card_sequence"
                    rule:
                        select:
                            roles: [ { heap: "cards" } ]
                        pairwise_tests: [
                            prop: "color"
                            compare: "!="
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
                                    prop: "color"
                                    compare: "!="
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
                                    prop: "pileclass"
                                    compare: "!="
                                    value: "Foundation"
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
                    position: { x: 0, y: 1 }
                    options:
                        initial_faceup: 7
                ,
                    position: { x: 1, y: 1 }
                    options:
                        initial_faceup: 7
                ,
                    position: { x: 2, y: 1}
                    options:
                        initial_faceup: 7
                ,
                    position: { x: 3, y: 1 }
                    options:
                        initial_faceup: 7
                ,
                    position: { x: 4, y: 1 }
                ,
                    position: { x: 5, y: 1 }
                ,
                    position: { x: 6, y: 1 }
                ,
                    position: { x: 7, y: 1 }
            ]
    ]
}
