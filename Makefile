# https://pandoc.org/MANUAL.html#producing-slide-shows-with-pandoc

SLIDE_OPTIONS=-t revealjs --css=./custom.css -s

all: actix-rs.html

actix-rs.html: actix-rs.md reveal.js/css/reveal.css
	pandoc $(SLIDE_OPTIONS) $< -o $@

watch: actix-rs.md reveal.js/css/reveal.css actix-rs.html
	fswatch -o --event Updated $< | xargs -n1 -I{} sh -c "echo Rebuilding...; pandoc $(SLIDE_OPTIONS) $< -o actix-rs.html"

full: actix-rs.md reveal.js/css/reveal.css
	pandoc  $(SLIDE_OPTIONS) --self-contained $< -o actix-rs.html

reveal_version=3.6.0

reveal.js/css/reveal.css:
	wget -O /tmp/$(reveal_version).tar.gz https://github.com/hakimel/reveal.js/archive/$(reveal_version).tar.gz
	tar xvzf /tmp/$(reveal_version).tar.gz
	rm /tmp/$(reveal_version).tar.gz
	mv reveal.js-$(reveal_version) reveal.js
	touch $@
