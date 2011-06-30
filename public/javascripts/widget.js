/* 
 * By Carl Tashian (carl@tashian.com)
 * (c) 2011 Participatory Politics Foundation
 * 
 * The general structure for this was inspired by twitter's widget.js by Dustin Diaz (dustin@twitter.com)
 * 
 */

/* Call this widget like so:
<script src="http://opengovernment.org/javascripts/widget.js"></script>
<script>
  new OG.Widget({
    version: 1,
    type: 'most_viewed_bills',
    theme: {
      background: '#333333',
      color: '#ffffff',
      links: '#4aed05'
    }
  }).render();
</script>

*/

OG = window.OG || {};

(function(undefined) {
  if (OG && OG.Widget) {
    // in case people include this script twice
    return;
  }

  OG.Widget = function(opts) {
    this.init(opts);
  };

  // Takes an ISO time and returns a Date
  OG.dateFromISO8601 = function (time) {
  	return new Date((time || "").replace(/-/g,"/").replace(/[TZ]/g," "));
  };

  /*
   * Date Format 1.2.3
   * (c) 2007-2009 Steven Levithan <stevenlevithan.com>
   * MIT license
   *
   * Includes enhancements by Scott Trenda <scott.trenda.net>
   * and Kris Kowal <cixar.com/~kris.kowal/>
   *
   * Accepts a date, a mask, or a date and a mask.
   * Returns a formatted version of the given date.
   * The date defaults to the current date/time.
   * The mask defaults to dateFormat.masks.default.
   */

  var dateFormat = function () {
  	var	token = /d{1,4}|m{1,4}|yy(?:yy)?|([HhMsTt])\1?|[LloSZ]|"[^"]*"|'[^']*'/g,
  		timezone = /\b(?:[PMCEA][SDP]T|(?:Pacific|Mountain|Central|Eastern|Atlantic) (?:Standard|Daylight|Prevailing) Time|(?:GMT|UTC)(?:[-+]\d{4})?)\b/g,
  		timezoneClip = /[^-+\dA-Z]/g,
  		pad = function (val, len) {
  			val = String(val);
  			len = len || 2;
  			while (val.length < len) val = "0" + val;
  			return val;
  		};

  	// Regexes and supporting functions are cached through closure
  	return function (date, mask, utc) {
  		var dF = dateFormat;

  		// You can't provide utc if you skip other args (use the "UTC:" mask prefix)
  		if (arguments.length == 1 && Object.prototype.toString.call(date) == "[object String]" && !/\d/.test(date)) {
  			mask = date;
  			date = undefined;
  		}

  		// Passing date through Date applies Date.parse, if necessary
  		date = date ? new Date(date) : new Date;
  		if (isNaN(date)) throw SyntaxError("invalid date");

  		mask = String(dF.masks[mask] || mask || dF.masks["default"]);

  		// Allow setting the utc argument via the mask
  		if (mask.slice(0, 4) == "UTC:") {
  			mask = mask.slice(4);
  			utc = true;
  		}

  		var	_ = utc ? "getUTC" : "get",
  			d = date[_ + "Date"](),
  			D = date[_ + "Day"](),
  			m = date[_ + "Month"](),
  			y = date[_ + "FullYear"](),
  			H = date[_ + "Hours"](),
  			M = date[_ + "Minutes"](),
  			s = date[_ + "Seconds"](),
  			L = date[_ + "Milliseconds"](),
  			o = utc ? 0 : date.getTimezoneOffset(),
  			flags = {
  				d:    d,
  				dd:   pad(d),
  				ddd:  dF.i18n.dayNames[D],
  				dddd: dF.i18n.dayNames[D + 7],
  				m:    m + 1,
  				mm:   pad(m + 1),
  				mmm:  dF.i18n.monthNames[m],
  				mmmm: dF.i18n.monthNames[m + 12],
  				yy:   String(y).slice(2),
  				yyyy: y,
  				h:    H % 12 || 12,
  				hh:   pad(H % 12 || 12),
  				H:    H,
  				HH:   pad(H),
  				M:    M,
  				MM:   pad(M),
  				s:    s,
  				ss:   pad(s),
  				l:    pad(L, 3),
  				L:    pad(L > 99 ? Math.round(L / 10) : L),
  				t:    H < 12 ? "a"  : "p",
  				tt:   H < 12 ? "am" : "pm",
  				T:    H < 12 ? "A"  : "P",
  				TT:   H < 12 ? "AM" : "PM",
  				Z:    utc ? "UTC" : (String(date).match(timezone) || [""]).pop().replace(timezoneClip, ""),
  				o:    (o > 0 ? "-" : "+") + pad(Math.floor(Math.abs(o) / 60) * 100 + Math.abs(o) % 60, 4),
  				S:    ["th", "st", "nd", "rd"][d % 10 > 3 ? 0 : (d % 100 - d % 10 != 10) * d % 10]
  			};

  		return mask.replace(token, function ($0) {
  			return $0 in flags ? flags[$0] : $0.slice(1, $0.length - 1);
  		});
  	};
  }();

  // Some common format strings
  dateFormat.masks = {
  	"default":      "ddd mmm dd yyyy HH:MM:ss",
  	shortDate:      "m/d/yy",
  	mediumDate:     "mmm d, yyyy",
  	longDate:       "mmmm d, yyyy",
  	fullDate:       "dddd, mmmm d, yyyy",
  	shortTime:      "h:MM TT",
  	mediumTime:     "h:MM:ss TT",
  	longTime:       "h:MM:ss TT Z",
  	isoDate:        "yyyy-mm-dd",
  	isoTime:        "HH:MM:ss",
  	isoDateTime:    "yyyy-mm-dd'T'HH:MM:ss",
  	isoUtcDateTime: "UTC:yyyy-mm-dd'T'HH:MM:ss'Z'"
  };

  // Internationalization strings
  dateFormat.i18n = {
  	dayNames: [
  		"Sun", "Mon", "Tue", "Wed", "Thu", "Fri", "Sat",
  		"Sunday", "Monday", "Tuesday", "Wednesday", "Thursday", "Friday", "Saturday"
  	],
  	monthNames: [
  		"Jan", "Feb", "Mar", "Apr", "May", "Jun", "Jul", "Aug", "Sep", "Oct", "Nov", "Dec",
  		"January", "February", "March", "April", "May", "June", "July", "August", "September", "October", "November", "December"
  	]
  };

  // For convenience...
  Date.prototype.format = function (mask, utc) {
  	return dateFormat(this, mask, utc);
  };

  String.prototype.truncate = function (len) {
    return (this.length > len ? this.substring(0, len) + '...' : this);
  };

  (function(undefined) {

    /* This section is from jQuery 1.6
    * Copyright 2011, John Resig
    * Dual licensed under the MIT or GPL Version 2 licenses.
    * http://jquery.org/license
    */

  	// [[Class]] -> type pairs
  	var class2type = {};

    // Populate the class2type map
    _.each("Boolean Number String Function Array Date RegExp Object".split(" "), function(name, i) {
    	class2type[ "[object " + name + "]" ] = name.toLowerCase();
    });

    var isFunction = function( obj ) {
      return type(obj) === "function";
    };

    var type = function( obj ) {
  		return obj == null ?
  			String( obj ) :
  			class2type[ toString.call(obj) ] || "object";
  	};

  	/* end jQuery stuff */

  	/* Modify document CSS */
  	var css = function(cssCode) {
      var styleElement = document.createElement("style");
      styleElement.type = "text/css";
      if (styleElement.styleSheet) {
        styleElement.styleSheet.cssText = cssCode;
      } else {
        styleElement.appendChild(document.createTextNode(cssCode));
      }
      document.getElementsByTagName("head")[0].appendChild(styleElement);
    };
  	
    /* Append a new stylesheet link tag */
  	var injectStyleSheet = function(url, widgetEl) {
      var linkElement = document.createElement('link');
      linkElement.href = url;
      linkElement.rel = 'stylesheet';
      linkElement.type = 'text/css';
      document.getElementsByTagName('head')[0].appendChild(linkElement);
    };

  	var isHttps = location.protocol.match(/https/);
  	
    OG.Widget.WIDGET_NUMBER = 0;

    OG.Widget.prototype = function () {
      var http = isHttps ? 'https://' : 'http://';
      var domain = 'opengovernment.org';

      // From http://javascriptweblog.wordpress.com/2010/11/29/json-and-jsonp/
      var jsonp = {
          CALLBACK_NUMBER: 0,

          fetch: function(url, callback) {
              var fn = 'JSONPCallback_' + this.CALLBACK_NUMBER++;
              window[fn] = this.evalJSONP(callback);
              url = url.replace('=?', '=' + fn);

              var scriptTag = document.createElement('script');
              scriptTag.src = url;
              document.getElementsByTagName('head')[0].appendChild(scriptTag);
          },

          evalJSONP: function(callback) {
              return function(data) {
                  var validJSON = false;
      	    if (typeof data == "string") {
      	        try {validJSON = JSON.parse(data);} catch (e) {
      	            /*invalid JSON*/}
      	    } else {
      	        validJSON = JSON.parse(JSON.stringify(data));
                      window.console && console.warn(
      	            'response data was not a JSON string');
                  }
                  if (validJSON) {
                      callback(validJSON);
                  } else {
                      throw("JSONP call returned invalid or empty JSON");
                  }
              }
          }
      }

      return {
        init: function(ops) {
          this.ops = ops;
          this.theme = ops.theme ? ops.theme : this._getDefaultTheme();
          this._widgetNumber = ++OG.Widget.WIDGET_NUMBER;
          this._isPeopleWidget = ops.type == 'most_viewed_people';
          this._isBillsWidget = ops.type == 'most_viewed_bills';
          this._isBillWidget = ops.type == 'bill_status';
          this.type = ops.type;
          this.bill = ops.bill;
          this.state = ops.state || 'ca';
          this._subdomain = this.state + '.' + domain;
          this.preview = ops.preview || false;
          this.url = this._getUrl();
          this.setWidth(ops.width);
          this.id = ops.id || 'og-widget-' + this._widgetNumber;

          this._reset();

          this._ready = isFunction(ops.ready) ? ops.ready : function() { };
          
          return this;
        },

        _reset: function() {
          // Create an element if we don't get an id passed in.
          if (this.widgetEl = document.getElementById(this.id)) {
            classes.add(this.widgetEl, 'og-widget');
          } else {
            document.write('<div class="og-widget" id="' + this.id + '"></div>');
            this.widgetEl = document.getElementById(this.id);
          }
        },
      
        _getDefaultTheme: function() {
          return {
            background: "#f9f9f9",
            header: "#333",
            color: "#555",
            links: "#1985b5"
          };
        },

        _getUrl: function() {
          if (this._isBillsWidget) {
            return http + this._subdomain + '/bills.json?sort=views&limit=3&callback=?';
          } else if (this._isBillWidget) {
            return http + this._subdomain + '/sessions/' + escape(this.bill.session + '/bills/' + this.bill.number) + '.json?callback=?';
          } else {
            return http + this._subdomain + '/people.json?sort=views&limit=3&callback=?';
          }
        },

        getOptions: function() {
          return this.ops;
        },

        getOptionsForSnippet: function() {
          var ops = {};
          // essentially this.ops.except(:preview)
          for (attrname in this.ops) { ops[attrname] = this.ops[attrname]; }
          delete ops.preview;
          return ops;
        },

        setWidth: function(w) {
          this.ops.width = w ? w : 'auto';

          // min width: 150px, min height: 100px.
          this.width = (this.ops.width == "auto" || this.ops.width == "100%") ? "100%" : (this.ops.width < 150 ? 150 : this.ops.width) + "px";

          return this;
        },

        _setWidth: function() {
          // Apply the width to the widget.
          var style = '#' + this.id + ' {\
            width: ' + this.width + ';\
          }';
          css(style);
          return this;
        },

        setTheme: function(theme) {
          var that = this;

          this.theme = this.ops.theme = {
            background: function() {
              return theme.background || that._getDefaultTheme().background
            } (),
            color: function() {
              return theme.color || that._getDefaultTheme().color
            } (),
            links: function() {
              return theme.links || that._getDefaultTheme().links
            } (),
            header: function() {
              return theme.header || that._getDefaultTheme().header
            } ()
          };
          var style = '#' + this.id + ', #' + this.id + ' h1, #' + this.id + ' h1 a {\
            color: ' + this.theme.header + ' !important;\
          }\
          #' + this.id + ' a {\
            color: ' + this.theme.links + ' !important;\
          }\
          #' + this.id + ' {\
            color: ' + this.theme.color + ' !important;\
            background-color: ' + this.theme.background + ' !important;\
          }';
          css(style);
          return this;
        },

        setBill: function(bill) {
          this.bill = this.ops.bill = bill;
          this.url = this._getUrl();
          return this;
        },

        _injectStyleSheet: function() {
          injectStyleSheet(http + domain + "/stylesheets/widget.css", this.widgetEl);
        },

        // Fetch the data via jsonp, and update the widget
        _fetch: function() {
          var that = this;
          jsonp.fetch(this.url, function(data) {
            // jsonp callback
            var params = {state: that.state, subdomain: http + that._subdomain};
            params[that['type']] = data;
            that.widgetEl.innerHTML = window.JST[that.type](params);
          });
        },

        setTitle: function(title) {
          this.title = title;
          this.widgetEl.getElementsByTagName('h3')[0].innerHTML = this.title;
          return this;
        },
        
        setCaption: function(subject) {
          this.subject = subject;
          this.widgetEl.getElementsByTagName('h4')[0].innerHTML = this.subject;
          return this;
        },

        // Actually render the widget on the page.
        render: function() {
          this.setTheme(this.theme);
          this._setWidth();
          if (!this.preview) { this._injectStyleSheet(); }
          this._fetch();
          this._ready();
          return this;
        },

        // Refresh the widget after style changes.
        // Does not resize the widget.
        reformat: function() {
          this.setTheme(this.theme);
          this._fetch();
          return this;
        }
      }
    }();
    
  })(); // internal namespace

})(); // application closure


