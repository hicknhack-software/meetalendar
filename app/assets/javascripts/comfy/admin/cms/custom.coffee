#
#= require_tree .
#= require_self
#

# $ ->
#   $(".load-more").click (e) ->
#     e.preventDefault()
#     alert "load-more?"

#     current_offset = e.currentTarget.dataset.currentOffset
#     $.get "/admin/meetalendar/meetup_api/search/new?page=#{current_offset}", ((data) ->
#       console.log data
#       return), 'json'
