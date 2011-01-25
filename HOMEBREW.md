Here are instructions for installing OpenGovernment's prerequisites on
OS X using Homebrew instead of MacPorts, assuming you already have git
and Homebrew installed.

The complicated command below is necessary to install PostgreSQL 8.4
instead of 9.0. (The long hex string is a git commit ID, determined by
reading the output of `brew log --oneline postgresql`.)

    brew update
    (cd /usr/local; git checkout -b postgresql-8.4 7dc7ccef9e1ab7d2fc351d7935c96a0e0b031552^ && brew install postgresql && git checkout master && git branch -d postgresql-8.4)

Somewhere in the last command's output there are instructions for
initializing and launching postgresql. Find and follow those
instructions... but if you need to initialize the database, specify
the default encoding, like this:

    initdb /usr/local/var/postgres -E utf8

Install mongodb:

    brew install mongodb

_[Follow the instructions at the end of the above installation.]_

    brew install postgis
    brew install sphinx
    gem install bundler

Proceed with "General Installation" from the README.
