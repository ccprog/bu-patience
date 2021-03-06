/*
patience.js
Copyright Claus Colloseus 2013

This program is free software: Redistribution and use, with or
without modification, are permitted provided that the following
conditions are met:
 * If you redistribute this code, either as source code or in
   minimized, compacted or obfuscated form, you must retain the
   above copyright notice, this list of conditions and the
   following disclaimer.
 * If you modify this code, distributions must not misrepresent
   the origin of those parts of the code that remain unchanged,
   and you must retain the above copyright notice and the following
   disclaimer.
 * If you modify this code, distributions must include a license
   which is compatible to the terms and conditions of this license.

This program is distributed in the hope that it will be useful,
but WITHOUT ANY WARRANTY; without even the implied warranty of
MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
*/



var Cell, Foundation, Pile, Reserve, Stock, Tableau, Waste,
  __hasProp = {}.hasOwnProperty,
  __extends = function(child, parent) { for (var key in parent) { if (__hasProp.call(parent, key)) child[key] = parent[key]; } function ctor() { this.constructor = child; } ctor.prototype = parent.prototype; child.prototype = new ctor(); child.__super__ = parent.prototype; return child; };

Pile = (function() {
  Pile.prototype.default_options = {
    initial_facedown: 0,
    initial_faceup: 0,
    click_rule: {
      name: "none"
    },
    drag_rule: {
      name: "none"
    },
    build_rule: {
      name: "none"
    },
    point_rule: {}
  };

  function Pile(game, options, deck) {
    var a, _i, _len, _ref, _ref1;
    this.game = game;
    this.countdown = options.countdown, this.click = options.click, this.autofill = options.autofill;
    this.facedown_cards = deck.splice(0, options.initial_facedown);
    this.faceup_cards = deck.splice(0, options.initial_faceup);
    this.click_rule = function() {
      return rulefactory.evaluate(options.click_rule, [], this, null, this.game.piles);
    };
    this.drag_rule = function(index) {
      var cards, index_up;
      index_up = Math.max(0, index - this.facedown_cards.length);
      cards = this.facedown_cards.slice(index).concat(this.faceup_cards.slice(index_up));
      return rulefactory.evaluate(options.drag_rule, cards, this, null, this.game.piles);
    };
    this.build_rule = function(cards, source) {
      return rulefactory.evaluate(options.build_rule, cards, this, source, this.game.piles);
    };
    if (options.pairing_rule != null) {
      this.pairing_rule = function(cards, source) {
        return rulefactory.evaluate(options.pairing_rule, cards, this, source, this.game.piles);
      };
    }
    this.marked_withdraw = 0;
    this.actions = {};
    _ref1 = (_ref = options.action) != null ? _ref : [];
    for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
      a = _ref1[_i];
      this.actions[a.on] = rulefactory.get_action(a, this.game.add_for_update);
    }
    this.point_rule = function(timing) {
      return rulefactory.points(options.point_rule, timing, this, this.game.piles);
    };
  }

  Pile.prototype.init_related = function(piles) {
    var r, _i, _len, _ref, _results;
    _ref = ["click", "autofill"];
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      r = _ref[_i];
      if (this[r] != null) {
        _results.push(this[r].related = rulefactory.related(this[r].relations, this, piles));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  Pile.prototype.total_length = function() {
    return this.facedown_cards.length + this.faceup_cards.length;
  };

  Pile.prototype.copy_all_cards = function() {
    return {
      down: this.facedown_cards.concat(),
      up: this.faceup_cards.concat()
    };
  };

  Pile.prototype.set_all_cards = function(cards) {
    this.facedown_cards = cards.down;
    return this.faceup_cards = cards.up;
  };

  Pile.prototype.marked_indexes = function() {
    return [Math.min(this.facedown_cards.length, this.total_length() - this.marked_withdraw), Math.max(0, this.faceup_cards.length - this.marked_withdraw)];
  };

  Pile.prototype.show_withdraw = function(number) {
    var begin, end;
    end = this.marked_indexes();
    this.marked_withdraw += Math.min(number, this.total_length() - this.marked_withdraw);
    begin = this.marked_indexes();
    return this.facedown_cards.slice(begin[0], end[0]).reverse().concat(this.faceup_cards.slice(begin[1], end[1]));
  };

  Pile.prototype.exec_withdraw = function() {
    var begin;
    begin = this.marked_indexes();
    this.facedown_cards.splice(begin[0], this.facedown_cards.length);
    this.faceup_cards.splice(begin[1], this.faceup_cards.length);
    this.marked_withdraw = 0;
    return this.on_withdraw();
  };

  Pile.prototype.cancel_withdraw = function(number) {
    return this.marked_withdraw -= number != null ? number : this.marked_withdraw;
  };

  Pile.prototype.exec_add = function(cards) {
    return this.faceup_cards = this.faceup_cards.concat(cards);
  };

  Pile.prototype.show_swap = function(part, index) {
    return this[part + "_cards"].slice(index, index + 1)[0];
  };

  Pile.prototype.exec_swap = function(part, index, card) {
    return this[part + "_cards"].splice(index, 1, card)[0];
  };

  Pile.prototype.on_withdraw = function() {
    var drawn, number, source, _i, _len, _ref, _results;
    if (this.total_length() === 0 && (this.autofill != null)) {
      number = this.autofill.number;
      _ref = this.autofill.related;
      _results = [];
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        source = _ref[_i];
        drawn = source.show_withdraw(number);
        if (drawn.length > 0) {
          number -= drawn.length;
          source.exec_withdraw();
          this.exec_add(drawn.reverse());
        }
        if (number === 0) {
          break;
        } else {
          _results.push(void 0);
        }
      }
      return _results;
    }
  };

  Pile.prototype.on_click = function() {
    var number, target, test, withdraw, _base, _i, _len, _ref, _ref1, _ref2, _ref3;
    if ((!(((_ref = this.countdown) != null ? _ref.which : void 0) === "click") || this.countdown.number > 0) && this.click_rule()) {
      test = 0;
      if (this.click != null) {
        _ref1 = this.click.related;
        for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
          target = _ref1[_i];
          number = (_ref2 = this.click.number) != null ? _ref2 : this.total_length();
          withdraw = this.show_withdraw(number);
          if (target.on_build(withdraw, this)) {
            test++;
            if (((_ref3 = this.countdown) != null ? _ref3.which : void 0) === "click") {
              this.countdown.number--;
            }
          } else {
            this.cancel_withdraw(number);
          }
        }
      }
      if (test || (this.actions.click != null)) {
        this.exec_withdraw();
        if (typeof (_base = this.actions).click === "function") {
          _base.click(this, null, this.game.piles);
        }
        return this.game.update();
      }
    }
  };

  Pile.prototype.on_dblclick = function() {
    var number, target, test, withdraw, _base, _i, _len, _ref, _ref1, _ref2;
    if ((!(((_ref = this.countdown) != null ? _ref.which : void 0) === "dblclick") || this.countdown.number > 0) && this.faceup_cards.length) {
      test = false;
      _ref1 = this.dblclick_targets;
      for (_i = 0, _len = _ref1.length; _i < _len; _i++) {
        target = _ref1[_i];
        number = target.fill === "once" ? 13 : 1;
        withdraw = this.show_withdraw(number);
        if (target.on_build(withdraw, this)) {
          if (((_ref2 = this.countdown) != null ? _ref2.which : void 0) === "dblclick") {
            this.countdown.number--;
          }
          test = true;
          break;
        } else {
          this.cancel_withdraw(number);
        }
      }
      if (test || (this.actions.dblclick != null)) {
        this.exec_withdraw();
        if (typeof (_base = this.actions).dblclick === "function") {
          _base.dblclick(this, null, this.game.piles);
        }
        return this.game.update();
      } else {
        return this.cancel_withdraw();
      }
    }
  };

  Pile.prototype.on_drop = function(target, index) {
    var withdraw, _base;
    withdraw = this.show_withdraw(this.total_length() - index);
    if (target.on_build(withdraw, this)) {
      this.exec_withdraw();
      if (typeof (_base = this.actions).drop === "function") {
        _base.drop(this, target, this.game.piles);
      }
      return this.game.update();
    } else {
      return this.cancel_withdraw();
    }
  };

  Pile.prototype.on_build = function(cards, source) {
    var test, _base, _ref, _ref1, _ref2;
    if ((this.pairing_rule != null) && this.faceup_cards.length >= 1) {
      this.show_withdraw(1);
      test = (!(((_ref = this.countdown) != null ? _ref.which : void 0) === "build") || this.countdown.number > 0) && cards.length === 1 && (typeof this.pairing_rule === "function" ? this.pairing_rule(cards, source) : void 0);
      if (test) {
        this.exec_withdraw();
      }
    } else {
      test = (!(((_ref1 = this.countdown) != null ? _ref1.which : void 0) === "build") || this.countdown.number > 0) && this.build_rule(cards, source);
      if (test) {
        this.exec_add(cards);
      }
    }
    if (test) {
      if (typeof (_base = this.actions).build === "function") {
        _base.build(this, source, this.game.piles);
      }
      if (((_ref2 = this.countdown) != null ? _ref2.which : void 0) === "build") {
        this.countdown.number--;
      }
    }
    return test;
  };

  return Pile;

})();

Cell = (function(_super) {
  __extends(Cell, _super);

  Cell.prototype.classname = "Cell";

  Cell.prototype.default_options = {
    drag_rule: {
      name: "all"
    },
    build_rule: {
      name: "card_sequence",
      rule: {
        select: {
          roles: [
            {
              heap: "self",
              part: "facedown"
            }, {
              heap: "self",
              part: "faceup"
            }, {
              heap: "cards"
            }
          ]
        },
        count: {
          compare: "<=",
          value: 1
        }
      }
    }
  };

  function Cell(game, options, deck) {
    Cell.__super__.constructor.call(this, game, options, deck);
  }

  return Cell;

})(Pile);

Tableau = (function(_super) {
  __extends(Tableau, _super);

  Tableau.prototype.classname = "Tableau";

  Tableau.prototype.default_options = {
    initial_faceup: 1,
    direction: "down",
    drag_rule: {
      name: "two_sequence",
      rule: {
        first_cards: {
          roles: [
            {
              heap: "cards"
            }
          ]
        },
        second_cards: {
          roles: [
            {
              heap: "self",
              part: "faceup"
            }
          ]
        },
        count: {
          compare: "<="
        }
      }
    }
  };

  function Tableau(game, options, deck) {
    this.direction = options.direction, this.spread = options.spread;
    Tableau.__super__.constructor.call(this, game, options, deck);
  }

  Tableau.prototype.on_withdraw = function() {
    if (!this.faceup_cards.length && this.facedown_cards.length) {
      this.faceup_cards.push(this.facedown_cards.pop());
    }
    return Tableau.__super__.on_withdraw.apply(this, arguments);
  };

  return Tableau;

})(Pile);

Stock = (function(_super) {
  __extends(Stock, _super);

  Stock.prototype.classname = "Stock";

  Stock.prototype.default_options = {
    click: {
      relations: [
        {
          single_tests: [
            {
              prop: "pileclass",
              value: "Waste"
            }
          ]
        }
      ],
      number: 1
    },
    click_rule: {
      name: "all"
    },
    build_rule: {
      name: "and",
      rule: [
        {
          name: "one_pile",
          rule: {
            select: {
              role: "other"
            },
            tests: [
              {
                prop: "pileclass",
                value: "Waste"
              }
            ]
          }
        }, {
          name: "card_sequence",
          rule: {
            select: {
              roles: [
                {
                  heap: "self",
                  part: "facedown"
                }
              ]
            },
            count: {
              value: 0
            }
          }
        }
      ]
    }
  };

  function Stock(game, options, deck) {
    if (options.initial_facedown === 0) {
      options.initial_facedown = deck.length;
    }
    Stock.__super__.constructor.call(this, game, options, deck);
  }

  Stock.prototype.exec_add = function(cards) {
    return this.facedown_cards = this.facedown_cards.concat(cards);
  };

  return Stock;

})(Pile);

Waste = (function(_super) {
  __extends(Waste, _super);

  Waste.prototype.classname = "Waste";

  Waste.prototype.default_options = {
    countdown: {
      which: "click",
      number: 0
    },
    click: {
      relations: [
        {
          single_tests: [
            {
              prop: "pileclass",
              value: "Stock"
            }
          ]
        }
      ]
    },
    click_rule: {
      name: "all"
    },
    drag_rule: {
      name: "all"
    },
    build_rule: {
      name: "one_pile",
      rule: {
        select: {
          role: "other"
        },
        tests: [
          {
            prop: "pileclass",
            value: "Stock"
          }
        ]
      }
    }
  };

  function Waste(game, options, deck) {
    Waste.__super__.constructor.call(this, game, options, deck);
  }

  Waste.prototype.on_click = function() {
    var target, withdraw, _ref;
    if (this.countdown.number > 0 && this.click_rule()) {
      target = this.click.related[0];
      withdraw = this.show_withdraw(this.total_length());
      if (target.on_build(withdraw.reverse(), this)) {
        this.exec_withdraw();
        if (((_ref = this.countdown) != null ? _ref.which : void 0) === "click") {
          this.countdown.number--;
        }
        return this.game.update();
      } else {
        return this.cancel_withdraw();
      }
    }
  };

  return Waste;

})(Pile);

Reserve = (function(_super) {
  __extends(Reserve, _super);

  Reserve.prototype.classname = "Reserve";

  Reserve.prototype.default_options = {
    initial_faceup: 1,
    drag_rule: {
      name: "all"
    },
    build_rule: {
      name: "one_pile",
      rule: {
        select: {
          role: "other"
        },
        tests: [
          {
            prop: "pileclass",
            value: "Stock"
          }
        ]
      }
    }
  };

  function Reserve(game, options, deck) {
    Reserve.__super__.constructor.call(this, game, options, deck);
  }

  Reserve.prototype.on_withdraw = function() {
    if (!this.faceup_cards.length && this.facedown_cards.length) {
      this.faceup_cards.push(this.facedown_cards.pop());
    }
    return Reserve.__super__.on_withdraw.apply(this, arguments);
  };

  return Reserve;

})(Pile);

Foundation = (function(_super) {
  var component, foundation_rule;

  __extends(Foundation, _super);

  Foundation.prototype.classname = "Foundation";

  component = {
    sequence: {
      name: "card_sequence",
      rule: {
        select: {
          roles: [
            {
              heap: "self",
              part: "faceup"
            }, {
              heap: "cards"
            }
          ]
        },
        pairwise_tests: [
          {
            prop: "suit"
          }, {
            prop: "value"
          }
        ]
      }
    },
    bottom: {
      name: "one_card",
      rule: {
        select: {
          role: {
            heap: "cards"
          },
          card: {
            position: {
              dir: "recto",
              position: 0
            }
          }
        },
        tests: [
          {
            prop: "value"
          }
        ]
      }
    },
    nonempty: {
      name: "card_sequence",
      rule: {
        select: {
          roles: [
            {
              heap: "self",
              part: "faceup"
            }
          ]
        },
        count: {
          compare: ">",
          value: 0
        }
      }
    },
    length: {
      name: "card_sequence",
      rule: {
        select: {
          roles: [
            {
              heap: "cards"
            }
          ]
        },
        count: {
          value: 13
        }
      }
    },
    empty: {
      name: "card_sequence",
      rule: {
        select: {
          roles: [
            {
              heap: "self",
              part: "faceup"
            }
          ]
        },
        count: {
          value: 0
        }
      }
    }
  };

  foundation_rule = function(fill) {
    var r, _ref;
    r = [];
    component.bottom.rule.tests[0].value = (_ref = fill.base) != null ? _ref : (fill.dir === "asc" ? 1 : 13);
    component.sequence.rule.pairwise_tests[1].operator = fill.base != null ? "wrapped_diff" : "diff";
    component.sequence.rule.pairwise_tests[1].value = fill.dir === "asc" ? -1 : 1;
    if (fill.method === "once") {
      r.push(component.empty);
      r.push(component.length);
      r.push(component.bottom);
    }
    r.push(component.sequence);
    if (fill.method === "incremental") {
      r.push({
        name: "or",
        rule: [component.nonempty, component.bottom]
      });
    }
    return {
      name: "and",
      rule: r
    };
  };

  Foundation.prototype.default_options = {
    fill: {
      method: "incremental",
      dir: "asc"
    },
    point_rule: {
      both: {
        cards: {
          roles: [
            {
              heap: "self",
              part: "faceup"
            }
          ]
        }
      }
    }
  };

  function Foundation(game, options, deck) {
    if (options.fill.method !== "other") {
      this.fill = options.fill.method;
      options.build_rule = foundation_rule(options.fill);
    }
    Foundation.__super__.constructor.call(this, game, options, deck);
  }

  Foundation.prototype.on_dblclick = function() {
    var _base, _ref;
    if ((this.actions.dblclick != null) && (!(((_ref = this.countdown) != null ? _ref.which : void 0) === "dblclick") || this.countdown.number > 0)) {
      if (typeof (_base = this.actions).dblclick === "function") {
        _base.dblclick(this, null, this.game.piles);
      }
      return this.game.update();
    }
  };

  return Foundation;

})(Pile);

var base, rulefactory,
  __hasProp = {}.hasOwnProperty;

base = {
  pile_classes: {
    "Cell": Cell,
    "Foundation": Foundation,
    "Tableau": Tableau,
    "Stock": Stock,
    "Waste": Waste,
    "Reserve": Reserve
  },
  suit_names: ["club", "diamond", "heart", "spade"],
  shuffle: function(array) {
    var i, m, t;
    m = array.length;
    while (m) {
      i = Math.floor(Math.random() * m--);
      t = array[m];
      array[m] = array[i];
      array[i] = t;
    }
    return array;
  }
};

rulefactory = (function() {
  var card_extract, card_pair_test, card_pair_test_list, card_prop, card_selection, card_selection_list, card_sequence_count, card_test, card_test_list, compare, do_swap, evaluator, mover, numeric_card_prop_names, numeric_card_props, numeric_pile_prop_names, numeric_pile_props, operator, pair_count, part_selection, part_selection_list, pile_card_count, pile_card_prop, pile_pair_test, pile_pair_test_list, pile_prop, pile_role_names, pile_selection, pile_selection_list, pile_sequence_count, pile_test, pile_test_list, point_count, point_model, position, priority_pile, priority_sequence, range, role_list, sequence_extract, sequence_position_extract, single_card, single_pile, single_role, string_card_props, string_pile_props;
  compare = {
    "==": function(val1, val2) {
      return val1 === val2;
    },
    "!=": function(val1, val2) {
      return val1 !== val2;
    },
    "<": function(val1, val2) {
      return val1 < val2;
    },
    "<=": function(val1, val2) {
      return val1 <= val2;
    },
    ">": function(val1, val2) {
      return val1 > val2;
    },
    ">=": function(val1, val2) {
      return val1 >= val2;
    }
  };
  operator = {
    "plus": function(val1, val2) {
      return val1 + val2;
    },
    "diff": function(val1, val2) {
      return val1 - val2;
    },
    "abs_diff": function(val1, val2) {
      return Math.abs(val1 - val2);
    },
    "wrapped_diff": function(val1, val2, neg) {
      return (val1 - val2 + 13) % 13 - (neg ? 13 : 0);
    },
    "wrapped_abs_diff": function(val1, val2) {
      var d;
      d = Math.abs(val1 - val2) % 13;
      return Math.min(d, 13 - d);
    },
    "multi": function(val1, val2) {
      return val1 * val2;
    },
    "division": function(val1, val2) {
      if (val2 < val1) {
        return (val2 + 13) / val1;
      } else {
        return val2 / val1;
      }
    },
    "max": function(val1, val2) {
      return Math.max(val1, val2);
    },
    "min": function(val1, val2) {
      return Math.min(val1, val2);
    }
  };
  numeric_card_props = {
    "value": function(card) {
      return card.value;
    }
  };
  numeric_card_prop_names = Object.keys(numeric_card_props);
  string_card_props = {
    "color": function(card) {
      return card.getColor();
    },
    "suit": function(card) {
      return card.suit;
    }
  };
  numeric_pile_props = {
    "index": function(pile, piles) {
      return piles.indexOf(pile);
    },
    "position_x": function(pile, piles) {
      return pile.position.x;
    },
    "position_y": function(pile, piles) {
      return pile.position.y;
    },
    "facedown_length": function(pile, piles) {
      return pile.facedown_cards.length;
    },
    "faceup_length": function(pile, piles) {
      return pile.faceup_cards.length;
    },
    "total_length": function(pile, piles) {
      return pile.total_length();
    }
  };
  numeric_pile_prop_names = Object.keys(numeric_pile_props);
  pile_role_names = ["self", "other"];
  string_pile_props = {
    "pileclass": function(pile, self, other) {
      return pile.classname;
    },
    "role": function(pile, self, other) {
      if (pile === self) {
        return pile_role_names[0];
      } else if (pile === other) {
        return pile_role_names[1];
      } else {
        return "none";
      }
    }
  };
  position = function(sel, array) {
    var pos;
    if (!array.length) {
      return null;
    }
    if (sel.dir === "random") {
      pos = Math.floor(Math.random() * array.length);
    } else if (sel.dir === "verso") {
      pos = array.length - 1 - sel.position;
    } else {
      pos = sel.position;
    }
    return array[pos];
  };
  range = function(sel, array) {
    var from, to, _ref, _ref1;
    from = (_ref = sel.from) != null ? _ref : 0;
    to = (_ref1 = sel.to) != null ? _ref1 : array.length;
    if (sel.dir === "verso") {
      return array.slice(array.length - to, array.length - from);
    } else {
      return array.slice(from, to);
    }
  };
  card_prop = function(prop, card) {
    if (numeric_card_prop_names.indexOf(prop) > -1) {
      return numeric_card_props[prop](card);
    } else {
      return string_card_props[prop](card);
    }
  };
  card_test = function(test, card) {
    var val, _ref;
    val = card_prop(test.prop, card);
    return compare[(_ref = test.compare) != null ? _ref : "=="](val, test.value);
  };
  card_test_list = function(tests, card) {
    var t, test, _i, _len;
    test = true;
    for (_i = 0, _len = tests.length; _i < _len; _i++) {
      t = tests[_i];
      test && (test = card_test(t, card));
      if (!test) {
        return false;
      }
    }
    return test;
  };
  card_pair_test = function(test, card1, card2) {
    var res, val1, val2, _ref, _ref1;
    val1 = card_prop(test.prop, card1);
    val2 = card_prop(test.prop, card2);
    if (test.operator != null) {
      res = operator[test.operator](val1, val2, test.value < 0);
      return compare[(_ref = test.compare) != null ? _ref : "=="](res, test.value);
    } else {
      return compare[(_ref1 = test.compare) != null ? _ref1 : "=="](val1, val2);
    }
  };
  card_pair_test_list = function(tests, card1, card2) {
    var t, test, _i, _len;
    test = true;
    for (_i = 0, _len = tests.length; _i < _len; _i++) {
      t = tests[_i];
      test && (test = card_pair_test(t, card1, card2));
      if (!test) {
        return false;
      }
    }
    return test;
  };
  single_card = function(sel, cards) {
    var card, _i, _len;
    if (sel.position != null) {
      return position(sel.position, cards);
    } else {
      for (_i = 0, _len = cards.length; _i < _len; _i++) {
        card = cards[_i];
        if (card_test_list(sel.single_tests, card)) {
          return card;
        }
      }
      return null;
    }
  };
  card_selection = function(sel, card_infos) {
    var e, e1, e2, entry, i, i1, i2, list, _i, _j, _k, _l, _len, _len1, _len2, _len3, _ref, _ref1, _ref2;
    list = [];
    if (sel.range != null) {
      return range(sel.range, card_infos);
    } else if (sel.single_tests != null) {
      for (_i = 0, _len = card_infos.length; _i < _len; _i++) {
        entry = card_infos[_i];
        if (card_test_list(sel.single_tests, entry.card)) {
          list.push(entry);
        }
      }
    } else if (sel.comparison_tests != null) {
      _ref = card_infos.slice(1);
      for (i2 = _j = 0, _len1 = _ref.length; _j < _len1; i2 = ++_j) {
        e2 = _ref[i2];
        _ref1 = card_infos.slice(0, +i2 + 1 || 9e9);
        for (i1 = _k = 0, _len2 = _ref1.length; _k < _len2; i1 = ++_k) {
          e1 = _ref1[i1];
          if (card_pair_test_list(sel.comparison_tests, e1.card, e2.card)) {
            entry = sel.dir === "verso" ? e2 : e1;
            list.push(entry);
          }
        }
      }
    } else if (sel.pairwise_tests != null) {
      _ref2 = card_infos.slice(1);
      for (i = _l = 0, _len3 = _ref2.length; _l < _len3; i = ++_l) {
        e = _ref2[i];
        if (card_pair_test_list(sel.pairwise_tests, card_infos[i].card, e.card)) {
          entry = sel.dir === "verso" ? e : card_infos[i];
          list.push(entry);
        }
      }
    }
    return list;
  };
  card_selection_list = function(selections, card_infos) {
    var list, sel, _i, _len;
    list = [];
    for (_i = 0, _len = selections.length; _i < _len; _i++) {
      sel = selections[_i];
      list = list.concat(card_selection(sel, card_infos));
    }
    return list;
  };
  card_sequence_count = function(test, cards) {
    var _ref;
    return compare[(_ref = test.compare) != null ? _ref : "=="](cards.length, test.value);
  };
  part_selection = function(name, pile, piles) {
    var card, i, list, _i, _len, _ref;
    if (piles != null) {
      list = [];
      _ref = pile[name + "_cards"];
      for (i = _i = 0, _len = _ref.length; _i < _len; i = ++_i) {
        card = _ref[i];
        list.push({
          card: card,
          pile: pile,
          part: name,
          index: i
        });
      }
      return list;
    } else {
      return pile[name + "_cards"];
    }
  };
  part_selection_list = function(selections, pile, piles) {
    var list, sel, _i, _len;
    list = [];
    for (_i = 0, _len = selections.length; _i < _len; _i++) {
      sel = selections[_i];
      list = list.concat(part_selection(sel, pile, piles));
    }
    return list;
  };
  pile_prop = function(prop, pile, self, other, piles) {
    if (numeric_pile_prop_names.indexOf(prop) > -1) {
      return numeric_pile_props[prop](pile, piles);
    } else {
      return string_pile_props[prop](pile, self, other);
    }
  };
  pile_card_prop = function(sel, pile, piles) {
    var card, cards;
    cards = part_selection_list(sel.parts, pile);
    card = single_card(sel.card, cards);
    if (card == null) {
      return null;
    }
    return card_prop(sel.prop, card);
  };
  pile_card_count = function(sel, pile, piles) {
    var cards;
    cards = part_selection_list(sel.parts, pile, piles);
    return card_selection_list(sel.card_list, cards).length;
  };
  pile_test = function(test, pile, self, other, piles) {
    var val, _ref;
    if (test.prop != null) {
      val = pile_prop(test.prop, pile, self, other, piles);
    } else if (test.card != null) {
      val = pile_card_prop(test.card, pile);
    } else if (test.count != null) {
      val = pile_card_count(test.count, pile, piles);
    }
    return compare[(_ref = test.compare) != null ? _ref : "=="](val, test.value);
  };
  pile_test_list = function(tests, pile, self, other, piles) {
    var t, test, _i, _len;
    test = true;
    for (_i = 0, _len = tests.length; _i < _len; _i++) {
      t = tests[_i];
      test && (test = pile_test(t, pile, self, other, piles));
      if (!test) {
        return false;
      }
    }
    return test;
  };
  pile_pair_test = function(test, pile1, pile2, self, other, piles) {
    var res, val1, val2, _ref, _ref1;
    if (test.prop != null) {
      val1 = pile_prop(test.prop, pile1, self, other, piles);
      val2 = pile_prop(test.prop, pile2, self, other, piles);
    } else if (test.card != null) {
      val1 = pile_card_prop(test.card, pile1, piles);
      val2 = pile_card_prop(test.card, pile2, piles);
    } else if (test.count != null) {
      val1 = pile_card_count(test.count, pile1, piles);
      val2 = pile_card_count(test.count, pile2, piles);
    }
    if (test.operator != null) {
      res = operator[test.operator](val1, val2, test.value < 0);
      return compare[(_ref = test.compare) != null ? _ref : "=="](res, test.value);
    } else {
      return compare[(_ref1 = test.compare) != null ? _ref1 : "=="](val1, val2);
    }
  };
  pile_pair_test_list = function(tests, pile1, pile2, self, other, piles) {
    var t, test, _i, _len;
    test = true;
    for (_i = 0, _len = tests.length; _i < _len; _i++) {
      t = tests[_i];
      test && (test = pile_pair_test(t, pile1, pile2, self, other, piles));
      if (!test) {
        return false;
      }
    }
    return test;
  };
  single_pile = function(sel, self, other, piles) {
    var comp, pile, _i, _j, _len, _len1;
    if (sel.role != null) {
      if (sel.role === "self") {
        return self;
      }
      if (sel.role === "other") {
        return other;
      }
    }
    if (sel.position != null) {
      return position(sel.position, piles);
    }
    if (sel.comparison_tests != null) {
      comp = single_pile(sel.comparator, self, other, piles);
      for (_i = 0, _len = piles.length; _i < _len; _i++) {
        pile = piles[_i];
        if (pile_pair_test_list(sel.comparison_tests, comp, pile, self, other, piles)) {
          return pile;
        }
      }
    } else {
      for (_j = 0, _len1 = piles.length; _j < _len1; _j++) {
        pile = piles[_j];
        if (pile_test_list(sel.single_tests, pile, self, other, piles)) {
          return pile;
        }
      }
      return null;
    }
  };
  pile_selection = function(sel, self, other, piles) {
    var comp, i, i1, i2, list, p, p1, p2, pile, _i, _j, _k, _l, _len, _len1, _len2, _len3, _len4, _m, _ref, _ref1, _ref2;
    list = [];
    if (sel.range != null) {
      return range(sel.range, piles);
    } else if (sel.single_tests != null) {
      for (_i = 0, _len = piles.length; _i < _len; _i++) {
        pile = piles[_i];
        if (pile_test_list(sel.single_tests, pile, self, other, piles)) {
          list.push(pile);
        }
      }
    } else if (sel.pairwise_tests != null) {
      _ref = piles.slice(1);
      for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
        p = _ref[i];
        if (pile_pair_test_list(sel.pairwise_tests, piles[i], p, self, other, piles)) {
          pile = sel.dir === "verso" ? p : piles[i];
          list.push(pile);
        }
      }
    } else if (sel.comparison_tests != null) {
      if (sel.comparator != null) {
        comp = single_pile(sel.comparator, self, other, piles);
        if (comp == null) {
          return list;
        }
        for (_k = 0, _len2 = piles.length; _k < _len2; _k++) {
          pile = piles[_k];
          if (pile_pair_test_list(sel.comparison_tests, comp, pile, self, other, piles)) {
            list.push(pile);
          }
        }
      } else {
        _ref1 = piles.slice(1);
        for (i2 = _l = 0, _len3 = _ref1.length; _l < _len3; i2 = ++_l) {
          p2 = _ref1[i2];
          _ref2 = piles.slice(0, +i2 + 1 || 9e9);
          for (i1 = _m = 0, _len4 = _ref2.length; _m < _len4; i1 = ++_m) {
            p1 = _ref2[i1];
            if (pile_pair_test_list(sel.comparison_tests, p1, p2, self, other, piles)) {
              pile = sel.dir === "verso" ? p2 : p1;
              list.push(pile);
            }
          }
        }
      }
    }
    return list;
  };
  pile_selection_list = function(selections, self, other, piles) {
    var list, sel, _i, _len;
    list = [];
    for (_i = 0, _len = selections.length; _i < _len; _i++) {
      sel = selections[_i];
      list = list.concat(pile_selection(sel, self, other, piles));
    }
    return list;
  };
  pile_sequence_count = function(test, pile_list) {
    var _ref;
    return compare[(_ref = test.compare) != null ? _ref : "=="](pile_list.length, test.value);
  };
  priority_pile = function(sel, self, other, piles) {
    var list;
    list = pile_selection_list(sel.pile, self, other, piles);
    return position(sel.priority, list);
  };
  single_role = function(sel, cards, self, other, piles) {
    var c, list, _i, _len;
    switch (sel.heap) {
      case "cards":
        if (piles != null) {
          list = [];
          for (_i = 0, _len = cards.length; _i < _len; _i++) {
            c = cards[_i];
            list.push({
              card: c
            });
          }
          return list;
        } else {
          return cards;
        }
        break;
      case "self":
        return part_selection(sel.part, self, piles);
      case "other":
        return part_selection(sel.part, other, piles);
    }
  };
  role_list = function(sels, cards, self, other, piles) {
    var list, sel, _i, _len;
    list = [];
    for (_i = 0, _len = sels.length; _i < _len; _i++) {
      sel = sels[_i];
      list = list.concat(single_role(sel, cards, self, other, piles));
    }
    return list;
  };
  card_extract = function(sel, cards, self, other, piles) {
    var card_list, pile;
    if (sel.role != null) {
      card_list = single_role(sel.role, cards, self, other);
    } else {
      pile = single_pile(sel.pile, self, other, piles);
      if (pile == null) {
        return null;
      }
      card_list = part_selection_list(sel.parts, pile);
    }
    return single_card(sel.card, card_list);
  };
  sequence_position_extract = function(rule, cards, self, other, piles) {
    var list, pile, _i, _len, _ref;
    if (rule.roles != null) {
      list = role_list(rule.roles, cards, self, other, piles);
    } else {
      list = [];
      _ref = pile_selection_list(rule.piles, self, other, piles);
      for (_i = 0, _len = _ref.length; _i < _len; _i++) {
        pile = _ref[_i];
        list = list.concat(part_selection_list(rule.parts, pile, piles));
      }
    }
    if (rule.cards != null) {
      list = card_selection_list(rule.cards, list);
    }
    return list;
  };
  sequence_extract = function(rule, cards, self, other, piles) {
    var e, list, _i, _len, _ref;
    list = [];
    _ref = sequence_position_extract(rule, cards, self, other, piles);
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      e = _ref[_i];
      list.push(e.card);
    }
    return list;
  };
  priority_sequence = function(sel, self, other, piles) {
    var list;
    list = sequence_position_extract(sel.card, null, self, other, piles);
    return position(sel.priority, list);
  };
  pair_count = function(test, list1, list2) {
    var res, _ref, _ref1;
    if (test.operator != null) {
      res = operator[test.operator](list1.length, list2.length, test.value < 0);
      return compare[(_ref = test.compare) != null ? _ref : "=="](res, test.value);
    } else {
      return compare[(_ref1 = test.compare) != null ? _ref1 : "=="](list1.length, list2.length);
    }
  };
  evaluator = {
    and: function(rule, cards, self, other, piles) {
      var r, test, _i, _len;
      test = true;
      for (_i = 0, _len = rule.length; _i < _len; _i++) {
        r = rule[_i];
        test && (test = evaluator[r.name](r.rule, cards, self, other, piles));
        if (!test) {
          break;
        }
      }
      return test;
    },
    or: function(rule, cards, self, other, piles) {
      var r, test, _i, _len;
      test = false;
      for (_i = 0, _len = rule.length; _i < _len; _i++) {
        r = rule[_i];
        test || (test = evaluator[r.name](r.rule, cards, self, other, piles));
        if (test) {
          break;
        }
      }
      return test;
    },
    one_card: function(rule, cards, self, other, piles) {
      var card;
      card = card_extract(rule.select, cards, self, other, piles);
      if (card == null) {
        return false;
      }
      return card_test_list(rule.tests, card);
    },
    two_card: function(rule, cards, self, other, piles) {
      var first, second;
      first = card_extract(rule.first, cards, self, other, piles);
      if (first == null) {
        return false;
      }
      second = card_extract(rule.second, cards, self, other, piles);
      if (second == null) {
        return false;
      }
      return card_pair_test_list(rule.tests, first, second);
    },
    card_sequence: function(rule, cards, self, other, piles) {
      var c, card, card_list, i, test, _i, _j, _len, _len1, _ref;
      card_list = sequence_extract(rule.select, cards, self, other, piles);
      test = true;
      if (rule.all_tests != null) {
        for (_i = 0, _len = card_list.length; _i < _len; _i++) {
          card = card_list[_i];
          test && (test = card_test_list(rule.all_tests, card));
          if (!test) {
            break;
          }
        }
      } else if (rule.pairwise_tests != null) {
        _ref = card_list.slice(1);
        for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
          c = _ref[i];
          test && (test = card_pair_test_list(rule.pairwise_tests, card_list[i], c));
          if (!test) {
            break;
          }
        }
      } else {
        test = card_sequence_count(rule.count, card_list);
      }
      return test;
    },
    one_pile: function(rule, cards, self, other, piles) {
      var pile;
      pile = single_pile(rule.select, self, other, piles);
      if (pile == null) {
        return false;
      }
      return pile_test_list(rule.tests, pile, self, other, piles);
    },
    two_pile: function(rule, cards, self, other, piles) {
      var first, second;
      first = single_pile(rule.first, self, other, piles);
      if (first == null) {
        return false;
      }
      second = single_pile(rule.second, self, other, piles);
      if (second == null) {
        return false;
      }
      return pile_pair_test_list(rule.tests, first, second, self, other, piles);
    },
    pile_sequence: function(rule, cards, self, other, piles) {
      var i, p, pile, pile_list, test, _i, _j, _len, _len1, _ref;
      pile_list = pile_selection_list(rule.select, self, other, piles);
      test = true;
      if (rule.all_tests != null) {
        for (_i = 0, _len = pile_list.length; _i < _len; _i++) {
          pile = pile_list[_i];
          test && (test = pile_test_list(rule.all_tests, pile));
          if (!test) {
            break;
          }
        }
      } else if (rule.pairwise_tests != null) {
        _ref = pile_list.slice(1);
        for (i = _j = 0, _len1 = _ref.length; _j < _len1; i = ++_j) {
          p = _ref[i];
          test && (test = pile_pair_test_list(rule.pairwise_tests, pile_list[i], p));
          if (!test) {
            break;
          }
        }
      } else {
        test = pile_sequence_count(rule.count, pile_list);
      }
      return test;
    },
    two_sequence: function(rule, cards, self, other, piles) {
      var first_list, second_list;
      if (rule.first_cards != null) {
        first_list = sequence_extract(rule.first_cards, cards, self, other, piles);
      }
      if (rule.second_cards != null) {
        second_list = sequence_extract(rule.second_cards, cards, self, other, piles);
      }
      if (rule.first_piles != null) {
        first_list = pile_selection_list(rule.first_piles, self, other, piles);
      }
      if (rule.second_piles != null) {
        second_list = pile_selection_list(rule.second_piles, self, other, piles);
      }
      return pair_count(rule.count, first_list, second_list);
    },
    all: function() {
      return true;
    },
    none: function() {
      return false;
    }
  };
  do_swap = function(pair) {
    var swapping;
    swapping = pair[0].pile.show_swap(pair[0].part, pair[0].index);
    swapping = pair[1].pile.exec_swap(pair[1].part, pair[1].index, swapping);
    return pair[0].pile.exec_swap(pair[0].part, pair[0].index, swapping);
  };
  mover = {
    iterate: function(rule, self, other, piles) {
      var r, _i, _len, _results;
      _results = [];
      for (_i = 0, _len = rule.length; _i < _len; _i++) {
        r = rule[_i];
        _results.push(mover[r.name](r.rule, self, other, piles));
      }
      return _results;
    },
    move: function(rule, self, other, piles) {
      var ord, pair, prio, removed, _i, _len, _ref, _ref1;
      while (true) {
        pair = [];
        _ref = ["first", "second"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ord = _ref[_i];
          prio = priority_pile(rule[ord], self, other, piles);
          if (!prio) {
            return;
          }
          pair.push(prio);
        }
        removed = pair[0].show_withdraw((_ref1 = rule.number) != null ? _ref1 : 1);
        pair[0].exec_withdraw();
        pair[1].exec_add(removed);
      }
    },
    swap: function(rule, self, other, piles) {
      var ord, pair, prio, _i, _len, _ref;
      while (true) {
        pair = [];
        _ref = ["first", "second"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          ord = _ref[_i];
          prio = priority_sequence(rule[ord], self, other, piles);
          if (!prio) {
            return;
          }
          pair.push(prio);
        }
        do_swap(pair);
      }
    },
    shuffle: function(rule, self, other, piles) {
      var c, i, list, sorted, _i, _len, _results;
      list = sequence_position_extract(rule.select, null, self, other, piles);
      sorted = list.slice(0);
      base.shuffle(list);
      _results = [];
      for (i = _i = 0, _len = sorted.length; _i < _len; i = ++_i) {
        c = sorted[i];
        _results.push(do_swap([list[i], c]));
      }
      return _results;
    }
  };
  point_model = function(rule, self, other, piles) {
    var entry, points, _i, _len;
    if (Array.isArray(rule)) {
      points = 0;
      for (_i = 0, _len = rule.length; _i < _len; _i++) {
        entry = rule[_i];
        points += point_count(entry, self, other, piles);
      }
      return points;
    } else {
      return point_count(rule, self, other, piles);
    }
  };
  point_count = function(rule, self, other, piles) {
    var card, count, pile, selected, _i, _j, _len, _len1;
    if (rule.fixed != null) {
      return rule.fixed;
    } else if (rule.piles != null) {
      selected = pile_selection_list(rule.piles, self, other, piles);
      if ((rule.evaluate != null) && rule.evaluate !== "length") {
        count = 0;
        for (_i = 0, _len = selected.length; _i < _len; _i++) {
          pile = selected[_i];
          count += pile_prop(rule.evaluate, pile);
        }
      } else {
        count = selected.length;
      }
    } else if (rule.cards != null) {
      selected = sequence_extract(rule.cards, null, self, other, piles);
      if ((rule.evaluate != null) && rule.evaluate !== "length") {
        count = 0;
        for (_j = 0, _len1 = selected.length; _j < _len1; _j++) {
          card = selected[_j];
          count += card_prop(rule.evaluate, card);
        }
      } else {
        count = selected.length;
      }
    }
    if (rule.operator != null) {
      if (rule.dir === "verso") {
        return operator[rule.operator](rule.value, count);
      } else {
        return operator[rule.operator](count, rule.value);
      }
    } else {
      return count;
    }
  };
  return {
    evaluate: function(rule, cards, self, other, piles) {
      return evaluator[rule.name](rule.rule, cards, self, other, piles);
    },
    get_action: function(rule) {
      return function(self, other, piles) {
        return mover[rule.name](rule.rule, self, other, piles);
      };
    },
    points: function(rule, timing, pile, piles) {
      var _ref;
      if ((rule[timing] == null) && (rule.both == null)) {
        return 0;
      }
      return point_model((_ref = rule[timing]) != null ? _ref : rule.both, pile, null, piles);
    },
    related: function(rule, pile, piles) {
      return pile_selection_list(rule, pile, null, piles);
    },
    merge: function(obj1, obj2) {
      var prop, result, _ref;
      result = {};
      for (prop in obj2) {
        if (!__hasProp.call(obj2, prop)) continue;
        if (typeof obj2[prop] === "object" && !((obj2[prop] instanceof Array) || prop === "rule")) {
          result[prop] = this.merge((_ref = obj1[prop]) != null ? _ref : {}, obj2[prop]);
        } else {
          result[prop] = obj2[prop];
        }
      }
      for (prop in obj1) {
        if (!__hasProp.call(obj1, prop)) continue;
        if (obj2[prop] == null) {
          if (typeof obj1[prop] === "object" && !((obj1[prop] instanceof Array) || prop === "rule")) {
            result[prop] = this.merge(obj1[prop], {});
          } else {
            result[prop] = obj1[prop];
          }
        }
      }
      return result;
    }
  };
})();

var Card, Game, Step, Timer,
  __bind = function(fn, me){ return function(){ return fn.apply(me, arguments); }; };

Game = (function() {
  var advise, move;

  advise = function(self, pile) {
    var funct, name, _results;
    _results = [];
    for (name in pile) {
      funct = pile[name];
      if (name.search(/^exec_/) === 0) {
        _results.push((function(name, funct) {
          var point;
          point = funct;
          return pile[name] = function() {
            var doublet, old_step;
            old_step = new Step(pile, "old");
            doublet = self.pending.filter(function(entry) {
              return entry.pile === pile;
            });
            if (!doublet.length) {
              self.pending.push(old_step);
            }
            return point.apply(pile, arguments);
          };
        })(name, funct));
      } else {
        _results.push(void 0);
      }
    }
    return _results;
  };

  function Game(area, ruleset) {
    var action, c, deck, options, pg, pile, po, s, size, smallest, v, _i, _j, _k, _l, _len, _len1, _len2, _len3, _m, _n, _ref, _ref1, _ref2, _ref3, _ref4, _ref5, _ref6;
    this.area = area;
    deck = [];
    this.piles = [];
    smallest = 14 - Math.floor(ruleset.set / 4);
    for (c = _i = 0, _ref = ruleset.count; 0 <= _ref ? _i < _ref : _i > _ref; c = 0 <= _ref ? ++_i : --_i) {
      _ref1 = base.suit_names;
      for (_j = 0, _len = _ref1.length; _j < _len; _j++) {
        s = _ref1[_j];
        for (v = _k = smallest; smallest <= 13 ? _k <= 13 : _k >= 13; v = smallest <= 13 ? ++_k : --_k) {
          deck.push(new Card(s, v));
        }
      }
      if (ruleset.set % 4 === 2) {
        deck.push(new Card('joker', 1));
        deck.push(new Card('joker', 2));
      }
    }
    base.shuffle(deck);
    size = {
      x: 0,
      y: 0
    };
    this.pending = [];
    this.history = [];
    this.history_pointer = 0;
    this.point_target = ruleset.point_target;
    this.points = 0;
    _ref2 = ruleset.pilegroups;
    for (_l = 0, _len1 = _ref2.length; _l < _len1; _l++) {
      pg = _ref2[_l];
      _ref3 = pg.piles;
      for (_m = 0, _len2 = _ref3.length; _m < _len2; _m++) {
        po = _ref3[_m];
        options = rulefactory.merge(Pile.prototype.default_options, base.pile_classes[pg.pileclass].prototype.default_options);
        options = rulefactory.merge(options, (_ref4 = pg.options) != null ? _ref4 : {});
        options = rulefactory.merge(options, (_ref5 = po.options) != null ? _ref5 : {});
        if (pg.pileclass === "Tableau") {
          if (options.direction == null) {
            options.direction = "down";
          }
          if (options.spread == null) {
            options.spread = options.direction === "down" ? 3 : 2;
          }
        }
        size.x = Math.max(size.x, po.position.x + (options.direction === "right" ? options.spread : 1));
        size.y = Math.max(size.y, po.position.y + (options.direction === "down" ? options.spread : 1));
        pile = new base.pile_classes[pg.pileclass](this, options, deck);
        pile.position = po.position;
        this.piles.push(pile);
      }
    }
    if (ruleset.deal_action != null) {
      action = rulefactory.get_action(ruleset.deal_action, function() {});
      action(null, null, this.piles);
    }
    this.area.initialize(this, size);
    _ref6 = this.piles;
    for (_n = 0, _len3 = _ref6.length; _n < _len3; _n++) {
      pile = _ref6[_n];
      advise(this, pile);
      pile.init_related(this.piles);
      if (!(pile.classname === "Foundation")) {
        pile.dblclick_targets = this.piles.filter(function(p) {
          return p.classname === "Foundation";
        });
      }
      this.area.add_pile(pile);
      this.points += pile.point_rule("new");
    }
    this.set_all_infos();
    this.timer = new Timer(this.area);
  }

  Game.prototype.update = function() {
    var entry, steps, _i, _len;
    steps = this.pending.map(function(entry) {
      return {
        old: entry,
        "new": entry.to_new()
      };
    });
    this.pending = [];
    for (_i = 0, _len = steps.length; _i < _len; _i++) {
      entry = steps[_i];
      this.area.alter_pile(entry["new"].pile);
      this.points += entry["new"].point_delta;
    }
    this.history.splice(this.history_pointer);
    this.history_pointer++;
    this.history.push(steps);
    this.set_all_infos();
    if (!this.timer.running) {
      return this.timer.start();
    } else if (this.points === this.point_target) {
      this.timer.stop();
      return this.area.highlight_win();
    }
  };

  move = function(timing) {
    var entry, step, step_list, _i, _len, _results;
    step_list = this.history[this.history_pointer - (timing === "old" ? 1 : 0)];
    _results = [];
    for (_i = 0, _len = step_list.length; _i < _len; _i++) {
      entry = step_list[_i];
      step = entry[timing];
      step.pile.set_all_cards(step.cards);
      if (step.countdown != null) {
        step.pile.countdown.number = step.countdown;
      }
      this.area.alter_pile(step.pile);
      _results.push(this.points += step.point_delta);
    }
    return _results;
  };

  Game.prototype.undo = function() {
    if (this.history_pointer === 0) {
      return -1;
    }
    move.call(this, "old");
    this.history_pointer--;
    return this.set_all_infos();
  };

  Game.prototype.redo = function() {
    if (this.history_pointer === this.history.length) {
      return -1;
    }
    move.call(this, "new");
    this.history_pointer++;
    return this.set_all_infos();
  };

  Game.prototype.alter_points = function(delta) {
    return this.points += delta;
  };

  Game.prototype.set_all_infos = function() {
    var stock_count;
    stock_count = 0;
    this.piles.forEach(function(p) {
      if (p instanceof Stock) {
        return stock_count += p.facedown_cards.length;
      }
    });
    this.area.set_info("remaining", stock_count);
    this.area.set_info("moves", this.history_pointer);
    return this.area.set_info("points", this.points);
  };

  Game.prototype.destroy = function() {
    if (this.timer != null) {
      this.timer.reset();
      return this.timer = void 0;
    }
  };

  return Game;

})();

Card = (function() {
  function Card(suit, value) {
    this.suit = suit;
    this.value = value;
  }

  Card.prototype.getColor = function() {
    switch (this.suit) {
      case 'club':
      case 'spade':
        return "black";
      default:
        return "red";
    }
  };

  return Card;

})();

Step = (function() {
  function Step(pile, timing) {
    var _ref;
    this.cards = pile.copy_all_cards();
    this.pile = pile;
    this.countdown = (_ref = pile.countdown) != null ? _ref.number : void 0;
    this.point_delta = pile.point_rule(timing);
  }

  Step.prototype.to_new = function() {
    var after;
    after = new Step(this.pile, "new");
    this.point_delta -= after.point_delta;
    after.point_delta = -this.point_delta;
    return after;
  };

  return Step;

})();

Timer = (function() {
  function Timer(a) {
    this.poll = __bind(this.poll, this);
    this.format = d3.time.format.utc("%X");
    this.area = a;
    this.reset();
  }

  Timer.prototype.poll = function() {
    var dif;
    dif = new Date(Date.now() - this.start_time);
    return this.area.set_info("time", this.format(dif));
  };

  Timer.prototype.start = function() {
    this.running = true;
    this.start_time = Date.now();
    return this.loop = setInterval(this.poll, 500);
  };

  Timer.prototype.stop = function() {
    return clearInterval(this.loop);
  };

  Timer.prototype.reset = function() {
    this.running = false;
    clearInterval(this.loop);
    return this.area.set_info("time", '00:00:00');
  };

  return Timer;

})();

var Area;

Area = (function() {
  var cards, dim, is_over, load_cards, on_xhr, raster, remove_flashing, resize_timeout, set_flashing, to_view, waiting;

  dim = {
    svg: {
      w: 101,
      h: 156
    },
    png: {
      w: 200,
      h: 309
    }
  };

  raster = {
    x: 110,
    y: 165,
    space: 10,
    fan_x: 20,
    fan_y: 26
  };

  cards = {};

  waiting = false;

  load_cards = function(cards_version) {
    var _this = this;
    return d3.json('cards.json', function(e, obj) {
      if (e) {
        throw new Error("no cards received\n" + e.message);
      } else {
        cards = obj;
        try {
          localStorage.setItem('cards', JSON.stringify(cards));
          localStorage.setItem('cards_version', cards_version);
        } catch (_error) {
          e = _error;
        }
        if (waiting) {
          _this.new_game(waiting);
          return waiting = false;
        }
      }
    });
  };

  to_view = function(pile) {
    var dl;
    dl = pile.facedown_cards.length;
    return pile.facedown_cards.map(function(card, i) {
      return {
        key: "" + (pile.position.x * 100 + pile.position.y) + "_b_" + i,
        ref: cards["back"],
        back: true,
        x: 0,
        y: 0
      };
    }).concat(pile.faceup_cards.map(function(card, i) {
      return {
        key: "" + (pile.position.x * 100 + pile.position.y) + "_" + card.value + "_" + card.suit + "_" + (i + dl),
        ref: cards["" + card.value + "_" + card.suit],
        back: false,
        x: 0,
        y: 0
      };
    }));
  };

  is_over = function(stacks, rx, ry) {
    return stacks.filter(function(s, i) {
      var _ref, _ref1, _ref2, _ref3;
      switch (s.pile.direction) {
        case "down":
          return Math.abs(s.x - rx) < raster.x / 2 && (-0.5 < (_ref = (ry - s.y) / raster.y) && _ref < s.pile.spread - 0.5);
        case "up":
          return Math.abs(s.x - rx) < raster.x / 2 && (0.5 - s.pile.spread < (_ref1 = (ry - s.y) / raster.y) && _ref1 < 0.5);
        case "left":
          return (0.5 - s.pile.spread < (_ref2 = (rx - s.x) / raster.x) && _ref2 < 0.5) && Math.abs(s.y - ry) < raster.y / 2;
        case "right":
          return (-0.5 < (_ref3 = (rx - s.x) / raster.x) && _ref3 < s.pile.spread - 0.5) && Math.abs(s.y - ry) < raster.y / 2;
        default:
          return Math.abs(s.x - rx) < raster.x / 2 && Math.abs(s.y - ry) < raster.y / 2;
      }
    })[0];
  };

  set_flashing = function(d) {
    d.flashing = true;
    d3.event.preventDefault();
    return d3.select(this).style("z-index", "5");
  };

  remove_flashing = function(d) {
    if (d.flashing) {
      d3.select(this).style("z-index", null);
    }
    return d.flashing = false;
  };

  on_xhr = {
    ruleset: function(ruleset) {
      var _this = this;
      d3.select("title").text("Patience: " + ruleset.title);
      d3.select("#newgame").on("click", function() {
        return _this.new_game(ruleset);
      });
      this.infos.filter("#help").on("click", function() {
        if ((this.help_window == null) || this.help_window.closed) {
          return this.help_window = window.open(ruleset.help);
        } else {
          return this.help_window.location = ruleset.help;
        }
      });
      if (Object.keys(cards).length < 54) {
        return waiting = ruleset;
      } else {
        return this.new_game(ruleset);
      }
    },
    language: function(strings) {
      var el, entry, info, key, _results;
      _results = [];
      for (key in strings) {
        entry = strings[key];
        el = d3.select("#" + key);
        switch (entry.target) {
          case "title":
            _results.push(el.attr("title", entry.text));
            break;
          case "text":
            info = el.select(".data").node();
            _results.push(el.text(entry.text).append(function() {
              return info;
            }));
            break;
          default:
            _results.push(void 0);
        }
      }
      return _results;
    }
  };

  resize_timeout = null;

  function Area(pad, infos, presets) {
    var cards_ser, cards_version, e, item, sheet, _fn, _i, _len, _ref,
      _this = this;
    this.pad = pad;
    this.infos = infos;
    sheet = d3.select("head").append("style").property("sheet");
    sheet.insertRule("img {}", 0);
    this.rule = sheet.cssRules[0];
    try {
      cards_version = localStorage.getItem('cards_version');
      cards_ser = localStorage.getItem('cards');
      if (presets.cards_version !== cards_version || !cards_ser) {
        load_cards.call(this, presets.cards_version);
      } else {
        cards = JSON.parse(cards_ser);
      }
    } catch (_error) {
      e = _error;
    }
    this.selector = {};
    _ref = ["language", "ruleset"];
    _fn = function(item) {
      var lang, url, _ref1, _ref2, _ref3;
      try {
        url = (_ref1 = presets[item]) != null ? _ref1 : localStorage.getItem(item);
      } catch (_error) {
        e = _error;
      }
      _this.selector[item] = d3.select("select#" + item);
      if (url == null) {
        if (item === "language") {
          lang = (_ref2 = (_ref3 = navigator.language) != null ? _ref3 : navigator.userLanguage) != null ? _ref2 : "en";
          if (_this.selector[item].select('option[value="lang/#{lang}.json"]').empty()) {
            lang = "en";
          }
          url = "lang/" + lang.substring(0, 2) + ".json";
        } else {
          url = presets.standard;
        }
      }
      _this.selector[item].property("value", url).on("change", function() {
        url = _this.selector[item].property("value");
        return _this.change(item, url);
      });
      return _this.change(item, url);
    };
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      item = _ref[_i];
      _fn(item);
    }
  }

  Area.prototype.change = function(item, url) {
    var e,
      _this = this;
    try {
      localStorage.setItem(item, url);
    } catch (_error) {
      e = _error;
    }
    return d3.json(url, function(e, obj) {
      var lang;
      if (e) {
        throw new Error(("no " + item + " received\n") + e.message);
      } else {
        if (item === "language") {
          lang = url.match(/\/(.*)\.json$/)[1];
          d3.select("html").attr("lang", lang);
        }
        return on_xhr[item].call(_this, obj);
      }
    });
  };

  Area.prototype.new_game = function(ruleset) {
    var _ref;
    if ((_ref = this.game) != null) {
      _ref.destroy();
    }
    return this.game = new Game(this, ruleset);
  };

  Area.prototype.initialize = function(game, size) {
    var _this = this;
    d3.select("button#prev").on("click", function() {
      return game.undo();
    });
    d3.select("button#next").on("click", function() {
      return game.redo();
    });
    this.pad.selectAll("div").remove();
    this.stacks = [];
    this.hover = false;
    this.width = raster.x * size.x + raster.space;
    this.height = raster.y * size.y;
    this.scale = 1;
    d3.select(window).on("resize", function() {
      if (resize_timeout) {
        clearTimeout(resize_timeout);
      }
      return resize_timeout = setTimeout(function() {
        _this.resize();
        return resize_timeout = null;
      }, 100);
    });
    return this.resize();
  };

  Area.prototype.get_stack = function(pile) {
    return this.stacks.filter(function(s) {
      return s.pile === pile;
    })[0];
  };

  Area.prototype.resize = function() {
    var height, stack, _i, _len, _ref, _results;
    if (d3.select("#page").style("display") === "block") {
      height = d3.select("#page").property("clientHeight") - this.pad.property("offsetTop");
      this.pad.style("height", height + "px");
    }
    this.scale = Math.min(this.pad.property("clientWidth") / this.width, this.pad.property("clientHeight") / this.height);
    this.rule.style.width = Math.round(101 * this.scale) + "px";
    this.rule.style.height = Math.round(156 * this.scale) + "px";
    _ref = this.stacks;
    _results = [];
    for (_i = 0, _len = _ref.length; _i < _len; _i++) {
      stack = _ref[_i];
      stack.outer.style("top", Math.round(this.scale * stack.y) + "px").style("left", Math.round(this.scale * stack.x) + "px");
      _results.push(this.alter_pile(stack.pile));
    }
    return _results;
  };

  Area.prototype.add_pile = function(pile) {
    var stack;
    stack = {
      pile: pile,
      x: raster.x * pile.position.x + raster.space,
      y: raster.y * pile.position.y,
      trans_x: 0,
      trans_y: 0
    };
    stack.outer = this.pad.append("div").classed("stack", true).style("top", Math.round(this.scale * stack.y) + "px").style("left", Math.round(this.scale * stack.x) + "px");
    stack.outer.append("img").attr("src", cards["empty"]).on("dragstart", function() {
      return d3.event.preventDefault();
    });
    stack.inner = stack.outer.append("div").classed("stack", true);
    if ((pile.dblclick_targets != null) || (pile.actions.dblclick != null)) {
      stack.inner.on("dblclick", function() {
        return pile.on_dblclick();
      });
    }
    if ((pile.click != null) || (pile.actions.click != null)) {
      stack.outer.on("click", function() {
        return pile.on_click();
      });
    }
    this.stacks.push(stack);
    return this.alter_pile(pile);
  };

  Area.prototype.alter_pile = function(pile) {
    var can_drag, card_names, dragging, flashing, gd, hg, stack, total,
      _this = this;
    can_drag = hg = void 0;
    dragging = d3.behavior.drag().origin(function() {
      return {
        x: 0,
        y: 0
      };
    }).on("dragstart", function(d, i) {
      if (d3.event.sourceEvent.button === 0 && pile.drag_rule(i)) {
        can_drag = true;
        return hg = stack.inner.selectAll("img").filter(function(d, j) {
          return j >= i;
        });
      }
    }).on("drag", function(d, i) {
      var pre, _i, _len, _ref, _results;
      if (can_drag) {
        if (!_this.hover) {
          stack.outer.style("z-index", "5");
          _this.hover = true;
        }
        d.x = d3.event.x;
        d.y = d3.event.y;
        _ref = ["-moz-", "-webkit-", ""];
        _results = [];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          pre = _ref[_i];
          hg.style(pre + "transform", null);
          _results.push(hg.style(pre + "transform", "translate(" + d.x + "px," + d.y + "px)"));
        }
        return _results;
      }
    }).on("dragend", function(d, i) {
      var over, pre, rx, ry, _i, _len, _ref;
      if (can_drag) {
        rx = stack.x + (d.x / _this.scale) + i * stack.trans_x;
        ry = stack.y + (d.y / _this.scale) + i * stack.trans_y;
        over = is_over(_this.stacks, rx, ry);
        d.x = 0;
        d.y = 0;
        _ref = ["-moz-", "-webkit-", ""];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          pre = _ref[_i];
          hg.style(pre + "transform", null);
        }
        can_drag = _this.hover = false;
        stack.outer.style("z-index", null);
        if (over && over.pile !== pile) {
          return pile.on_drop(over.pile, i);
        }
      }
    });
    stack = this.get_stack(pile);
    total = pile.total_length();
    switch (pile.direction) {
      case "down":
        stack.trans_y = Math.min(raster.fan_y, raster.y * (pile.spread - 1) / (total - 1));
        break;
      case "up":
        stack.trans_y = -Math.min(raster.fan_y, raster.y * (pile.spread - 1) / (total - 1));
        break;
      case "right":
        stack.trans_x = Math.min(raster.fan_x, raster.x * (pile.spread - 1) / (total - 1));
        break;
      case "left":
        stack.trans_x = -Math.min(raster.fan_x, raster.x * (pile.spread - 1) / (total - 1));
    }
    card_names = to_view(pile);
    gd = stack.inner.selectAll("img").data(card_names, function(d) {
      return d.key;
    });
    gd.enter().append("img");
    gd.attr("src", function(d) {
      return d.ref;
    }).style("left", function(d, i) {
      return (stack.trans_x * i * _this.scale).toFixed(2) + "px";
    }).style("top", function(d, i) {
      return (stack.trans_y * i * _this.scale).toFixed(2) + "px";
    }).call(dragging);
    gd.exit().remove();
    flashing = null;
    gd.each(function(d, i) {
      var card;
      card = d3.select(this);
      if (d.back) {
        return card.on("contextmenu", null).on("mouseup", null).on("mouseout", null);
      } else {
        return card.on("contextmenu", set_flashing).on("mouseup", remove_flashing).on("mouseout", remove_flashing);
      }
    });
    return true;
  };

  Area.prototype.set_info = function(id, value) {
    this.infos.classed("win", false);
    return this.infos.filter("#" + id).select(".data").text(value);
  };

  Area.prototype.highlight_win = function() {
    return this.infos.filter("#time, #points").classed("win", true);
  };

  return Area;

})();
