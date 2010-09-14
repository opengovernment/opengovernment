/* Upgrade a text field to a search element, if supported. */
var mouse_is_on_menu = false;

function create_dropdown_menu(anchor_div, menu_div) {

  /* Breadcrumb dropdown menu */
  $(anchor_div).click(function() { //When trigger is clicked...  
      //Following events are applied to the subnav itself (moving subnav up and down)  
      var t = $(this).data("destroyHandle");
      if (t) {
        clearTimeout(t);
      }

      $(this).parent().find(menu_div).show(); //Drop down the subnav on click  
      $(this).addClass("subhover"); //On hover over, add class "subhover"
      return false;
  });

  // Leave the menu open when we hover over it,
  // but close it after a delay when we leave it.
  $(menu_div).parent().hover(
    function() {
      mouse_is_on_menu = true;
      var t = $(this).find("a").data("destroyHandle");
      if (t) {
        clearTimeout(t);
      }
    },
    function() {
      mouse_is_on_menu = false;
      var t = setTimeout(function() {
        $(menu_div).hide();
        $(anchor_div).removeClass("subhover");
      }, 1200);

      $(this).find("a").data("destroyHandle", t)
      return false;
    }
  );

  // Close the menu when someone clicks outside of it.
  $('body').mouseup(function(){ 
      if(! mouse_is_on_menu) {
        $(menu_div).hide();
        $(anchor_div).removeClass("subhover"); 
      }
  });

}

$(document).ready(function(){ 
  create_dropdown_menu("a#dropdown", "ul.state-select");
});


