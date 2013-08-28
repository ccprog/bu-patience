ruleset = {
    title: "Streets and Alleys"
    help: "https://help.gnome.org/users/aisleriot/stable/Streets_And_Alleys.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
        pileclass: "Foundation"
        options:
            drag_rule:
                name: "all"
        piles: [
            position: { x: 4, y: 0 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 4, y: 2 }
        ,
            position: { x: 4, y: 3 }
        ]
    ,
        pileclass: "Tableau"
        options:
            initial_faceup: 7
            direction: "right"
            spread: 3
            drag_rule:
                name: "card_sequence"
                rule:
                    select:
                        roles: [ { heap: "cards" } ]
                    count:
                        value: 1
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
                                    position: 0
                        tests: [
                            prop: "value"
                            operator: "diff"
                            value: 1
                        ]
                ]
        piles: [
            position: { x: 0, y: 0 }
        ,
            position: { x: 0, y: 1 }
        ,
            position: { x: 0, y: 2 }
        ,
            position: { x: 0, y: 3 }
        ,
            position: { x: 6, y: 0 }
            options:
                initial_faceup: 6
        ,
            position: { x: 6, y: 1 }
            options:
                initial_faceup: 6
        ,
            position: { x: 6, y: 2 }
            options:
                initial_faceup: 6
        ,
            position: { x: 6, y: 3 }
            options:
                initial_faceup: 6
        ]
    ]
}

