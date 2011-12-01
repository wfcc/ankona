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
          var mid = my.data('mid')
          var sid = $('.section').data('sid')
          var mmark = my.slider('value').toString()
          $('.mark[data-did="' + did + '"]').text('...')
          $('<input>').attr(
            { type: 'hidden'
            , name: 'mark[nummark]'
            , value: mmark
            }).appendTo('form')
          $.post('/sections/' + sid + '/mark'
            , $('form').serialize()
            , function(data) {
              my.data('mid', data)
              $('.mark[data-did="' + did + '"]').text(mmark)
            })
          }
      })
    })
    
  })
  
