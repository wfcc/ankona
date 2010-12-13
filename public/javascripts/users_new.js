
$(document).ready(function()
  {
  $('.hideable').hide()
  $('#user_name').tokenInput('/authors/json?handle=1',
    { hintText: "Start typing your LAST NAME"
    , minChars: 3
    , prePopulate: []
    , tokenLimit: 1
    , onSelect: function (selected){
        console.log(selected)
        $('#handle').html(selected.id)
        $('#name').html(selected.name)
        $('.hideable').show()
        
        return true
        }
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
  })


