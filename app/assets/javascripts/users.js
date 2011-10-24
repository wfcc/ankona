$(function()  {        
  //$('#accordion').accordion({fillSpace: true})   
  $('.hideable').hide()
  $('#name_handle').tokenInput('/authors/json?handle=1',
    { hintText: "Start typing your name"
    , minChars: 3
    , prePopulate: $.parseJSON($('#author_json').val())
    , tokenLimit: 1
    , onSelect: function (selected){
        $('#handle').html(selected.id)
        $('#name').html(selected.name)
        $('.hideable').show()
        return true
        }
    , theme: 'facebook'
    , onBeforeAdd: function(item){
      var matches
      if ( (isNaN(item.id)) && (matches = item.id.match(/^CREATE_(.+?)$/)) ) {
        item.name = matches[1]
        }
      }    
    })  
  })


