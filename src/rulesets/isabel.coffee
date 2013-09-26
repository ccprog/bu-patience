ruleset = {
    title: "Isabel"
    help: "https://help.gnome.org/users/aisleriot/stable/Isabel.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
        pileclass: "Reserve"
        options:
            initial_facedown: 3
            pairing_rule:
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
                    ]
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "facedown" }, { heap: "self", part: "faceup" } ]
                    operator: "diff"
                    value: 4
                    dir: "verso"
        piles: [
            position: { x: 0, y: 0 }
        ,
            position: { x: 0, y: 1 }
        ,
            position: { x: 0, y: 2 }
        ,
            position: { x: 1.5, y: 0.5 }
        ,
            position: { x: 1.5, y: 1.5 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 3, y: 1 }
        ,
            position: { x: 3, y: 2 }
        ,
            position: { x: 4.5, y: 0.5 }
        ,
            position: { x: 4.5, y: 1.5 }
        ,
            position: { x: 6, y: 0 }
        ,
            position: { x: 6, y: 1 }
        ,
            position: { x: 6, y: 2 }
        ]
    ]
}
