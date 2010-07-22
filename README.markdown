OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

# Requirements
Before you install the app, you will need to download and install the following:

  * PostgreSQL 8.4 (Mac OS X: "port install postgresql84")
  * [PostGIS](http://postgis.refractions.net/) (which requires the [proj4](http://trac.osgeo.org/proj/) and [geos](http://trac.osgeo.org/geos/) libraries) (Mac OS X: install MacPorts and run "port install postgis")
  * Rails 3
  * [GeoServer](http://geoserver.org/display/GEOS/Welcome), if you want to see vote maps
  * [Sphinx](http://www.sphinxsearch.com/), if you want to use search (OS X: "port install sphinx +postgres84")

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
  * Rake install will set up the database, install the PostGIS SQL components, install fixtures, and download and install datasets.

To prepare the test database, run the following:
    RAILS_ENV=test rake db:prepare

To run tests:
    bundle exec script/spec_server &
    spec spec/
