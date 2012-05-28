jQuery ->
  $('.user a.toggle-extra-info').click (ev) ->
    $('.user .extra-info').toggle()

  # TODO: cleanup
  $('.extra-tools .upvote').click (ev) ->
    console.log 'up'
    $.ajax $(this).data('voteurl'),
      type: 'POST'
      dataType: 'json'
      data:
        direction: 'up'
      success: (data) ->
        $('.extra-tools .rating').html(data.rating)

  $('.extra-tools .downvote').click (ev) ->
    console.log 'down'
    $.ajax $(this).data('voteurl'),
      type: 'POST'
      dataType: 'json'
      data:
        direction: 'down'
      success: (data) ->
        $('.extra-tools .rating').html(data.rating)
