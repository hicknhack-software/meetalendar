#
#= require_tree .
#= require_self
#

$ ->
  $(".load-more").click (e) ->
    e.preventDefault()

    alert('I alert on .load-more')
    return
