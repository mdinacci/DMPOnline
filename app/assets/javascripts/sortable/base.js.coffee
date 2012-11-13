class @TheSortableTree
  max_levels  = 4
  rebuild_url = '/'
  rebuild_ok = true

  init: ->
    $('ol.sortable').nestedSortable
      disableNesting: 'no-nest'
      forcePlaceholderSize: true
      handle: 'div.handle'
      helper: 'clone'
      items:  'li'
      maxLevels: @max_levels
      opacity: .6
      placeholder: 'placeholder'
      revert: 250
      tabSize: 25
      tolerance: 'pointer'
      toleranceElement: '> div'

      update: (event, ui) =>
        parent_id = ui.item.parent().parent().attr('id')
        item_id   = ui.item.attr('id')
        prev_id   = ui.item.prev().attr('id')
        next_id   = ui.item.next().attr('id')

        @rebuild item_id, parent_id, prev_id, next_id

  rebuild: (item_id, parent_id, prev_id, next_id) =>
    @rebuild_ok = true
    
    $.ajax
      type:       'POST'
      dataType:   'text'
      async:      false
      url:        @rebuild_url
      data:
        id:        item_id
        parent_id: parent_id
        prev_id:   prev_id
        next_id:   next_id

      beforeSend: (xhr) ->
        $('.nested_set div.handle').hide()

      success: (data, status, xhr) -> 
        $('.nested_set div.handle').show()

      error: (xhr, status, error) =>
        alert xhr.responseText
        @rebuild_ok = false
        $('.nested_set div.handle').show()
    
    @rebuild_ok
