Alchemy.ScrollableMenu = {
  expandibleMenu: function(){    
    $(".main_navi_entry.has_sub_navigation.active").addClass('expanded');
    $(".main_navi_entry.has_sub_navigation").click(function(event){      
      var target= $(event.target);
      if(target.hasClass('main_navi_entry')){
        $(this).toggleClass('expanded');
      }
    });
  },
  init: function() {
    this.expandibleMenu();

    new SimpleBar($('#left_menu')[0]);
  }
}
