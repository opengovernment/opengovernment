Tracker = {
  req: {},
  track: function() {
    var env = this.req;
    delete env.trackingServer;
    delete env.trackingServerSecure;
    env.u = document.location.href;
    env.bw = window.innerWidth;
    env.bh = window.innerHeight;

    if(document.referrer && document.referrer != "") {
      env.ref = document.referrer;
    }

    $('body').append('<img src="/tracking.gif?' + jQuery.param(env) + '"/>');
  }
};
