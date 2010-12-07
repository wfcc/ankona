
$(document).ready(function()
  {
  $('#add_author').click(function()
    {
    $('#author_name_first').clone().appendTo('#authors')
    })

  $('#author_name_first').autocomplete({
    minLength: 3,
    source: '/authors/json',
    select: function(event, ui)
      { 
      $('#author_code').html(ui.item.value)
      }
    })
  
  PIECE = ''
  $('#diagram_white').bind('keyup', updateFen)
  $('#diagram_black').bind('keyup', updateFen)
  $('#diagram_position').bind('keyup', updateFromFen)

  initVars()
  if (! $('#diagram_position').val())
    { updateFen({keyCode: 50})
    } else
    { updateFromFen()
    }

  //   $('blank').src = '/fen/' + $('#diagram_fen').value;
  $('#diagram_white').focus()
  })


