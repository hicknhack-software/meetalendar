#
#= require_tree .
#= require_self
#

$ ->
  $("form").submit ->
    checked_checkboxes = $(this).find('input[type="checkbox"]').filter ->
      return $(this).is(':checked') == true

    checked_indices = (checked_checkboxes.map ->
      return $(this).attr 'data-index').toArray()

    $(this).find('input[data-index]').each ->
      if !checked_indices.includes($(this).attr 'data-index')
        $(this).attr('disabled', true)
      return

    return
