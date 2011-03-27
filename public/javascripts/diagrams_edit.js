//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008
//

$(function() {
  $('#authors_ids').tokenInput('/authors/json',
    { hintText: "Start typing author's name or handle"
    , minChars: 3
    , inputBoxName: 'newname'
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

  aBoard = []
  arrayOfOnes = ['1','1','1','1','1','1','1','1']
  eight = $(arrayOfOnes)

  notationEnglish = 'KQRBSPkqrbsp'
  notationFIDE    = 'KDTLSpKDTLSp'
  nEngl = 'kqrbsp'
  nFide = 'kdtlsp'

  String.prototype.times = function(num) {return new Array( num + 1 ).join( this )}

  $('#diagram_white').bind('keyup', updateFen)
  $('#diagram_black').bind('keyup', updateFen)
  $('#diagram_position').bind('keyup', updateFromFen)

  initVars()                             
  
  if (! $('#diagram_position').val()) {
    updateFen({keyCode: 50}) 
    } else {
    updateFromFen()
    }

  $('#diagram_white').focus()

  $('.todrag').draggable(
    { revertDuration: 0
    , revert: true
    , cursor: 'crosshair'
    //, containment: $('#blank')
    , zIndex: 5
    })
  $('#blank').droppable(
    { drop: function(event, ui) {
      board = $('#blank').offset()
      aBoard[Math.floor((ui.offset.top - board.top + 12) / 25)]
        [Math.floor((ui.offset.left - board.left + 12) / 25)] = ui.helper.data('id')
      if (ui.helper.data('inner')) { // remove
        aBoard[ui.helper.data('x')][ui.helper.data('y')] = '1'
        }
      fromInternal()
      }
    })
  

  $('.moveboard').button()
  $('.moveboard').click(function() { // move position left/up/down/up
    // ◁ ▽ △ ▷
    switch (this.getAttribute('data-name')) {
    case '▷' :
        $.each(aBoard, function(i,row) {
          row.unshift('1')
          row.pop()
        })
        break
    case '◁' :
        $.each(aBoard, function(i,row)
          { row.shift()
          ; row.push('1')
        })
        ; break
    case '△' :
        aBoard.shift()
        aBoard.push(arrayOfOnes)
        break
    case '▽' :
        aBoard.pop()
        aBoard.unshift(arrayOfOnes)
        break
    case '↺' :
      newBoard = []
      eight.each (function() {newBoard.push(arrayOfOnes.slice(0))})
      eight.each (function(i, x) {
        eight.each (function(j, y) {
          newBoard[7-j][i] = aBoard[i][j]
        })
      })
      aBoard = newBoard
      break
    case '↻' :
      newBoard = []
      eight.each (function() {newBoard.push(arrayOfOnes.slice(0))})
      eight.each (function(i, x) {
        eight.each (function(j, y) {
          newBoard[j][7-i] = aBoard[i][j]
        })
      })
      aBoard = newBoard
      break
    case '↕' :
        aBoard.reverse()
        break
    }
    fromInternal()
    return false
  }) //*************************************
  function clearBoard() {

    //$('.pieceOnBoard').remove()
    aBoard = [];
    for(i=0;i<8;++i) {aBoard.push(arrayOfOnes.slice(0))}
  } //*************************************
  function initVars(){

    allPieces = ['wk','wq','wr','wb','ws','wp','bk','bq','br','bb','bs','bp']
    aPieces = {}                                       
    imgPieces = {}
    $.each(allPieces, function(i,p) {
      aPieces[p] = '/images/fig/' + p + '.gif'
      imgPieces[p] = $('<img>').attr('src', aPieces[p])
      })
  } //*************************************
  function fenToInternal(){

    var i = 0
    clearBoard()
    var fen = $('#diagram_position').val()
      .replace(/n/g, 's')
      .replace(/N/g, 'S') // no Nightriders in FEN, only Knights

    if (fen.match('/')) {
      fen = fen.replace(/\d+/g, function(x){return '1'.times(Number(x))})
      fen = fen.replace(/[^kqrbspn\/1]/ig, '1') // strip wrong FEN characters
      var a1 = fen.split('/')
      $(a1).each (function(i, row) {
          row += '1'.times(8 - row.length)
          aBoard[i++] = row.split('')
          })
    } else {
      fen = fen.replace(/\d/g, function(x){return '1'.times(Number(x))})
      fen = fen.replace(/[^kqrbspn\/1]/ig, '1') // strip wrong FEN characters
      fen += '1'.times(64 - fen.length)
      for (var i=0; i<8; i++) {
        aBoard[i] = fen.slice(i*8,i*8+8).split('')
        }
      }

  } //*************************************
  function notationToInternal(){

    clearBoard()
    $(['#diagram_white', '#diagram_black']).each (function(i_color ,color) {
      $($(color).val().toLowerCase().split(/\W/)).each (function(j,p) {
         if (p.length == 2) p = 'p' + p
         if (p.length != 3) return
         p = p.toLowerCase()
         piece = p.charAt(0)
         file = p.charCodeAt(1)
         rank = p.charAt(2)
         //; alert(file)
         if (file< 97 || file>104) return; // a — h
         if (rank<'1' || rank>'8') return;
         if ('kdtlsp'.indexOf(piece) < 0) return;
         aBoard[8 - rank][file - 97]
            = i_color == 0
            ? nEngl.charAt(nFide.indexOf(piece)).toUpperCase()
            : nEngl.charAt(nFide.indexOf(piece))
        })
      })
  } //*************************************
  function internalToDiagram(){

    var p, im, top, left, color
//    $('.pieceOnBoard').remove()
    for (var i=0; i<8; ++i) {
      for (var j=0; j<8; ++j) {
        p = aBoard[i][j]
        if (p == '1') {
          $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]').remove()
          continue
          }
        else {
          color = p>'a'?'b':'w'
          left = j * 25 + 1
          top = i * 25 + 1 
          im = imgPieces[color + p.toLowerCase()].clone()
          $('#divBlank').append(im)
          $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]').remove()
          im.css(
              { 'position': 'absolute'
              , 'top': top + 'px'
              , 'left': left + 'px'
            })
            .attr('data-x', i)
            .attr('data-y', j)
            .attr('data-id', p)
            .attr('data-inner', 1)
            .addClass('pieceOnBoard ui-draggable')
            .draggable(
              { revert: false
              , zIndex: 5
              , stop: function(e,ui) {
                var fig = $(this)
                aBoard[fig.data('x')][fig.data('y')] = '1'
                internalToNotation()
                internalToFen()
                fig.remove()
                }
              })
           }
        }
      }  

    var b = aBoard.join('').match(/[a-z]/g)
    var w = aBoard.join('').match(/[A-Z]/g)
    $('#pcount').html('(' + (w?w.length:'0') +' + '+ (b?b.length:'0')+')')

  } //*************************************
  function internalToFen(){
    $('#diagram_position')
      .val(aBoard
        .join('/')
        .replace(/,/g,'')
        .replace(/\d+/g,function(x){return x.length}))

  } //*************************************
  function internalToNotation(){
    var aWhite=[], aBlack=[]
    for(var i=0;i<8;++i) {
      for(var j=0;j<8;++j) {
        var piece = aBoard[i][j]
        if (piece !== '1') {
          (piece < 'a' ? aWhite : aBlack).push(
            notationFIDE.substr(notationEnglish.indexOf(piece),1) +
            String.fromCharCode(j+97) + (8-i).toString())
          }
        }
      }
     $('#diagram_white').val(aWhite.sort(sortPieces).join(' '))
     $('#diagram_black').val(aBlack.sort(sortPieces).join(' '))
  } //*************************************
  function validateForm(){
     ; if ($('diagram_stipulation').value.length < 2)
        { new Effect.Highlight('diagram_stipulation', {startcolor:'ffffee',
           transition:Effect.Transitions.linear, duration:2})
        ; new Effect.Pulsate('diagram_stipulation', {duration:2})
        ; $('diagram_stipulation').focus()
        ; return false
     }
     ; return true
  } //*************************************
  function updateFen(e){
     if (e.keyCode < 32 || e.keyCode > 58) return false;
     notationToInternal()
     internalToDiagram()
     internalToFen()
     return true
  } //*************************************
  function updateFromFen(e){
     fenToInternal()
     internalToDiagram()
     internalToNotation()
     return true
  } //*************************************
  function sortPieces(a,b) {
     var pcs = 'KDTLSp'
     return pcs.indexOf(a.substr(0,1)) -
        pcs.indexOf(b.substr(0,1)) 
  } //*************************************
  function addFairyCondition() {
    $('#showfairy').hide()
    $('#fairy').show()
  } //*************************************
  function updateTwin(e){

    var m = [], r = ''
    $('#twin').val('')
    $('#twn').val(toLowerCase().split(/.\)|\.|\,/).each(function(i, tw) {
      if (tw.length < 3) return;
      switch (true) {
      case m = tw.match(/(\w\w)-?>(\w\w)/), m!=null :
         r='Move ' + m[1] + ' ' + m[2]
         break
      case m = tw.match(/\+(\w)(\w)(\w\w)/), m!=null :
         r='Add '+ (m[1]=='w'?'White ':'Black ') + m[2]+m[3]
         break
      case m = tw.match(/\-(\w)(\w)(\w\w)/), m!=null :
         r='Remove '+ (m[1]=='w'?'White ':'Black ') + m[2]+m[3]
         break
      case m = tw.match(/\w*(\w\w)<.*>\w*(\w\w)/), m!=null :
         r='Exchange '+ m[1] + ' ' + m[2]
         break
      default: return;
      }
      $('#twin').attr('value', $('#twin').attr('value') + ('Twin ' + r + "\n"))
     }))
  } //*************************************
  function fromInternal() {
    internalToDiagram()
    internalToNotation()
    internalToFen()
    }
  })


