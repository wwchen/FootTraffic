TEXS := $(filter-out titlepage.tex, $(wildcard *.tex))
PDFS := $(patsubst %.tex,%.pdf,$(TEXS))
LOGS := $(patsubst %.tex,%.log,$(TEXS))
AUXS := $(patsubst %.tex,%.aux,$(TEXS))


all: $(PDFS)
    
%.pdf: %.tex
	pdflatex $<

clean:
#	rm -f *.log *.aux *.toc *.bbl *.blg
	rm -f $(LOGS) $(AUXS)

clean-all:
	rm -f $(PDFS)

.PHONY: clean all
