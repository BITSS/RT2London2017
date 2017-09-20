# Stata Built-in Dynamic Documents

Stata started including dynamic documents capabilities with version 15 (June 2017). However, the capabilities are significantly limited when compared with either R Markdown & knitr or user-built tools that work with earlier versions of Stata such as [Markdoc](http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php).

The built-in tools can output HTML from Markdown ([dyndoc](https://www.stata.com/new-in-stata/markdown/)), and can output PDFs ([putpdf](https://www.stata.com/new-in-stata/create-pdfs/)) or Word documents ([putdocx](https://www.stata.com/new-in-stata/create-word-documents/)). But the syntax is different for all three! Tomas Dvorak wrote a blog post summarizing the shortcomings [here](https://muse.union.edu/dvorakt/review-of-statas-dyndoc/).

* [Video comparison](https://www.youtube.com/watch?v=tWrde-8TwPI).
* [Stata's example files](http://www.stata-press.com/data/r15/markdown/)


Thankfully, there are other free tools available.
* Stata and Markdown -->anything: [Markdoc](http://www.haghish.com/statistics/stata-blog/reproducible-research/markdoc.php). See the website, or check out the [Stata Forum](https://www.statalist.org/forums/search?q=markdoc&searchJSON=%7B%22keywords%22%3A%22markdoc%22%7D)--the developer E.F. Haghish is pretty good about answering questions there.

* For Stata (or R, SAS) and Word (for Windows only) you can try [StatTag](http://sites.northwestern.edu/stattag/).

* For LaTeX and Stata: [texdoc](http://repec.sowi.unibe.ch/stata/texdoc/) by Ben Jann.

* For Stata-->HTML/Markdoc: [webdoc](http://repec.sowi.unibe.ch/stata/webdoc/) by Ben Jann.

* I just discovered that someone has built a Stata and Jupyter Notebooks combination: [iPyStata](https://www.stata.com/meeting/chicago16/slides/chicago16_dekok.pdf).

* See the pros and cons of most of these in a [presentation](https://www.stata.com/meeting/oceania16/slides/rising-oceania16.pdf) by Bill Rising of StataCorp.
