
$(document).ready(function()
  {
  $('#authors_ids').tokenInput('/authors/json',
    { hintText: "Start typing author's name or handle"
    , minChars: 3
    , prePopulate: $.parseJSON($('#authors_json').val())
    , classes:
      { tokenList: "token-input-list-facebook"
      , token: "token-input-token-facebook"
      , tokenDelete: "token-input-delete-token-facebook"
      , selectedToken: "token-input-selected-token-facebook"
      , highlightedToken: "token-input-highlighted-token-facebook"
      , dropdown: "token-input-dropdown-facebook"
      , dropdownItem: "token-input-dropdown-item-facebook"
      , dropdownItem2: "token-input-dropdown-item2-facebook"
      , selectedDropdownItem: "token-input-selected-dropdown-item-facebook"
      , inputToken: "token-input-input-token-facebook"
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


