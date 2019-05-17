#for dependency you want all tex files  but for acronyms you do not want to include the acronyms file itself.
DOCTYPE = DMTN
DOCNUMBER = 119
DOCNAME = $(DOCTYPE)-$(DOCNUMBER)

tex = $(filter-out $(wildcard *acronyms.tex) , $(wildcard *.tex))

GITVERSION := $(shell git log -1 --date=short --pretty=%h)
GITDATE := $(shell git log -1 --date=short --pretty=%ad)
GITSTATUS := $(shell git status --porcelain)
ifneq "$(GITSTATUS)" ""
	GITDIRTY = -dirty
endif


tex=$(filter-out $(wildcard *aglossary.tex) , $(wildcard *.tex))  


SRC= $(DOCNAME).tex

OBJ=$(SRC:.tex=.pdf)

#Default when you type make
all: $(OBJ)

$(OBJ): $(tex) aglossary.tex meta.tex
	latexmk -bibtex -xelatex -f $(SRC)
	makeglossaries $(DOCNAME)      
	xelatex $(SRC)

#The generateAcronyms.py  script is in lsst-texmf/bin - put that in the path
acronyms.tex :$(tex) myacronyms.txt
	generateAcronyms.py   $(tex)

aglossary.tex :$(tex) myacronyms.txt
	generateAcronyms.py  -g $(tex)

.PHONY: clean
clean :
	latexmk -c
	rm *.pdf *.nav *.bbl *.xdv *.snm meta.tex


.FORCE:

meta.tex: Makefile .FORCE
	rm -f $@
	touch $@
	echo '% GENERATED FILE -- edit this in the Makefile' >>$@
	/bin/echo '\newcommand{\lsstDocType}{$(DOCTYPE)}' >>$@
	/bin/echo '\newcommand{\lsstDocNum}{$(DOCNUMBER)}' >>$@
	/bin/echo '\newcommand{\vcsRevision}{$(GITVERSION)$(GITDIRTY)}' >>$@
	/bin/echo '\newcommand{\vcsDate}{$(GITDATE)}' >>$@


