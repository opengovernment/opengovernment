// Twitter API wrapper. http://apiwiki.twitter.com/Twitter-API-Documentation
function TwitterAPI(){}

// http://apiwiki.twitter.com/Twitter-Search-API-Method%3A-search
TwitterAPI.search = function(q, callback){
	requestURL = "http://search.twitter.com/search.json?q=" + escape(q) + "&callback=?";
	$.getJSON(requestURL, callback);
}

TwitterAPI.refresh = function(q) {
  TwitterAPI.search(q, function(json, status){
  	var content = "";
    var count = 0;

  	$.each(json['results'], function(i) {
  	  count += 1;
  	  if (i <= 5) {
    	  created_at = new Date(this['created_at']);
    		tweet = '<span class="from_user"><a rel="nofollow" href="http://twitter.com/' + escape(this['from_user']) + '">' + this['from_user'] + '</a></span> ';
    		tweet += '<span class="text">' + replaceURLWithHTMLLinks(this['text']) + "</span>";
    		tweet += '<time class="timeago" datetime="' + created_at.toISOString() + '"></time>';
    		content += '<li class="tweet">' + tweet + '</li>';
      }
  	});

    if (count > 0) {
      $("#twitter").show();
  	  $("ul#tweets").html(content);
  	  jQuery("time.timeago").timeago(); 
    }

  });
}


TwitterAPI.hook = function(q) {
  $(document).ready(function() {
    TwitterAPI.refresh(q);
  });

  setInterval(function() { TwitterAPI.refresh(q);  }, 30000);
}
