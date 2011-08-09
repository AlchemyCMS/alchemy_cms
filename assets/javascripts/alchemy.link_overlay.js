if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {
  
  var LinkOverlay = {};
  $.extend(Alchemy, LinkOverlay);
  
  Alchemy.LinkOverlay = {
    
    open : function (linked_element, width) {
      var $dialog = $('<div style="display:none" id="alchemyLinkOverlay"></div>');
      
      $dialog.html(Alchemy.getOverlaySpinner({x: width}));
      
      Alchemy.LinkOverlay.current = $dialog.dialog({
        modal: true, 
        minWidth: parseInt(width) < 600 ? 600 : parseInt(width), 
        minHeight: 450,
        title: 'Link setzen',
        show: "fade",
        hide: "fade",
        open: function (event, ui) {
          $.ajax({
            url: '/admin/pages/link',
            success: function(data, textStatus, XMLHttpRequest) {
              $dialog.html(data);
              Alchemy.SelectBox('#alchemyLinkOverlay select');
            },
            error: function(XMLHttpRequest, textStatus, errorThrown) {
              Alchemy.AjaxErrorHandler($dialog, XMLHttpRequest.status, textStatus, errorThrown);
            }
          });
        },
        close: function () {
          $dialog.remove();
        }
      });
      
      Alchemy.LinkOverlay.current.linked_element = linked_element;
      
    },
    
    close : function () {
      Alchemy.LinkOverlay.current.dialog('close');
      return true;
    },
    
    selectPage : function(selected_element, urlname) {
      $('#page_anchor').removeAttr('value');
      // We have to remove the Attribute. If not the value does not get updated.
      $('.elements_for_page').hide();
      $('#internal_urlname').val('/' + urlname);
      $('#alchemyLinkOverlay #sitemap .selected_page').removeClass('selected_page');
      $('#sitemap_sitename_' + selected_element).addClass('selected_page').attr('name', urlname);
    },
    
    createLink : function(link_type, url, title, target) {
      var element = Alchemy.LinkOverlay.current.linked_element;
      Alchemy.setElementDirty($(element).parents('.element_editor'));
      if (element.editor) {
        // aka we are linking text inside of TinyMCE
        var editor = element.editor;
        editor.execCommand('mceInsertLink', false, {
          href: url,
          'class': link_type,
          title: title,
          'data-link-target': target,
          target: target == 'blank' ? '_blank' : null
        });
        editor.selection.collapse();
      } else {
        // aka: we are linking an content
        var essence_type = element.name.replace('essence_', '').split('_')[0];
        var content_id = null;
        switch (essence_type) {
        case "picture":
          content_id = element.name.replace('essence_picture_', '');
          break;
        case "text":
          content_id = element.name.replace('essence_text_', '');
          break;
        }
        $('#contents_content_' + content_id + '_link').val(url);
        $('#contents_content_' + content_id + '_link_title').val(title);
        $('#contents_content_' + content_id + '_link_class_name').val(link_type);
        $('#contents_content_' + content_id + '_link_target').val(target);
        $(element).addClass('linked');
        $(element).next().addClass('linked').removeClass('disabled');
      }
    },
    
    // Selects the tab for kind of link and fills all fields.
    selectTab : function() {
      var linked_element = Alchemy.LinkOverlay.current.linked_element, link;
      
      // Creating an temporary anchor node if we are linking an EssencePicture or EssenceText.
      if (linked_element.nodeType) {
        link = Alchemy.LinkOverlay.createTempLink(linked_element);
      }
      
      // Restoring the bookmarked selection inside the TinyMCE of an EssenceRichtext.
      else {
        if (linked_element.node.nodeName === 'A') {
          link = linked_element.node;
          linked_element.selection.moveToBookmark(linked_element.bookmark);
        } else {
          return false;
        }
      }
      
      $('#alchemyLinkOverlay .link_title').val(link.title);
      $('#alchemyLinkOverlay .link_target').val($(link).attr('data-link-target'));
      
      // Checking of what kind the link is (internal, external, file or contact_form).
      if ($(link).is("a")) {
        var title = link.title == null ? "": link.title;
        
        // Handling an internal link.
        if ((link.className == '') || link.className == 'internal') {
          var internal_anchor = link.hash.split('#')[1];
          var internal_urlname = link.pathname;
          $('#overlay_tabs').tabs("select", '#overlay_tab_internal_link');
          $('#internal_urlname').val(internal_urlname);
          var $sitemap_line = $('.sitemap_sitename').closest('[name="'+internal_urlname+'"]');
          if ($sitemap_line.length > 0) {
            // Select the line where the link was detected in.
            $sitemap_line.addClass("selected_page");
            $('#page_selector_container').scrollTo($sitemap_line.parents('li'), {duration: 400, offset: -10});
            // is there an anchor in the url? then request the element selector via ajax and select the correct value. yeah!
            if (internal_anchor) {
              var $select_container = $sitemap_line.parent().find('.elements_for_page');
              $select_container.show();
              $.get("/admin/elements/?page_urlname=" + $(internal_urlname.split('/')).last()[0] + '&internal_anchor=' + internal_anchor);
            }
          }
        }
        
        // Handling an external link.
        if (link.className == 'external') {
          $('#overlay_tabs').tabs("select", '#overlay_tab_external_link');
          var protocols = [];
          $('#url_protocol option').map(function() {
            protocols.push($(this).attr('value'));
          });
          $(protocols).each(function(index, value) {
            if (link.href.beginsWith(value)) {
              $('#external_url').val(link.href.replace(value, ""));
              $('#url_protocol').val(value);
            }
          });
        }
        
        // Handling a file link.
        if (link.className == 'file') {
          $('#overlay_tabs').tabs("select", '#overlay_tab_file_link');
          $('#public_filename').val(link.pathname + link.search);
        }
        
        // Handling a contactform link.
        if (link.className == 'contact') {
          var link_url = link.pathname;
          var link_params = link.search;
          var link_subject = link_params.split('&')[0];
          var link_mailto = link_params.split('&')[1];
          var link_body = link_params.split('&')[2];
          $('#overlay_tabs').tabs("select", '#overlay_tab_contactform_link');
          $('#contactform_url').val(link_url);
          $('#contactform_subject').val(unescape(link_subject.replace(/subject=/, '')).replace(/\?/, ''));
          $('#contactform_body').val(unescape(link_body.replace(/body=/, '')).replace(/\?/, ''));
          $('#contactform_mailto').val(link_mailto.replace(/mail_to=/, '').replace(/\?/, ''));
        }
      }
    },
    
    showElementsSelect: function(id) {
      $('#elements_for_page_' + id + ' div.selectbox').remove();
      $('#elements_for_page_' + id).show();
      $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
    },
    
    hideElementsSelect: function(id) {
      $('#elements_for_page_' + id).hide();
      $('#elements_for_page_' + id + ' div.selectbox').remove();
      $('#page_anchor').removeAttr('value');
      $('#page_selector_container').scrollTo('#sitemap_sitename_'+id, {duration: 400, offset: -10});
    },
    
    createTempLink : function(linked_element) {
      var $tmp_link = $("<a></a>");
      var essence_type = $(linked_element).attr('name').replace('essence_', '').split('_')[0];
      var content_id;
      switch (essence_type) {
        case "picture":
          content_id = $(linked_element).attr('name').replace('essence_picture_', '');
        break;
        case "text":
          content_id = $(linked_element).attr('name').replace('essence_text_', '');
        break;
      }
      $tmp_link.attr('href', $('#contents_content_' + content_id + '_link').val());
      $tmp_link.attr('title', $('#contents_content_' + content_id + '_link_title').val());
      $tmp_link.attr('data-link-target', $('#contents_content_' + content_id + '_link_target').val());
      $tmp_link.attr('target', $('#contents_content_' + content_id + '_link_target').val() == 'blank' ? '_blank' : null);
      $tmp_link.addClass($('#contents_content_' + content_id + '_link_class_name').val());
      return $tmp_link[0];
    },
    
    removeLink : function(link, content_id) {
      Alchemy.setElementDirty($(link).parents('.element_editor'));
      $('#contents_content_' + content_id + '_link').val('');
      $('#contents_content_' + content_id + '_link_title').val('');
      $('#contents_content_' + content_id + '_link_class_name').val('');
      $('#contents_content_' + content_id + '_link_target').val('');
      $(link).removeClass('linked').addClass('disabled');
      $('#edit_link_' + content_id).removeClass('linked');
    }
    
  };
  
})(jQuery);
