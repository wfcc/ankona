google.setOnLoadCallback(function() {
  $('.slider').each(function(i,slider) {
    $(slider).slider(
      { min: 0
      , max: 5
      , step: 0.5
      , value: $(this).data('value')
      , change: function(event, ui) {
          var my = $(this)
          var did = my.data('did')
          var mid = my.data('mid')
          var sid = $('.section').data('sid')
          var mmark = my.slider('value').toString()
          $('.mark[data-did="' + did + '"]').text('...')
          $.get('/sections/' + sid + '/mark'
            , {diagram_id: did, nummark: mmark, section_id: sid, mid: mid}
            , function(data) {
              my.data('mid', data)
              $('.mark[data-did="' + did + '"]').text(mmark)
            })
          }
      })
    })

  })
  
