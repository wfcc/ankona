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
          $.post('/sections/' + sid + '/mark'
            , {diagram_id: did, nummark: mmark, section_id: sid, 'mark[id]': mid}
            , function(data) {
              my.data('mid', data)
              $('.mark[data-did="' + did + '"]').text(mmark)
            })
          }
      })
    })
    
  $('form.edit_mark').each(function(i,edit_mark) {
    var updating = $(this).find('.updating')
    var button = $(this).find('input[name="commit"]')
    $(edit_mark).bind('ajax:beforeSend', function(evt, xhr, settings) {
      updating.text('Updating...')
      button.attr('disabled', true)
      })
    $(edit_mark).bind('ajax:complete', function(evt, xhr, settings) {
      updating.text('')
      button.attr('disabled', false)
      })
    })
    
  })
  
