jQuery ->
  $('.user a.toggle-extra-info').click (ev) ->
    $('.user .extra-info').toggle()

  $('.extra-tools .upvote, .extra-tools .downvote').click (ev) ->
    $.ajax $(this).data('voteurl'),
      type: 'POST'
      dataType: 'json'
      data:
        direction: $(this).data('direction'),
      success: (data) ->
        $('.extra-tools .rating').html(data.rating)
