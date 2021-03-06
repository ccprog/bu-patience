# BU Patience

A HTML5 browser game coded in Coffeescript, aimed at implementing a number of patience card games.

**Play here:** [Gamepad](http://browser-unplugged.net/games/patience/gamepad.php)

- [Web Storage API](http://www.whatwg.org/specs/web-apps/current-work/multipage/webstorage.html)
  is used to record the name of the last game played
- The application page is using the [D3.js](https://github.com/mbostock/d3/wiki) library.
  As the author states, 
  > D3 supports so-called “modern” browsers, which generally means everything except IE8 and below.
- Positioning and dragging of cards is realised with [CSS Transforms](http://www.w3.org/TR/css3-transforms)
- Gamepad layout uses [CSS flexbox](http://www.w3.org/TR/css3-flexbox), but also sets sizes programmatically
  as a fallback
- The controls use [Twitter Bootstrap 3.0](http://getbootstrap.com) and [Glyphicons](http://glyphicons.com/)

## Installation and Usage

Copy the contents of the `web/` folder to a webserver file system. PHP is needed.

The game is loaded from the url `gamepad.php`. It takes two `GET` parameters:

- **`ruleset`**: The name of the game to initially load, as displayed in the selection list.
  Defaults to the last game played.
- **`language`**: interface language (currently only `en` and `de`). Defaults to the browser
  default language.

## Rulesets

Individual games are described in JSON ruleset objects and interpreted by a Javascript game engine.

- Cards show up on the gamepad grouped in piles, positioned in a raster 
- Piles are assumed to consist of a group of facedown cards situated below a group of faceup cards.
  Each of these groups may be empty.
- Pile behavior is determined by membership in one of six pile classes
- Pile behavior can be further detailed or standard pileclass behavior overridden by setting options
- Pile options can be set for all piles of a pile class, or for individual piles

### Describing rules for a move

A move entails the player moving one or more cards from one pile to one or more other piles.
Such a move may succeed or not, and may be followed by other movement. The application goes through
several steps, checking several rules:

- The player may click or doubleclick on a pile, or drag one or more cards (in case the pile is
  spread out) away from the pile
- For each of these actions there is a rule governing whether this may result in the removal of
  cards from the pile. If the removal is considered invalid, the action stops.
- Optionally, the number of times an action can be performed for a pile may be limited
- In case of _clicks_ or _doubleclicks_, a number of target piles can be defined, to each of which
  a given number of cards should be moved.
- The player may _drag_ cards on top of another pile and try to drop them.
- In each of these cases, a _build_ rule is consulted for an individual target pile to determine
  if the movement shall succeed
- In case cards are successfull added to a pile, further action may follow.  
  If the source pile is empty after the move, it may be automatically refilled with
  a defined number of cards, originating from a priorized list of source piles.  
  Some other form of card movement may be defined to follow (movement of cards from the
  top of one pile to another, swaping the position of two cards, shuffling some cards randomly).
- On completion of a move, points are awarded based on a rule for each pile.

All these rules use a common base syntax, encompassing things like _testing_ a card or pile
for a property, _comparing_ two cards or piles in the light of one or more properties,
_selecting_ cards or piles by position in the game, by properties or by their role in a move,
_picking_ a single entry out of a card or pile list or _counting_ cards or properties.

### Pile classes

- __Cell:__ a pile that can at most hold one card.
- __Tableau:__ a pile whith the cards spread out (in any direction). Dragging
  a card also moves all cards sitting on top of it. (Whether this succeeds depends on the
  drag rule.) As a standard, on removal of the last faceup card, the topmost facedown card
  will automatically be flipped to faceup.
- __Stock:__ a pile holding only facedown cards. Unless defined otherwise, cards
  can only be removed by clicking.
- __Waste:__ a pile holding only faceup cards. Since its member cards are not spread
  out, dragging will only move the topmost card. (The same is true for the following pile classes.)
- __Reserve:__ can hold both facedown and faceup cards. As a standard, on removal
  of the last faceup card, the topmost facedown card will automatically be flipped to faceup.
- __Foundation:__ a pile that is the automatic target for a doubleclick. Since
  it is normally used for collecting ordered cards, it features a number of standard build rules
  that can be selected using a number of option keywords. (ascendening or descending order, will
  cards be added one by one or a complete ordered sequence, may sequences "wrap around" their end,
  i. e. may a king be considered adjecent to an ace)

## Overall features

- Cards and their positioning are scaled for optimal fit into the browser window
- Game moves are recorded internally, but apart from the browser history
- The Gamepad features informations about the remaining cards in the stockpile,
  the number of moves executed, the number of points achieved and the time elapsed 
  since the first move
- When the predefined target point number is reached, the game is considered solved
  and the timer stops (including visual feedback)

## Implemented games

The games featured here have been developed from the descriptions of Gnome Games 
[Aisle Riot](https://help.gnome.org/users/aisleriot/stable/index.html). My implementation
is independent of this software and only uses the manual descriptions. The copyright for
these games remains with the authors stated on the pages of the individual games. The Help
link on the gamepad leads to these pages.

## The card set

The court card faces are based on the standard english set as designed by
[Andrew Dougherty](https://plainbacks.com/imagegroups/HochAD1900.html)
and the [New York Card Company](https://plainbacks.com/imagegroups/HochNY1900.html)
between ca. 1870 and 1900, and which are variants of what can at least be
traced back to [John J. Levy in 1850](https://plainbacks.com/imagegroups/HochNY1860.html#I28).
As differences are truely minor, they must be placed in the public domain. Modern variants
are sold by _The United States Playing Card Company_ as the "Bee" series.

The joker design comes from a motive in an old folk lore book. I found it
[here](https://commons.wikimedia.org/wiki/File:DBP_1977_922_Till_Eulenspiegel.jpg). Note that
the stamp may be not public domain, but the motives it features are.

Pips and the backface are my own design. I claim no ownership and release their design
to the public domain.

Changes to the cardset need to be compiled to data urls with

    grunt cards

## Browser compatibility

- IE11 and Edge
- FF6+
- Chrome 8+
- Safari 6+
- Opera 12+

## Developing rulesets

Be sure to install the dev dependencies with

    npm install

`src/rulefactory.coffee` contains all partial schema definitions alongsige the functions
utilising them. You can follow the schema links down from the top level `ruleset` object to find
out the structure.

The `web/rulesets/` folder contains five [JSON Schema](http://json-schema.org/) files that
can be used to validate rulesets.

- `ruleset_schema` is the toplevel file which references all other files as subschemas.
- `evaluate_schema` holds descriptions for rules deciding whether an action is allowed
- `action_schema` holds descriptions for card moving action rules
- `point_schema` holds descriptions for point awarding rules
- `lib_schema` holds the common base library for rules

I still use the old [JaySchema](https://github.com/natesilva/jayschema) for validation, but also verify
that piles are not overlapping and the deck is completely exhausted for filling the initial piles.

You can call

    node tests/val.js [qualified coffee file name]

to test Coffescript source files. These files need to contain a global object `ruleset`.

It is also possible to test parts of rules. (usefull when the part in question lies behind
a _`oneOf`_ rule and you only get the result that none of the possible subschemas fit.)


    node tests/val.js [qualified coffee file name] [rule part pointer] [schema part pointer]

- `rule part pointer` must be a valid
  [JSON Pointer](http://tools.ietf.org/html/draft-ietf-appsawg-json-pointer-07) to the
  rule part to test
- `schema part pointer` starts with the keyword for the schema file, followed by a `/`
  and a valid JSON pointer into the file.

__Example__:

    nodejs tests/val.js src/rulesets/auld_lang_syne.coffee deal_action/rule action/definitions/swap

would test the `rule` property of the `deal_action` entry against the `definitions/swap` part
of file `action_schema`.

After validation you can convert them to JSON files with

    grunt rulesets

To compile `val.js` itself, run

    grunt coffee:validator

## Compilation

Be sure to install the dev dependencies with

    npm install

As `src/rulefactory.coffee` features both the rule functions and the schema elements for their
rule parameters, some special handling is needed.

    grunt splitter

will extract the schema objects and compile the five schema files, and additionally produce a file
`src/patience_factory.coffee` that only contains the function part.

The compile task for the application handles this file as temporary; all files `src/patience_*.coffee`
get compiled into a single javascript file `web/patience.js`.

    grunt compile

