OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

# Requirements
Before you install the app, you will need to download and install the following:

  * PostgreSQL 8.4 (Mac OS X: "port install postgresql84")
  * [PostGIS](http://postgis.refractions.net/) (which requires the [proj4](http://trac.osgeo.org/proj/) and [geos](http://trac.osgeo.org/geos/) libraries) (Mac OS X: install MacPorts and run "port install postgis")
  * Rails 3
  * Ruby 1.9.2 recommended (install via [RVM](http://rvm.beginrescueend.com/))
  * [GeoServer](http://geoserver.org/display/GEOS/Welcome), if you want to see vote maps
  * [Sphinx](http://www.sphinxsearch.com/), if you want to use search.

# Installation
  * Get a copy of the code:
        git clone http://github.com/opengovernment/opengovernment.git
        cd opengovernment
        git submodule init
        git submodule update
  * Set up your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
  * Create your database role and give it superuser privileges:
        psql# CREATE ROLE opengovernment WITH SUPERUSER LOGIN CREATEDB
  * Run the following:
        bundle install
        rake install
  * Rake install will set up the database, install the PostGIS SQL components, install fixtures, and download and install datasets. It typically takes at least an hour. You can always install the test database fixtures if you don't want to wait for the full install.
  * Once the install is complete, start the server:
        rails server

OpenGovernment uses subdomains, so to access the site you'll find the lvh.me domain helpful. This is a domain for which all subdomains point to localhost. So if you visit, for example, http://tx.lvh.me:3000, you should see the Texas OpenGovernment subsite.

# Sphinx installation
Mac OS X: If you use MacPorts:
    port install sphinx +postgresql84
should do the trick!

Otherwise, download and install sphinx using [instructions here](http://freelancing-god.github.com/ts/en/installing_sphinx.html). You can locate your pg_sql include directory using
    pg_config --pkgincludedir

# Thinking Sphinx installation
You should already have the thinkingsphinx gem installed via the bundle.
Run "rake -T | grep ts" to look at all the available commands.

# Tests
To prepare the test database, run the following:
    RAILS_ENV=test rake db:prepare

To run tests:
    bundle exec autotest
