ruleset = {
    title: "Quatorze"
    help: "https://help.gnome.org/users/aisleriot/stable/Quatorze.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
        pileclass: "Cell"
        options:
            initial_faceup: 1
            pairing_rule:
                name: "and"
                rule: [
                    name: "one_pile"
                    rule:
                        select:
                            role: "other"
                        tests: [
                            prop: "pileclass"
                            value: "Cell"
                        ]
                ,
                    name: "or"
                    rule: [
                        name: "two_pile"
                        rule:
                            first:
                                role: "self"
                            second:
                                role: "other"
                            tests: [
                                prop: "position_x"
                            ]
                    ,
                        name: "two_pile"
                        rule:
                            first:
                                role: "self"
                            second:
                                role: "other"
                            tests: [
                                prop: "position_y"
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
                            prop: "value"
                            operator: "plus"
                            value: 14
                        ]
                ]
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "faceup" } ]
                    operator: "diff"
                    value: 1
                    dir: "verso"
        piles: [
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
            position: { x: 2, y: 2 }
        ,
            position: { x: 3, y: 2 }
        ,
            position: { x: 4, y: 2 }
        ,
            position: { x: 5, y: 2 }
        ,
            position: { x: 6, y: 2 }
        ,
            position: { x: 2, y: 3 }
        ,
            position: { x: 3, y: 3 }
        ,
            position: { x: 4, y: 3 }
        ,
            position: { x: 5, y: 3 }
        ,
            position: { x: 6, y: 3 }
        ,
            position: { x: 2, y: 4 }
        ,
            position: { x: 3, y: 4 }
        ,
            position: { x: 4, y: 4 }
        ,
            position: { x: 5, y: 4 }
        ,
            position: { x: 6, y: 4 }
        ]
    ,
        pileclass: "Stock"
        options:
            click:
                relations: []
            action: [
                on: "click"
                name: "move"
                rule:
                    first:
                        pile: [
                            comparison_tests: [
                                prop: "pileclass"
                            ,
                                prop: "faceup_length"
                                operator: "diff"
                                value: -1
                            ]
                            dir: "verso"
                        ,
                            single_tests: [
                                prop: "pileclass"
                                value: "Stock"
                            ,
                                prop: "facedown_length"
                                compare: ">"
                                value: 0
                            ]
                        ]
                        priority:
                            dir: "recto"
                            position: 0
                    second:
                        pile: [
                            single_tests: [
                                prop: "pileclass"
                                value: "Cell"
                            ,
                                prop: "faceup_length"
                                value: 0
                            ]
                        ]
                        priority:
                            dir: "recto"
                            position: 0
                    number: 1
            ]
            point_rule:
                both:
                    cards:
                        roles: [ { heap: "self", part: "facedown" } ]
                    operator: "diff"
                    value: 27
                    dir: "verso"
        piles: [
            position: { x: 0, y: 0 }
        ]
    ]
}
