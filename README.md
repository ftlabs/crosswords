# Crossword mini-site Experiment

To see if Jekyll is suitable...

... [live pages](//ftlabs.github.io/crossword-minisite/)

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
