# Crossword mini-site Experiment

To see if Jekyll is suitable...

... [live pages](//ftlabs.github.io/crossword-minisite/)

## Update the crosswords from ft.com

There is a script which scrapes ft.com/crossword for an uptodate list of live crosswords, and maps them into a form suitable to be displayed as part of this mini-site, converting the pdfs to images.

Since the Jeykll site is static, once deployed to github, the only way to update that list of crosswords is to pull the latest version of the repo, run the script, checkin the changes, and push back up to github.

In more detail:

* $ git pull origin master
* $ git checkout -b BRANCHNAME
* $ cd \_scripts
* $ ./joinFalconCrosswordsAndWinners.pl
* check that you have some new \_post/ entries
* $ cd -
* check it works ok locally
   * $ bundle exec jekyll serve
   * view localhost:4000 in your browser
* $ git add .
* $ git commit -m "latest crosswords from ft.com, 14/11/2017"
* $ git push origin BRANCHNAME
* merge this branch into master

## Considering

* how to keep in synch with changes in Origami?
* how to fold this into the Editorial workflow?
* how to stagger/delay the display of answers?
   * does it matter if the answers are available to the tech savvy?
      * A: yes, for the prize crosswords...
* how to make the crossword posts 100% front matter?
* some kind of commit hook to validate crossword posts before adding to the repo?
* ...

## setting up Jekyll locally (on a Mac, also works on Windows)

via https://jekyllrb.com/

* have or install ruby (this was developed using version ruby 2.0.0p648)
* `$ sudo gem install jekyll bundler`
* clone this repo
* cd to this repo
* `$ bundle exec jekyll serve`
* browse to http://localhost:4000
