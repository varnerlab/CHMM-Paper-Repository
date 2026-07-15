# Build recipe for the CHMM-paper draft.
#
# `make`         -> run pdflatex + bibtex + pdflatex x3 to produce paper.pdf
#                   (the fourth pdflatex pass clears the final cross-reference
#                   rerun warning so a clean build converges without manual passes)
# `make clean`   -> remove LaTeX auxiliary files
# `make distclean` -> also remove paper.pdf

PAPER := paper

.PHONY: all clean distclean

all: $(PAPER).pdf

$(PAPER).pdf: $(PAPER).tex references.bib $(wildcard sections/*.tex) $(wildcard figs/*.pdf)
	pdflatex -interaction=nonstopmode $(PAPER).tex
	bibtex $(PAPER)
	pdflatex -interaction=nonstopmode $(PAPER).tex
	pdflatex -interaction=nonstopmode $(PAPER).tex
	pdflatex -interaction=nonstopmode $(PAPER).tex

clean:
	rm -f $(PAPER).aux $(PAPER).bbl $(PAPER).blg $(PAPER).log \
	      $(PAPER).out $(PAPER).toc $(PAPER).fdb_latexmk $(PAPER).fls

distclean: clean
	rm -f $(PAPER).pdf
