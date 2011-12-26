google.setOnLoadCallback(function() {

  $('div.slider').each(function(i,slider) {
    $(slider).slider(
      { min: 0
      , max: 4
      , step: 0.5
      , value: $(this).data('value')
      , change: function(event, ui) {
          var my = $(this)
          var did = my.data('did')
          var sid = $('.section').data('sid')
          var mmark = my.slider('value').toString()
          var submission = my.parents('form').serialize()
          submission += '&mark[nummark]=' + mmark
          $('.mark[data-did="' + did + '"]').text('...')
          $.post('/sections/' + sid + '/mark'
            , submission
            , function(data) {
              my.data('mid', data)
              $('.mark[data-did="' + did + '"]').text(mmark)
            })
          }
      })
    })

   
  })
  
