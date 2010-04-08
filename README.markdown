OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

You will need:
postgres >= 8.4
PostGIS (depends on proj4 and geos libraries)
Gem Bundler (sudo gem install bundler)

Steps for installing on Mac OS X:
* Run port install postgresql84-server geos
* Create your database user and give them superuser privileges
* Set up your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
* Install proj4 from source (http://trac.osgeo.org/proj/)
* Install postgis 1.5 from source (http://postgis.refractions.net/)
* Run sudo gem install bundler
* Then, from the opengovernment dir, run "bundle install"
* Run "rake install" to set up the database, install PostGIS, install fixtures, and download and install datasets.
