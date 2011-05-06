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
          this.type = ops.type;
          this.state = ops.state || 'ca';
          this._subdomain = this.state + '.' + domain;
          this.url = this._getUrl();
          this.setDimensions(ops.width, ops.height);
          this.id = ops.id || 'og-widget-' + this._widgetNumber;

          if (!ops.id) {
            document.write('<div class="og-widget" id="' + this.id + '"></div>');
          }
          this.widgetEl = document.getElementById(this.id);
          if (ops.id) {
            classes.add(this.widgetEl, 'og-widget');
          }
          this._ready = isFunction(ops.ready) ? ops.ready : function() { };
          
          return this;
        },
        _getDefaultTheme: function() {
          return {
            background: "#8ec1da",
            color: "#ffffff",
            links: "#1985b5"
          };
        },
        _getUrl: function() {
          if (this._isBillsWidget) {
            return http + this._subdomain + '/bills.json?sort=views&callback=?';
          } else {
            return http + this._subdomain + '/people.json?sort=views&callback=?';
          }
        },
        setDimensions: function(a, b) {
            this.wh = a && b ? [a, b] : [250, 300],

            // min width: 150px, min height: 100px.
            a == "auto" || a == "100%" ? this.wh[0] = "100%": this.wh[0] = (this.wh[0] < 150 ? 150: this.wh[0]) + "px",
            this.wh[1] = (this.wh[1] < 100 ? 100: this.wh[1]) + "px";
            return this;
        },
        setTheme: function(theme) {
          this.theme = {
            background: function() {
              return theme.background || this._getDefaultTheme().background
            } (),
            color: function() {
              return theme.color || this._getDefaultTheme().color
            } (),
            links: function() {
              return theme.links || this._getDefaultTheme().links
            } ()
          };
          var style = '#' + this.id + ' {\
            background-color: ' + this.theme.background + ';\
            color: ' + this.theme.color + ';\
          }\
          #' + this.id + ' a {\
            color: ' + this.theme.links + ';\
          }';
          css(style);
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
            that.widgetEl.innerHTML = window.JST[that.type]({subdomain: http + that._subdomain, collection: data});
          })
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
          this._injectStyleSheet();
          this._fetch();
          this._ready();
          return this;
        }
      }
    }();
    
  })(); // internal namespace

})(); // application closure


