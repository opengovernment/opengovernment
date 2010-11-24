OpenGovernment is a Ruby on Rails application for aggregating and presenting open government data.

# Prerequisites
Before you install the app, you will need to download and install the following:

  * PostgreSQL 8.4
  * [PostGIS](http://postgis.refractions.net/) (which requires the [proj4](http://trac.osgeo.org/proj/) and [geos](http://trac.osgeo.org/geos/) libraries)
  * Rails 3
  * REE 1.8.7 recommended (install via [RVM](http://rvm.beginrescueend.com/))
  * [Sphinx](http://www.sphinxsearch.com/) is required. [Here are the install instructions](http://freelancing-god.github.com/ts/en/installing_sphinx.html). You can locate your `pg_sql` include directory using `pg_config --pkgincludedir`
  * [GeoServer](http://geoserver.org/display/GEOS/Welcome), if you want to see vote maps
  * [MongoDB](http://mongodb.org/) for page view count support

# Installing prerequisites via MacPorts:

[Download MacPorts](http://www.macports.org/)

Then run:
    # Install MacPorts items
    sudo port selfupdate
    sudo port install postgresql84 postgis mongodb git-core
    sudo port install sphinx +postgresql84
    
    # Install RVM
    bash < <( curl http://rvm.beginrescueend.com/releases/rvm-install-head )
    
    # Re-open the terminal, then
    rvm install ree
    rvm --create ree@og
    rvm use ree@og
    gem install bundler 

# General Installation
  * Get a copy of the code:
        git clone http://github.com/opengovernment/opengovernment.git
        cd opengovernment
        git submodule init
        git submodule update
        bundle install
  * Set up your config/database.yml and config/api_keys.yml (see api_keys.yml.example)
  * Create your database role and give it superuser privileges:
        psql# CREATE ROLE opengovernment WITH SUPERUSER LOGIN CREATEDB
  * Run the following:
        rake install
  * You can provide a comma-separated list of states in a LOAD_STATES env variable to rake install. Otherwise, the default "loadable" states will be loaded, as specified in the tasks/fixtures/states.yml file.
  * Rake install will set up the database, install the PostGIS SQL components, install fixtures, and download and install datasets. It typically takes at least an hour. You can always install the test database fixtures if you don't want to wait for the full install.
  * Once the install is complete, start the server:
        rails server

OpenGovernment uses subdomains, so to access the site you'll find the `127localhost.com` domain helpful. This is a domain for which all subdomains point to localhost. So if you visit, for example, `http://tx.127localhost.com:3000`, you should see the Texas OpenGovernment subsite.

# Thinking Sphinx installation (for search functionality)
You should already have the `thinkingsphinx` gem installed via the bundle.
    rake ts:start
will start the Sphinx server.

# GeoServer Installation (for vote maps)
Download and install [GeoServer](http://geoserver.org/display/GEOS/Welcome).

After starting the server, you'll want to sign in and add a new Store for OpenGovernment. Here are the details:
    Data Source: PostGIS
    Workspace: cite
    Date Source Name: og
    Database User & PW should match your database.yml

You'll want to add two new Layers to the `og` Store as well. You'll only need to set the name and title on these--all other settings can remain default. The layers should be called `v_district_people` and `v_district_votes`.

# Tests
To prepare the test database: `RAILS_ENV=test rake db:prepare`.
Then, to run all tests: `rake`.

You can use autotest or spork. To fire up the spork-based drb server, run `script/spec_server`

# Troubleshooting

Many bill versions and documents in state legislatures have FTP URLs associated with them. Ruby 1.8.7's Net::FTP does not negotiate passive FTP and will hang if you are using iptables without the `ip_conntrack_ftp` module.

In `/etc/sysconfig/iptables-config`, add it to `IPTABLES_MODULES`:
    IPTABLES_MODULES="ip_conntrack_netbios_ns ip_conntrack_ftp"

