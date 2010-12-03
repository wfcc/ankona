
function diagram_initialize()
  {
  $('#author_name_first').keyup(function()
    {
    alert($('#author_name_first').val())
    })
  $('#add_author').click(function()
    {
//    alert('bubu')
    $('#author_name_first').clone().appendTo('#authors')
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
  }


