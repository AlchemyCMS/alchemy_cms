if (typeof(Alchemy) === 'undefined') {
  var Alchemy = {};
}

(function($) {

  $.extend(Alchemy, {

    SortableElements: function(page_id, form_token, selector) {
      if (typeof(selector) === 'undefined') {
        selector = '#element_area .sortable_cell';
      }
      $(selector).sortable({
        items: 'div.element_editor',
        handle: '.element_handle',
        axis: 'y',
        placeholder: 'droppable_element_placeholder',
        forcePlaceholderSize: true,
        dropOnEmpty: true,
        opacity: 0.5,
        cursor: 'move',
        tolerance: 'pointer',
        update: function(event, ui) {
          var ids = $.map($(this).children(), function(child) {
            return $(child).attr('data-element-id');
          });
          var params_string = '';
          var cell_id = $(this).attr('data-cell-id');
          // Is the trash window open?
          if ($('#alchemyTrashWindow').length > 0) {
            // updating the trash icon
            if ($('#trash_items div.element_editor').not('.dragged').length === 0) {
              $('#element_trash_button .icon').removeClass('full');
              $('#trash_empty_notice').show();
            }
          }
          $(event.target).css("cursor", "progress");
          params_string = "page_id=" + page_id + "&authenticity_token=" + encodeURIComponent(form_token) + "&" + $.param({
            element_ids: ids
          });
          if (cell_id) {
            params_string += "&cell_id=" + cell_id;
          }
          $.ajax({
            url: Alchemy.routes.order_admin_elements_path,
            type: 'POST',
            data: params_string,
            complete: function() {
              $(event.target).css("cursor", "auto");
              Alchemy.refreshTrashWindow(page_id);
            }
          });
        },
        start: function(event, ui) {
          var $textareas = ui.item.find('textarea.default_tinymce, textarea.custom_tinymce');
          $textareas.each(function() {
            tinymce.get(this.id).remove();
          });
        },
        stop: function(event, ui) {
          var $textareas = ui.item.find('textarea.default_tinymce, textarea.custom_tinymce');
          $textareas.each(function() {
            Alchemy.Tinymce.addEditor(this.id);
          });
        }
      });
    },

    SortableContents: function(selector, token) {
      $(selector).sortable({
        items: 'div.dragable_picture',
        handle: 'div.picture_handle',
        opacity: 0.5,
        cursor: 'move',
        tolerance: 'pointer',
        containment: 'parent',
        update: function(event, ui) {
          var ids = $.map($(this).children('div.dragable_picture'), function(child) {
            return child.id.replace(/essence_picture_/, '');
          });
          $(event.originalTarget).css("cursor", "progress");
          $.ajax({
            url: Alchemy.routes.order_admin_contents_path,
            type: 'POST',
            data: "authenticity_token=" + encodeURIComponent(token) + "&" + $.param({
              content_ids: ids
            }),
            complete: function() {
              $(event.originalTarget).css("cursor", "move");
            }
          });
        }
      });
    },

    DraggableTrashItems: function(items_n_cells) {
      $("#trash_items div.draggable").each(function() {
        var cell_classes = '';
        var cell_names = items_n_cells[this.id];
        $.each(cell_names, function(i) {
          cell_classes += '.' + this + '_cell' + ', ';
        });
        $(this).draggable({
          helper: 'clone',
          iframeFix: 'iframe#alchemyPreviewWindow',
          connectToSortable: cell_classes.replace(/,.$/, ''),
          start: function(event, ui) {
            $(this).hide().addClass('dragged');
            ui.helper.css({
              width: '300px'
            });
          },
          stop: function() {
            $(this).show().removeClass('dragged');
          }
        });
      });
    }

  });

})(jQuery);
