function BitlyAPI(login, apiKey) {
  this.login = login;
  this.apiKey = apiKey;
}

BitlyAPI.prototype.shorten = function(link, callback) {
  requestURL = "http://api.bit.ly/v3/shorten?login=" + this.login + "&apiKey=" + this.apiKey + "&longUrl=" + link + "&format=json&callback=?";
  $.getJSON(requestURL, callback);
}
