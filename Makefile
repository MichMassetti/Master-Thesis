TMP_FILE_TYPES= *.acn *.acr *.alg *.aux *.bbl *.bcf *.blg *-blx.bib *.brf *.cb *.cb2\
                *.dbj *.dvi *.glo *.glg *.gls *.idx *.ilg *.ind *.lof *.log *.lol *.lot\
                *.nav *.nlg *.nlo *.nls *.not *.ntn *.out *.run.xml *.sd *.sgl *.snm\
                *?.svn *.svt *.svx *.swp *.tdo *.tex.bak *.thm *.toc *.vrb *.vtc
SRC_FILES= $(shell find . -name '*.tex')

.PHONY: all %.pdf thesis clean realclean spellcheck

all: thesis clean

%.pdf: %.tex
	@pdflatex $<

thesis: thesis.tex thesis.bib
	@pdflatex thesis
	@biber thesis
	@pdflatex thesis
	@pdflatex thesis
	@pdflatex thesis
	@echo 'LaTeX gave' `grep 'Warning:' thesis.log | wc -l` 'warnings'

clean:
	@rm -f $(TMP_FILE_TYPES)

realclean: clean
	@rm -f thesis.pdf

spellcheck:
	@$(foreach file, $(SRC_FILES), aspell check $(file) --mode=tex --lang=en;)
