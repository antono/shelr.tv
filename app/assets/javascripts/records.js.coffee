jQuery ->
  $('.user a.toggle-extra-info').click (ev) ->
    $('.user .extra-info').toggle()

  $('.extra-tools .upvote, .extra-tools .downvote').click (ev) ->
    if userLoggedIn
      $.ajax $(this).data('voteurl'),
        type: 'POST'
        dataType: 'json'
        data:
          direction: $(this).data('direction'),
        success: (data) ->
          $('.extra-tools .rating').html(data.rating)
    else
      $('#login-modal').clone().removeClass('hidden').modal()
