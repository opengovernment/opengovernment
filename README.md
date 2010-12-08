OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

# Prerequisites
Before you install the app, you will need to download and install the following:

  * [Git](http://git-scm.com/)
  * Ruby Enterprise Edition 1.8.7 recommended (install via [RVM](http://rvm.beginrescueend.com/))
  * [Bundler](http://gembundler.com/) for rubygem installation
  * PostgreSQL 8.4
  * [PostGIS](http://postgis.refractions.net/) (which requires the [proj4](http://trac.osgeo.org/proj/) and [geos](http://trac.osgeo.org/geos/) libraries)
  * [ImageMagick](http://www.imagemagick.org/) image processing library
  * [Sphinx](http://www.sphinxsearch.com/) is required. [Here are the install instructions](http://freelancing-god.github.com/ts/en/installing_sphinx.html). You can locate your `pg_sql` include directory using `pg_config --pkgincludedir`
  * [GeoServer](http://geoserver.org/display/GEOS/Welcome), if you want to see vote maps
  * [MongoDB](http://mongodb.org/) for page view count support

# Easy Install

We could really use some Chef recipes or something that would ease the install process. Can you help with this?
Meanwhile...

# Full install

## Prerequisites:

### on Ubuntu 10.10:

Pop open a terminal and run the following commands to get started.

#### Libraries & Build Tools

These are used by gems like nokogiri or by our install scripts:

    sudo apt-get install bison openssl libreadline5 libreadline5-dev curl zlib1g zlib1g-dev libssl-dev libxml2-dev libxslt-dev libxml2-dev

#### Git

    sudo apt-get install git-core

#### PostgreSQL 8.4 and PostGIS

    sudo apt-get install libpq-dev libkdb5-4 postgresql-8.4 postgresql-doc-8.4
    sudo apt-get install postgis postgresql-8.4-postgis

#### Sphinx

    sudo apt-get install sphinxsearch

#### ImageMagick

    sudo apt-get install imagemagick

#### Ruby & Bundler

    sudo apt-get install ruby-full rubygems

For the ffi gem, you'll need:

    sudo apt-get install libffi-ruby

Then install bundler:

    sudo gem install bundler

The bundle executable may not be in your path. If not, run:

    sudo ln -s /var/lib/gems/1.8/bin/bundle /usr/local/bin/bundle
    
#### MongoDB (optional, for page view tracking)

For Ubuntu 10.10, add this line to `/etc/apt/sources.list`:

    deb http://downloads.mongodb.org/distros/ubuntu 10.4 10gen

Then run:

    sudo apt-key adv --keyserver keyserver.ubuntu.com --recv 7F0CEB10
    sudo apt-get update
    sudo apt-get install mongodb-stable

That should do it, but [other Ubuntus are covered on MongoDB's site](http://www.mongodb.org/display/DOCS/Ubuntu+and+Debian+packages).

#### GeoServer (optional, for vote maps)

These are the prerequisites for GeoServer:

    sudo apt-get install java-common default-jre-headless tomcat6

This is the tricky part:

    sudo -u tomcat6 -s
    cd /var/lib/tomcat6/webapps
    wget 'http://downloads.sourceforge.net/geoserver/geoserver-2.0.2-war.zip'
    unzip geoserver-2.0.2-war.zip && rm geoserver-2.0.2-war.zip
    exit

Now, change the `JAVA_OPS` line in /etc/default/tomcat6 to:

    JAVA_OPS="-jvm server -Djava.awt.headless=true -Xmx256M"

And restart tomcat:

    sudo service tomcat restart

GeoServer should now be available at `[http://localhost:8080/geoserver/web/](http://localhost:8080/geoserver/web/)`
Below, there are full instructions on setting up GeoServer to work with OpenGovernment.

### On Mac:

#### Basics / Build Tools

Start by installing [Xcode](http://developer.apple.com/technologies/tools/xcode.html)
Then [download MacPorts](http://www.macports.org/).

Then run:
    # Install MacPorts items
    sudo port selfupdate
    sudo port install postgresql84 postgis mongodb git-core
    sudo port install sphinx +postgresql84
    sudo gem install bundler 

## General Installation

Once you've satisfied the prerequisites, this should work on all platforms.

  * Get a copy of the code:
        git clone http://github.com/opengovernment/opengovernment.git
        cd opengovernment
        git submodule init
        git submodule update
        bundle install
  * Set up your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
  * Create your database role and give it superuser privileges:
        psql# CREATE ROLE opengovernment WITH SUPERUSER LOGIN CREATEDB

### Importing the full dataset (takes 2+ hours)

To import the full dataset, run `rake install`.

  * Rake install will set up the database, install the PostGIS SQL components, install fixtures, and download and install datasets.
  * You can provide a comma-separated list of state abbreviations in a LOAD_STATES env variable to rake install. Otherwise, the default "loadable" states will be loaded, as specified in the tasks/fixtures/states.yml file.

### OR import test data right away

Alternatively, you can quickly get up and running with `rake install_dev`. This will import YAML fixtures and give you enough of a database to browse the site.

## Start your engines

Once the install is complete, build the Sphinx index and start the Sphinx server:

    rake ts:rebuild

Then start Rails:

    bin/rails s

OpenGovernment uses subdomains, so to access the site you'll find the `127localhost.com` domain helpful. This is a domain for which all subdomains point to localhost. So if you visit, for example, `http://tx.127localhost.com:3000`, you should see the Texas OpenGovernment site.

## GeoServer Setup (optional, for vote maps)

Once you have GeoServer running, there are further setup steps.

You'll want to [sign in to your local GeoServer](http://localhost:8080/geoserver/web/):
    GeoServer: http://localhost:8080/geoserver/web/
    Default username: admin
    Default p/w: geoserver

Add a new Store for OpenGovernment. Here are the details:
    Data Source: PostGIS
    Workspace: cite
    Date Source Name: og
    Database User & PW should match your database.yml

You'll want to add two new Layers to the `og` Store as well. You'll only need to set the name and title on these--all other settings can remain default. The layers should be called `v_district_people` and `v_district_votes`.

# Tests
To prepare the test database: `RAILS_ENV=test rake db:test:prepare`.
Then, to run all tests: `rake`.

You can use autotest or spork. To fire up the spork-based drb server, run `script/spec_server`

# Troubleshooting

Many bill versions and documents in state legislatures have FTP URLs associated with them. Ruby 1.8.7's Net::FTP does not negotiate passive FTP and will hang if you are using iptables without the `ip_conntrack_ftp` module.

In `/etc/sysconfig/iptables-config`, add it to `IPTABLES_MODULES`:
    IPTABLES_MODULES="ip_conntrack_netbios_ns ip_conntrack_ftp"

