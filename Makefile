# The toplevel DocBook file of our project
DOCUMENT = embedgui.xml

$(DOCUMENT): article.txt
	asciidoc -b docbook -o embedgui.xml article.txt

# Include the DocBook Kit's makefile rules
include docbook-kit/tools/Makefile.inc

# Create a 'make check' shortcut for all kinds of validity checking
check: check-document check-spelling

CLEANFILES += fop.cfg $(DOCUMENT)
