//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008-2011
//

google.setOnLoadCallback(function() {

  'use strict' // don't remove this line.  It's good for you.
  
  initVars()                             

  $('#fen_button').click(function(e) {
    $('#fen-block').toggle()
    e.preventDefault()
  })
  $('#fairy_button').click(function(e) {
    $('#fairy-block').toggle()
    e.preventDefault()
  })

  $('#solve').click(function(e) {
    var form = $('form')
    $('#solve').val(' Solving... ')
    $.post('/diagrams/solve', 
      { stipulation: $('#diagram_stipulation').val()
      , position: $('#diagram_position').val()
      }, function(data) {
        $('#solution').html(data)
        $('#solve').val('Finished.  Solve again.')
        }
    )
    e.preventDefault()
  })

  $('#authors_ids').tokenInput('/authors/json',
    { hintText: "Start typing author's name or handle"
    , minChars: 3
    , prePopulate: $.parseJSON($('#authors_json').val())
    , theme: 'facebook'
    , onBeforeAdd: function(item){
      var matches
      if ( (isNaN(item.id)) && (matches = item.id.match(/^CREATE_(.+?)$/)) ) {
        item.name = matches[1]
        }
      }    
    })  

  $('#diagram_white').bind('keyup', updateFen)
  $('#diagram_black').bind('keyup', updateFen)
  $('#diagram_position').bind('keyup', updateFromFen)
  $('#white_c').bind('keyup', updateFen)
  $('#black_c').bind('keyup', updateFen)

  if (! $('#diagram_position').val()) {
    updateFen({keyCode: 50}) 
    } else {
    updateFromFen()
    }

  $('#diagram_white').focus()

  $('.todrag').draggable( // from cassettes, static pieces
    { revertDuration: 0
    , revert: true
    , cursor: 'crosshair'
    //, containment: $('#blank')
    , zIndex: 5
    })

  $('#blank').droppable(
    { drop: function(event, ui) {
      var board = $('#blank').offset()
        , piece = ui.draggable  
      
      ik.board
        [Math.floor((ui.offset.top - board.top + 12) / 25)]
        [Math.floor((ui.offset.left - board.left + 12) / 25)] = piece.data('id')
      if (piece.hasClass('pieceOnBoard')) { // remove
        ik.board[piece.data('x')][piece.data('y')] = '1'
        piece.remove()
        }
      fromInternal()
      }
    })
  

  $('.moveboard').button()
  $('.moveboard').click(function() { // move position left/up/down/up
    // ◁ ▽ △ ▷
    var newBoard
    switch ($(this).data('name')) {
    case '▷' :
        $.each(ik.board, function(i,row) {
          row.unshift('1')
          row.pop()
        })
        break
    case '◁' :
        $.each(ik.board, function(i,row)
          { row.shift()
          ; row.push('1')
        })
        ; break
    case '△' :
        ik.board.shift()
        ik.board.push(ik.arrayOfOnes)
        break
    case '▽' :
        ik.board.pop()
        ik.board.unshift(ik.arrayOfOnes)
        break
    case '↺' :
      newBoard = []
      ik.eight.each (function() {newBoard.push(ik.arrayOfOnes.slice(0))})
      ik.eight.each (function(i, x) {
        ik.eight.each (function(j, y) {
          newBoard[7-j][i] = ik.board[i][j]
        })
      })
      ik.board = newBoard
      break
    case '↻' :
      newBoard = []
      ik.eight.each (function() {newBoard.push(ik.arrayOfOnes.slice(0))})
      ik.eight.each (function(i, x) {
        ik.eight.each (function(j, y) {
          newBoard[j][7-i] = ik.board[i][j]
        })
      })
      ik.board = newBoard
      break
    case '↕' :
        ik.board.reverse()
        break
    }
    fromInternal()
    return false
  }) //*************************************
  function clearBoard() {

    for(var i=0;i<8;++i) { ik.board[i] = ik.arrayOfOnes.slice(0) }
  } //*************************************
  function initVars(){

    ik.board = []
    ik.arrayOfOnes = ['1','1','1','1','1','1','1','1']
    ik.eight = $(ik.arrayOfOnes)

    ik.notationFullEnglish = 'KQRBSPkqrbsp'
    ik.notationFullFIDE    = 'KDTLSpKDTLSp'
    ik.notationSmallEnglish = 'kqrbsp'
    ik.notationSmallFIDE = 'kdtlsp'
    ik.boobs = /^\[(.)(.+)\]/
    var allPieces =
      [ 'wk','wq','wr','wb','ws','wp'
      , 'bk','bq','br','bb','bs','bp'
      , 'xwk','xwq','xwr','xwb','xws','xwp'
      , 'xbk','xbq','xbr','xbb','xbs','xbp']
      , aPieces = {}                                       
    ik.imgPieces = {}
    $.each(allPieces, function(i,p) {
      aPieces[p] = $.globals.fig_path + p + '.gif'
      ik.imgPieces[p] = $('<img>').attr('src', aPieces[p])
      })
  } //*************************************
  function fenToInternal(){
    
    var gf = 0, fp = 0, res_row
      , acc = '', res = []
      , fen = $('#diagram_position').val()

    fen = fen.replace(/\d+/g, function(x){return '1'.times(Number(x))})    
    
    $.each(fen.split(''), function(i,c) {
       switch(c) {
         case '[' :
           acc = '['
           gf = 1
           break
         case '(' : 
           fp = 2
           acc = '('
           break 
         case ']' :
           res.push(acc + ']') ; acc = ''; gf = fp = 0
           break
         case ')' :
           acc += ')' ;  fp = 0
           break
         case '/' :
            res = res.concat('1'.times((8 - res.length % 8) % 8).split(''))
            break
         default :
           switch (gf + fp) {
           case 0 :
             if (acc.length) { res.push(acc) ; acc = '' }
             res.push(c.n2s())
             break
           default:
             acc += c
             }
           }
       })

    ik.eight.each(function(i,c) {
      res_row = res.slice(i*8, i*8+8)
      ik.board[i] = res_row
    })
    
  } //*************************************
  function notationToInternal(){

    var prefix, postfix, iswhite, p, piece, file, rank
    clearBoard()
    $(['#diagram_white', '#diagram_black', '#white_c', '#black_c'])
      .each (function(i_color ,color) {
      $($(color).val().toLowerCase().split(/\W/)).each (function(j,p) {
         if (p.length == 2) p = 'p' + p
         if (p.length != 3) return
         p = p.toLowerCase()
         piece = p.charAt(0)
         file = p.charCodeAt(1)
         rank = p.charAt(2)
         if (file< 97 || file>104) return; // a — h
         if (rank<'1' || rank>'8') return;
         if ('kdtlsp'.indexOf(piece) < 0) return;
         switch (true) {
         case i_color > 1 :
            prefix = '[x'
            postfix = ']'
            break
         default:
            prefix = postfix = ''
         }
         iswhite = i_color % 2 == 0 ? function(x){return x.toUpperCase()} : idem
         ik.board[8 - rank][file - 97]
            = prefix
            + iswhite( ik.notationSmallEnglish.charAt(ik.notationSmallFIDE.indexOf(piece)) )
            + postfix
        })
      })
  } //*************************************
  function internalToDiagram(){

    var p, im, oldPieces  =[]
      , top, left, oldPiece
      , color, pp, gf_cond = ''
    for (var i=0; i<8; ++i) {
      for (var j=0; j<8; ++j) {
        p = ik.board[i][j]
        if (p == '1') {
          $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]').remove()
          continue
          }
        else {    
          pp = p.match(ik.boobs) // general fairy piece condition
          if(pp) { p = pp[2] ;  gf_cond= 'x' }
          else { gf_cond = '' }
          color = p>'a'?'b':'w'
          left = j * 25 + 1
          top = i * 25 + 1
          p = p.n2s()
          oldPiece = $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]')
          if (oldPiece.data('id') == p) { continue }
          oldPiece.remove()
          im = ik.imgPieces[gf_cond + color + p.toLowerCase()].clone()
          $('#divBlank').append(im)
          im.css(
              { 'position': 'absolute'
              , 'top': top + 'px'
              , 'left': left + 'px'
            })
            .attr('data-x', i)
            .attr('data-y', j)
            .data('id', p)
            .addClass('pieceOnBoard ui-draggable')
            .draggable(
              { revert: false
              , zIndex: 5
              , stop: function(e,ui) { // remove off board
                var fig = $(this)
                ik.board[fig.data('x')][fig.data('y')] = '1'
                internalToNotation()
                internalToFen()
                fig.remove()
                }
              })
          }
        }
      }  
    var b = ik.board.join('').match(/[a-z]/g)
    var w = ik.board.join('').match(/[A-Z]/g)
    $('#pcount').html('(' + (w?w.length:'0') +' + '+ (b?b.length:'0')+')')

  } //*************************************
  function internalToFen(){
    $('#diagram_position')
      .val(ik.board
        .join('/')
        .replace(/,/g,'')
        .replace(/s/g,'n')
        .replace(/S/g,'N')
        .replace(/\d+/g,function(x){return x.length}))

  } //*************************************
  function internalToNotation(){
    var piece, pp, ham, f
      , fields = {diagram_white: [], diagram_black: [], white_c: [], black_c: []}
    for(var i=0;i<8;++i) {
      for(var j=0;j<8;++j) {
        piece = ik.board[i][j]
        pp = piece.match(ik.boobs)
        if(pp) { ham = true ; piece = pp[2] }
        else { ham = false }
        
        if (piece !== '1') {
          switch (true) {
          case !ham && piece.isWhite() :
            f = 'diagram_white'; break
          case !ham && !piece.isWhite() :
            f = 'diagram_black'; break
          case ham && piece.isWhite() :
            f = 'white_c'; break
          case ham && !piece.isWhite() :
            f = 'black_c'; break
            }
            
          fields[f].push(
            ik.notationFullFIDE.substr(ik.notationFullEnglish.indexOf(piece),1) +
            String.fromCharCode(j+97) + (8-i).toString())
          }
        }
      }
    for (var x in fields) {
      $('#' + x).val(fields[x].sort(sortPieces).join(' '))
      }
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
    var x
    if (x = a.match(ik.boobs)) { a = x[2] }
    if (x = b.match(ik.boobs)) { b = x[2] }
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
  //***************************************
  })


