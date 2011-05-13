$(function()  {        
  //$('#accordion').accordion({fillSpace: true})   

  //$('#submit').attr('disabled', 'disabled')

  $('#name_handle').tokenInput('/authors/json',
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


  $('form:first').submit(function() {
    var author = $('#name_handle').val()
    
    if (!author) {
      $('#ajax_error').text("You have to provide a name.")
      return false
      }
    
    var matches
    var input = $('<input>').attr('type', 'hidden').appendTo('form:first')

    if (matches = author.match(/^CREATE_(.+?)$/)) {
      // создать новый
      input.attr('name', 'user[author_attributes][name]').val(matches[1])
      }
    else {
      // использовать старый
      input.attr('name', 'user[author_id]').val(author)
      }
    })


  })


