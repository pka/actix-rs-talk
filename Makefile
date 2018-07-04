all: html/index.html

html/index.html: actix-rs.md reveal.js/css/reveal.css
	pandoc -t revealjs --self-contained -s $< -o $@

reveal_version=3.6.0

$(reveal_version).tar.gz:
	wget https://github.com/hakimel/reveal.js/archive/$(reveal_version).tar.gz

reveal.js/css/reveal.css: $(reveal_version).tar.gz
	tar xvzf $(reveal_version).tar.gz
	mv reveal.js-$(reveal_version) reveal.js
	touch $*
