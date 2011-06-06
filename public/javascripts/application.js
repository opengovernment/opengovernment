/* Upgrade a text field to a search element, if supported. */
var mouse_is_on_menu = false;

function create_dropdown_menu(anchor_div, menu_div) {

  /* Breadcrumb dropdown menu */
  $(anchor_div).click(function() {
      // When trigger is clicked...  
      //Following events are applied to the subnav itself (moving subnav up and down)  
      var t = $(this).data("destroyHandle");
      if (t) {
        clearTimeout(t);
      }

      if (!$(this).hasClass("subhover")) {
        $(this).parent().find(menu_div).show(); //Drop down the subnav on click  
        $(this).addClass("subhover"); //On hover over, add class "subhover"
      } else {
        $(menu_div).hide();
        $(anchor_div).removeClass("subhover");
      }

      return false;
  });

  // Leave the menu open when we hover over it,
  // but close it after a delay when we leave it.
  $(menu_div).parent().hover(
    function() {
      $(this).find("a").data("onMenu", true);
      var t = $(this).find("a").data("destroyHandle");
      if (t) {
        clearTimeout(t);
      }
    },
    function() {
      $(this).find("a").data("onMenu", false);
      var t = setTimeout(function() {
        $(menu_div).hide();
        $(anchor_div).removeClass("subhover");
      }, 1200);

      $(this).find("a").data("destroyHandle", t);
      return false;
    }
  );

  // Close the menu when someone clicks outside of it.
  $('body').mouseup(function(){ 
      if(! $(menu_div).parent().find("a").data("onMenu")) {
        $(menu_div).hide();
        $(anchor_div).removeClass("subhover");
      }
  });

}

$(function() {

  // Hover tooltips
  // http://onehackoranother.com/projects/jquery/tipsy/
  $('a[rel=tipsy],span[rel=tipsy]').tipsy();
  $('a[rel=tipsy-south],span[rel=tipsy-south]').tipsy({gravity: 's'});

  // For backwards-compatible placeholder attribute in input fields
  // http://plugins.jquery.com/plugin-tags/placeholder
  $('input').placeholder();

  $('a[data-hover-hide]').hover(
    function() {
      var link = $(this), link_id = link.attr('data-hover-hide');
      $(link_id).hide();
    }
  );
  
  $('a[data-hover-show]').hover(
    function() {
      var link = $(this), link_id = link.attr('data-hover-show');  
      $(link_id).show();
    }
  );

  // AjAX Modals
  // http://colorpowered.com/colorbox/
  $('a.modal').colorbox({
      transition: 'none',
      opacity: 0.8,
      scrolling: false
  });

  $('a.compact_modal').colorbox({
      transition: 'none',
      opacity: 0.8,
      scrolling: false,
      height: 400
  });

  // Initialize dropdown menus
  $('a[data-dropdown]').each(function() {
    create_dropdown_menu(this, $(this).data('dropdown'));
  });
  
  // Initialize inline dialogs
  $('a[data-dialog]').each(function() {
    var dialog_selector = $(this).data('dialog');

    $(dialog_selector).dialog({
      autoOpen: false
    });

    $(this).click(function() {  
      $(dialog_selector).dialog('open');  
    });
    
  });

  // Show the spinner on AJAX calls
  $('a[data-remote]').live('ajax:loading', function() {
    $(this).closest('ul').find(".spin").show();
    }
  );

  $('a[data-remote]').live('ajax:complete', function() {
    $(this).closest('ul').find(".spin").hide();
    }
  );

  // Twitter searches
  $('div[data-twitter-search]').each(function () {
    var limit = $(this).data('twitter-limit') || 2;
    console.log('"' + $(this).data('twitter-search') + '"', this, limit);
    TwitterAPI.hook('"' + $(this).data('twitter-search') + '"', this, limit);
  });

  // On pages with votes, resize the vote bar to show votes relative to one another.
  if ($('.vote-bar')) {
    vote_counts = $('.vote-bar').map(function () { return $(this).data('vote-count'); });

    max_vote_count = 0
    vote_counts.each(function () { if (this > max_vote_count) { max_vote_count = this; } });

    $('.vote-bar').each(function () {
      $(this).width( (($(this).data('vote-count') / max_vote_count) * 100).toString() + "%" );
    });
  }

});

function replaceURLWithHTMLLinks(text) {
  var exp = /(\b(https?|ftp|file):\/\/[-A-Z0-9+&@#\/%?=~_|!:,.;]*[-A-Z0-9+&@#\/%=~_|])/ig;
  return text.replace(exp,"<a href='$1' rel='nofollow' target='_blank'>$1</a>"); 
}

