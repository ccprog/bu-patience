ruleset = {
    title: "Klondike"
    help: "https://help.gnome.org/users/aisleriot/stable/Klondike.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
            pileclass: "Foundation"
            piles: [
                    position: { x: 3, y: 0 }
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
            piles: [
                    position: { x: 0, y: 1}
                    options:
                        initial_facedown: 0
                ,
                    position: { x: 1, y: 1 }
                    options:
                        initial_facedown: 1
                ,
                    position: { x: 2, y: 1 }
                    options:
                        initial_facedown: 2
                ,
                    position: { x: 3, y: 1 }
                    options:
                        initial_facedown: 3
                ,
                    position: { x: 4, y: 1 }
                    options:
                        initial_facedown: 4
                ,
                    position: { x: 5, y: 1 }
                    options:
                        initial_facedown: 5
                ,
                    position: { x: 6, y: 1 }
                    options:
                        initial_facedown: 6
            ]
        ,
            pileclass: "Waste"
            options:
                countdown:
                    which: "click"
                    number: 1
            piles: [
                    position: { x: 1, y: 0 }
            ]
        ,
            pileclass: "Stock"
            piles: [
                    position: { x: 0, y: 0 }
            ]
    ]
}
