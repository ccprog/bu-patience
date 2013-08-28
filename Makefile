rulesrc = src/rulesets
ruledir = web/rulesets
cardsrc = src/cards
carddir = web/cards

schemas = $(ruledir)/ruleset_schema \
		$(ruledir)/action_schema \
		$(ruledir)/evaluate_schema \
		$(ruledir)/point_schema \
		$(ruledir)/lib_schema

coffees = LICENCE \
        src/patience_pile.coffee \
        src/patience_factory.coffee \
        src/patience_game.coffee \
        src/patience_area.coffee

web/patience.js : $(coffees)
	coffee -j web/patience.js -cb $(coffees)
	rm src/patience_factory.coffee

src/patience_factory.coffee $(schemas) : src/rulefactory.coffee
	src/splitter.js

rulecoffees := $(filter-out %/val.coffee,$(wildcard $(rulesrc)/*.coffee))
rulesets := $(patsubst $(rulesrc)/%.coffee,$(ruledir)/%.json,$(rulecoffees))

rules: $(rulesets)

$(rulesets) : $(ruledir)/%.json: $(rulesrc)/%.coffee | $(ruledir)
	$(rulesrc)/to_json.js $(notdir $<) "../../web/rulesets/"

$(ruledir) : 
	mkdir $(ruledir)

svgs := $(wildcard $(cardsrc)/*.svg)
pngs := $(patsubst $(cardsrc)/%.svg,$(carddir)/%.png,$(svgs))

$(pngs) : $(carddir)/%.png: $(cardsrc)/%.svg | $(carddir)
	rsvg-convert -o $@ -w 200 $<

cards: $(pngs)

$(carddir) : 
	mkdir $(carddir)

all: web/patience.js rules cards

clean:
	rm -fr $(ruledir)
	rm -fr $(carddir)
	rm -f web/patience.js
	
