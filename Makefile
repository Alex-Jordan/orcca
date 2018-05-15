## ********************************************************************* ##
## Copyright 2016                                                        ##
## Portland Community College                                            ##
##                                                                       ##
## Authors                                                               ##
## Ann Cary, Alex Jordan, Carl Yao, Ralf Youtz                           ##
##                                                                       ##
## This file is part of Open Resources for Community College Algebra     ##
## (ORCCA).                                                              ##
##                                                                       ##
## Creative Commons BY 4.0 license                                       ##
## https://creativecommons.org/licenses/by/4.0/                          ##
## ********************************************************************* ##

#######################
# DO NOT EDIT THIS FILE
#######################

#   1) Make a copy of Makefile.paths.original
#      as Makefile.paths, which git will ignore.
#   2) Edit Makefile.paths to provide full paths to the root folders
#      of your local clones of the project repository and the mathbook
#      repository as described below.
#   3) The files Makefile and Makefile.paths.original
#      are managed by git revision control and any edits you make to
#      these will conflict. You should only be editing Makefile.paths.

##############
# Introduction
##############

# This is not a "true" makefile, since it does not
# operate on dependencies.  It is more of a shell
# script, sharing common configurations

######################
# System Prerequisites
######################

#   install         (system tool to make directories)
#   xsltproc        (xml/xsl text processor)
#   xmllint         (only to check source against DTD)
#   <helpers>       (PDF viewer, web browser, pager, Sage executable, etc)

#####
# Use
#####

#	A) Navigate to the location of this file
#	B) At command line:  make <some-target-from-the-options-below>

##################################################
# The included file contains customized versions
# of locations of the principal components of this
# project and names of various helper executables
##################################################
include Makefile.paths

###################################
# These paths are subdirectories of
# the project distribution
###################################
PRJSRC    = $(PRJ)/src
IMAGESSRC = $(PRJSRC)/images
OUTPUT    = $(PRJ)/output
STYLE     = $(PRJ)/style
XSL       = $(PRJ)/xsl

# The project's main hub file
MAINFILE  = $(PRJSRC)/orcca.ptx

# The project's styling files
CSS       = $(STYLE)/css/orcca.css
PRJXSL    = $(PRJ)/xsl
LATEX     = $(XSL)/orcca-latex.xsl

# These paths are subdirectories of
# the Mathbook XML distribution
# MBUSR is where extension files get copied
# so relative paths work properly
MBXSL = $(MB)/xsl
MBUSR = $(MB)/user
DTD   = $(MB)/schema/dtd

# These paths are subdirectories of the output
# folder for different output formats
PGOUT      = $(OUTPUT)/pg
HTMLOUT    = $(OUTPUT)/html
PDFOUT     = $(OUTPUT)/pdf
IMAGESOUT  = $(OUTPUT)/images
WWOUT      = $(OUTPUT)/webwork-extraction

# Some aspects of producing these examples require a WeBWorK server.
# For all but trivial testing or examples, please look into setting
# up your own WeBWorK server, or consult Alex Jordan about the use
# of PCC's server in a nontrivial capacity.    <alex.jordan@pcc.edu>
SERVER = https://webwork.pcc.edu
#SERVER = http://localhost

webwork-extraction:
	install -d $(WWOUT)
	-rm $(WWOUT) webwork-extraction.xml
	$(MB)/script/mbx -vv -c webwork -d $(WWOUT) -s $(SERVER) $(MAINFILE)

merge:
	cd $(OUTPUT); \
	xsltproc --xinclude --stringparam webwork.extraction $(WWOUT)/webwork-extraction.xml $(MBXSL)/pretext-merge.xsl $(MAINFILE) > merge.xml

pg:
	install -d $(PGOUT)
	cd $(PGOUT); \
	rm -r ORCCA; \
	xsltproc --xinclude --stringparam chunk.level 2 $(MBXSL)/pretext-ww-problem-sets.xsl $(OUTPUT)/merge.xml

pdf:
	install -d $(OUTPUT)
	install -d $(PDFOUT)
	install -d $(PDFOUT)/images
	install -d $(IMAGESOUT)
	install -d $(IMAGESSRC)
	-rm $(PDFOUT)/images/*
	-rm $(PDFOUT)/*.*
	cp -a $(IMAGESOUT) $(PDFOUT)
	cp -a $(WWOUT)/*.png $(PDFOUT)/images
	cp -a $(IMAGESSRC) $(PDFOUT)
	cd $(PDFOUT); \
	xsltproc -xinclude --stringparam exercise.text.statement yes --stringparam exercise.text.hint no --stringparam exercise.text.answer no --stringparam exercise.text.solution no --stringparam exercise.backmatter.statement no --stringparam exercise.backmatter.hint yes --stringparam exercise.backmatter.answer yes --stringparam exercise.backmatter.solution yes $(LATEX) $(OUTPUT)/merge.xml; \
	perl -pi -e 's/\\usepackage\{geometry\}//' orcca.tex; \
	perl -pi -e 's/\\documentclass\[10pt,\]\{book\}/\\documentclass\[paper=letter,DIV=14,BCOR=0.25in,chapterprefix,numbers=noenddot,fontsize=10pt,toc=indentunnumbered\]\{scrbook\}/' orcca.tex; \
	perl -pi -e 's/\\geometry\{letterpaper,total=\{340pt,9\.0in\}\}//' orcca.tex; \
	perl -pi -e 's/\%\% fontspec package will make Latin Modern \(lmodern\) the default font/\%\% Customized to load Palatino fonts\n\\usepackage[T1]{fontenc}\n\\renewcommand\{\\rmdefault\}\{zpltlf\} \%Roman font for use in math mode\n\\usepackage\[scaled=.85\]\{beramono\}\% used only by \\mathtt\n\\usepackage\[type1\]\{cabin\}\%used only by \\mathsf\n\\usepackage\{amsmath,amssymb,amsthm\}\%load before newpxmath\n\\usepackage\[varg,cmintegrals,bigdelims,varbb\]\{newpxmath\}\n\\usepackage\[scr=rsfso\]\{mathalfa\}\n\\usepackage\{bm\} \%load after all math to give access to bold math\n\% Now load the otf text fonts using fontspec--wont affect math\n\\usepackage\[no-math\]\{fontspec\}\n\\setmainfont\{TeXGyrePagellaX\}\n\\defaultfontfeatures\{Ligatures=TeX,Scale=1,Mapping=tex-text\}\n\% This is a palatino-like font\n\%\\setmainfont\[BoldFont = texgyrepagella-bold.otf, ItalicFont = texgyrepagella-italic.otf, BoldItalicFont = texgyrepagella-bolditalic.otf]\{texgyrepagella-regular.otf\}\n\\linespread\{1.02\}/' orcca.tex; \
	perl -pi -e 's/\\usepackage\{fontspec\}\n//' orcca.tex; \
	xelatex orcca.tex; \
	xelatex orcca.tex; \
	xelatex orcca.tex



#  HTML output
#  Output lands in the subdirectory:  $(HTMLOUT)
html:
	install -d $(OUTPUT)
	install -d $(HTMLOUT)
	install -d $(HTMLOUT)/images
	install -d $(IMAGESOUT)
	install -d $(IMAGESSRC)
	-rm $(HTMLOUT)/*.html
	-rm $(HTMLOUT)/knowl/*.html
	-rm $(HTMLOUT)/images/*
	-rm $(HTMLOUT)/*.css
	cp -a $(IMAGESOUT) $(HTMLOUT)
	cp -a $(IMAGESSRC) $(HTMLOUT)
	cp $(CSS) $(HTMLOUT)
	cd $(HTMLOUT); \
	xsltproc -xinclude --stringparam html.knowl.webwork.inline no --stringparam webwork.server $(SERVER) --stringparam html.knowl.exercise.inline no --stringparam html.knowl.example no --stringparam html.css.extra orcca.css $(PRJXSL)/orcca-html.xsl $(MAINFILE)

# make all the image files in svg format
images:
	install -d $(OUTPUT)
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.svg
	$(MB)/script/mbx -c latex-image -f svg -d $(IMAGESOUT) $(MAINFILE)
#	$(MB)/script/mbx -c asymptote -f svg -d $(IMAGESOUT) $(MAINFILE)

# run this to scrape thumbnail images from YouTube for any YouTube videos
youtube:
	install -d $(OUTPUT)
	install -d $(IMAGESOUT)
	-rm $(IMAGESOUT)/*.jpg
	$(MB)/script/mbx -c youtube -d $(IMAGESOUT) $(MAINFILE)


###########
# Utilities
###########

# Verify Source integrity
#   Leaves "dtderrors.txt" in OUTPUT
#   can then grep on, e.g.
#     "element XXX:"
#     "does not follow"
#     "Element XXXX content does not follow"
#     "No declaration for"
#   Automatically invokes the "less" pager, could configure as $(PAGER)
check:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/jingreport.txt
	-java -classpath ~/jing-trang/build -Dorg.apache.xerces.xni.parser.XMLParserConfiguration=org.apache.xerces.parsers.XIncludeParserConfiguration -jar ~/jing-trang/build/jing.jar $(MB)/schema/pretext.rng $(MAINFILE) > $(OUTPUT)/jingreport.txt
	less $(OUTPUT)/jingreport.txt

gource:
	install -d $(OUTPUT)
	-rm $(OUTPUT)/gource.mp4
	-gource --user-filter 'Stephen Simonds' --title ORCCA --key --background-image src/images/orca3.png --user-image-dir .git/avatar/ --hide filenames --seconds-per-day 0.2 --auto-skip-seconds 1 -1280x720 -o - | ffmpeg -y -r 60 -f image2pipe -vcodec ppm -i - -vcodec libx264 -preset veryslow -pix_fmt yuv420p -crf 23 -threads 0 -bf 0 $(OUTPUT)/gource.mp4
	-mv gource.mp4 $(OUTPUT)/gource.mp4
    
