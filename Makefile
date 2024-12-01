#nimvar = -d:release -d:danger -d:lto -d:strip 
nimvar = --opt:none 
funcopt = #--mm:none #functions have no memory management, they're run for short times, so it's a waste to bother with it.


install:build
	cp built/executable /usr/bin/fdm
	mkdir /usr/share/FDM_functions -p
	cp -rv built/functions/* /usr/share/FDM_functions

build:dirs build_functions
	nim compile $(nimvar) --out=built/executable main.nim

build_functions:build_main_functions build_output_functions

dirs:
	mkdir -p built/functions
	mkdir -p built/functions/html
	mkdir -p built/functions/markdown
	mkdir -p built/functions/md

build_output_functions:build_html build_markdown


build_html:
	echo -e "const format = \"html\"" > functions/format.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/i					functions/i.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/h1					functions/h1.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/h2					functions/h2.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/h3					functions/h3.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/center				functions/center.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/header				functions/header.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/footer				functions/footer.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/set_space			functions/set_space.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/p					functions/paragraph.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/newline				functions/newline.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/quote				functions/quote.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/q					functions/q.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/b					functions/bold.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/link				functions/link.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/image				functions/image.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/list				functions/list.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/table				functions/table.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/code				functions/code.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/single_space		functions/single_space.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/html/div					functions/div.nim

build_markdown:
	echo -e "const format = \"markdown\"" > functions/format.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/i				functions/i.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/h1				functions/h1.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/h2				functions/h2.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/h3				functions/h3.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/center			functions/center.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/header			functions/header.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/footer			functions/footer.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/set_space		functions/set_space.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/p				functions/paragraph.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/newline			functions/newline.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/quote			functions/quote.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/q				functions/q.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/b				functions/bold.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/link			functions/link.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/list			functions/list.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/table			functions/table.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/code			functions/code.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/single_space	functions/single_space.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/markdown/div				functions/div.nim
	cp built/functions/markdown/* built/functions/md

	
build_main_functions:
	nim compile $(nimvar) $(funcopt) --out=built/functions/import				functions/import.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/import_raw			functions/import_raw.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/var					functions/var.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/std					functions/std.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/mla_document		functions/mla_document.nim
	nim compile $(nimvar) $(funcopt) --out=built/functions/!					functions/bang.nim

