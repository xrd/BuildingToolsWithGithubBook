
# Remix Guide

Thanks for checking out the book. This document is worth reading if you want to remix and/or build your
own copy of the book.

There are three major sections here:

* Quickstart: build everything in just a few minutes.
* Remix Details: learn a little bit about the structure of this repository
* Extensions: learn how to add your own CSS and JS, and an example of adding a "contribute!" button.

## Quickstart

First things first, you will need Ruby. If you are on Mac OSX, you probably want to use brew to install Ruby.
Alternatively for Windows or if you don't want to use brew, or you can use something like rvm or rbenv.
If you are on linux, `sudo apt-get install ruby2` or `sudo yum install ruby2` probably will work.

Once you have ruby installed, run this command to install the relevant packages.

```
$ gem install bundler
$ bundle install
```

This installs the "bundler" gem which helps install packages for you, and then the second command
installs the packages specified in the `Gemfile`.

Once you have that, you can build the project using this command:

```
$ mkdir -p ../some_directory
$ PUBLISH_ROOT=../some_directory bundle exec ruby publish.rb
```

The first time you run this, you will probably be told you don't have all the necessary repositories which contain
code samples, so follow along with the extra commands to run and fully setup the directory structure.

Note that you need to create a directory where the files are written. Once things are all setup, then you run the
command that slurps in the files and processes them into that directory.



## Remix/Hacking Details

This project was written in [Asciidoc](http://asciidoc.org/). From the project page:

> AsciiDoc is a text document format for writing notes, documentation, articles, books, ebooks, slideshows, web pages, man pages and blogs. AsciiDoc files can be translated to many formats including HTML, PDF, EPUB, man page.

You can see several files with `.asciidoc` extensions in this directory.

ALSO, and this is important, there are some files with the extension `.asciidoc.snippet`.

You can edit these files as if they were regular `.asciidoc` files, they just include special syntax which includes sections of
other files, sections defined as "snippets." The snippets syntax in these files is almost identical to the original concept called O'Reilly "snippets",
However, the "pure" O'Reilly snippets don't support including sections from files at a certain historical point in a GitHub repository,
so these snippet files actually use a superset of the snippets syntax that the [O'Reilly Snippets ruby gem](https://github.com/xrd/oreilly-snippets) can process for you. The ruby gem will be automatically retrieved and installed when you run the `bundle install` command
so no need to understand anything here other than you can edit the `.asciidoc.snippet` files as if they were `.asciidoc` files.
When you build the files using the command `PUBLISH_ROOT=../some_directory bundle exec ruby publish.rb` those files are first processed
with the ruby gem to retrieve the snippet content, and then processed through Asciidoc.

For example, normal snippets syntax would look like this:

```
[filename="coffeetech.js", language="js" identifier="IDENTIFIER"]
snippet~~~~
Put any descriptive text you want here. It will be replaced with the
specified code snippet when you build ebook outputs
snippet~~~~
```

When the processor finds the IDENTIFIER inside the `coffeetech.js` file, it will pull out the code in between the start and end
identifier. However, you can't do more complicated things, so the ruby gem allows more interesting snippets like the stuff below.

```
[source,ruby]
-----
[filename="../final-scraper", language="ruby", sha="1797422:scraper.rb" callouts="2,3,12,17,23,26,38,43", callouts_prefix=" # #"]
snippet~~~~~
To be replaced
snippet~~~~~
-----
```

This pulls the file `scraper.rb` at the repository history defined by the SHA hash `1797422`, adds callouts at
the lines specified in the callouts, and adds a prefix to those callouts so you could copy and paste the code
without modification into a script (without this, the pasted code would have invalid syntax...)

## Extensions

If you want to include the docinfo.html and docinfo-footer.html file, which reference files in the extras directory
add the `BTWG_EXTRAS=1` flag to your build command. This enables cryptocurrency micro-contributions, customizations and
easy mobile friendly editing.