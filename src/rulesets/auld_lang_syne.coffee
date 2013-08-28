ruleset = {
    title: "Auld Lang Syne"
    help: "https://help.gnome.org/users/aisleriot/stable/Auld_Lang_Syne.html"
    set: 52
    count: 1
    point_target: 52
    pilegroups: [
        pileclass: "Foundation"
        options:
            initial_faceup: 1
            fill:
                method: "other"
            build_rule:
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
                        value: -1
                    ]
        piles: [
            position: { x: 2, y: 0 }
        ,
            position: { x: 3, y: 0 }
        ,
            position: { x: 4, y: 0 }
        ,
            position: { x: 5, y: 0 }
        ]
    ,
        pileclass: "Reserve"
        options:
            initial_faceup: 0
        piles: [
            position: { x: 2, y: 1 }
        ,
            position: { x: 3, y: 1 }
        ,
            position: { x: 4, y: 1 }
        ,
            position: { x: 5, y: 1 }
        ]
    ,
        pileclass: "Stock"
        options:
            click: 
                relations: [
                    single_tests: [
                        prop: "pileclass"
                        value: "Reserve" 
                    ]
                ]
        piles: [
                position: { x: 0, y: 0 }
        ]
    ]
    deal_action:
        name: "swap"
        rule:
            first:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Foundation"
                        ]
                    ]
                    parts: [ "faceup" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            compare: "!="
                            value: 1
                        ]
                    ]
                priority:
                    dir: "random"
            second:
                card:
                    piles: [
                        single_tests: [
                            prop: "pileclass"
                            value: "Stock"
                        ]
                    ]
                    parts: [ "facedown" ]
                    cards: [
                        single_tests: [
                            prop: "value"
                            value: 1
                        ]
                    ]
                priority:
                    dir: "random"
}
