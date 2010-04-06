OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

You will need:
postgres >= 8.4
PostGIS (depends on proj4 and geos libraries)

Installing on Mac OS X:
Run port install postgresql84-server geos
Create your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
Create your database(s)
Install proj4 from source (http://trac.osgeo.org/proj/)
Install postgis from source (http://postgis.refractions.net/)
Run sudo gem install bundler

Then, from the opengovernment dir:
Run "bundle install", then "rake install"
