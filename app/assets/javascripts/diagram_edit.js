//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008-2011
//

google.setOnLoadCallback(function() {

  'use strict' // don't remove this line.  It's good for you.

  $('#solving').hide()  

  initVars()                             


  $('#change-view').click(function(e) {
    if(ik.solving_view = ! ik.solving_view) {
      $('#change-view').button({label: ' Change to data entry view '})
      $('#catalog').hide()
      $('#solving').show()
    } else {
      $('#change-view').button({label: ' Change to solving view '})
      $('#catalog').show()
      $('#solving').hide()
    }
  })
        


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
      , twin: $('#diagram_twin').val()
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

    ik.solving_view = false
    ik.board = []
    ik.arrayOfOnes = ['1','1','1','1','1','1','1','1']
    ik.eight = $(ik.arrayOfOnes)

    ik.e2f = {K:'K',Q:'D',R:'T',B:'L',N:'S',P:'p'}
    ik.f2e = {k:'k',d:'q',t:'r',l:'b',s:'n',p:'p'}
    ik.boobs = /^\[(.)(.+)\]/
    var allPieces =
      [ 'wk','wq','wr','wb','wn','wp'
      , 'bk','bq','br','bb','bn','bp'
      , 'xwk','xwq','xwr','xwb','xwn','xwp'
      , 'xbk','xbq','xbr','xbb','xbn','xbp']
      , aPieces = {}                                       
    ik.imgPieces = {}
    $.each(allPieces, function(i,p) {
      aPieces[p] = ik.fig_path + p + '.gif'
      ik.imgPieces[p] = $('<img>').attr('src', aPieces[p])
      })
  } //*************************************
  function fenToInternal(){
    
    var fen = $('#diagram_position').val().trim()

    fen = fen
      .replace(/\d+/g, function(x){return '1'.times(Number(x))})
      .replace(/\/(?=\/)/g, '/8')
      .replace(/[^\/]+/g, function(x){ return x.pad('1', 8) })
    /* transformations:
    ----------------------------
    3      —> 111
    ///    —> /8/8/
    /bK/   —> /bK111111/
    ----------------------------    */
    _.each(fen.split('/'), function(row, i) {
      ik.board[i] = row.split(/(?!\w*[\)|\]])/)
      })

  } //*************************************
  function notationToInternal(){

    var prefix, postfix, ifwhite, p, piece, file, rank, m
    clearBoard()
    $(['#diagram_white', '#diagram_black', '#white_c', '#black_c'])
      .each (function(i_color ,color) {
      $($(color).val().toLowerCase().split(/\W/)).each (function(j,p) {
         if (p.length < 2) return
         if (p.length == 2) p = 'p' + p // implicit pawn
         p = p.toLowerCase()
         m = p.match(/(..?)(..)$/)
         piece = m[1]
         file = m[2].charCodeAt(0)
         rank = m[2].charAt(1)
         if (file< 97 || file>104) return; // a — h
         if (rank<'1' || rank>'8') return;
         switch (true) {
         case i_color > 1 :
            prefix = '[x'
            postfix = ']'
            break
         default:
            prefix = postfix = ''
         }
         ifwhite = i_color % 2 == 0 ? function(x){return x.toUpperCase()} : idem
         ik.board[8 - rank][file - 97]
            = prefix
            + ifwhite( ik.f2e[piece] || '('+piece+')' )
            + postfix
        })
      })
  } //*************************************
  function internalToDiagram(){
    var p, im, x, dataid
      , top, left, oldPiece
      , color, pp, gf_cond = ''
    _(ik.board).each(function(row, i) {
      _(row).each(function(p, j) {
        oldPiece = $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]')
        if (oldPiece.data('id') == p) return 
        if (p == '1') return oldPiece.remove()

console.log(p, wb(p))        

        dataid = p
        pp = p.match(ik.boobs) // general fairy piece condition
        if(pp) {p = pp[2] ;  gf_cond= 'x' }
        else { gf_cond = '' }
        oldPiece.remove()
        if (pp = p.match(/\((.+)\)/)) {
          x = _(ik.pieces).find(function(x){ return x.code == pp[1].toUpperCase() })
          x = x ? wb(pp[1]) + x.glyph1 : 'magic'
          im = $('<img>').attr('src', ik.fig_path + x + '.gif')
          }
        else {
          im = ik.imgPieces[ gf_cond + wb(p) + p.toLowerCase() ].clone()
          }
        $('#divBlank').append(im)
        left = j * 25 + 1
        top = i * 25 + 1
        im.css(
            { 'position': 'absolute'
            , 'top': top + 'px'
            , 'left': left + 'px'
            })
          .attr('data-x', i)
          .attr('data-y', j)
          .data('id', dataid)
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
        })
      })
    var b = ik.board.join('').match(/[a-z]/g)
    var w = ik.board.join('').match(/[A-Z]/g)
    $('#pcount').html('(' + (w?w.length:'0') +' + '+ (b?b.length:'0')+')')

  } //*************************************
  function internalToFen(){

    var x
    x = _(ik.board).map(function(row) { return row.join('') })
        .join('/')
        .replace(/\d+/g,function(x){return x.length})

    $('#diagram_position').val(x)

  } //*************************************
  function internalToNotation(){
    var piece, pp, ham, f, fairy
      , fields = {diagram_white: [], diagram_black: [], white_c: [], black_c: []}
    _(ik.board).each(function(row, i) {
      _(row).each(function(piece, j) {
        pp = piece.match(ik.boobs)
        if(pp) { ham = true ; piece = pp[2] }
        else { ham = false }

        var white = function(x){ return x.match(/^\(?[A-Z]/) ? true : false }
        
        if (piece !== '1') {
          switch (true) {
          case !ham && white(piece) :
            f = 'diagram_white'; break
          case !ham && !white(piece) :
            f = 'diagram_black'; break
          case ham && white(piece) :
            f = 'white_c'; break
          case ham && !white(piece) :
            f = 'black_c'; break
            }

          piece = piece.toUpperCase()            
          fields[f].push(
            (ik.e2f[piece] || piece.replace(/\(|\)/g,'')) +
            String.fromCharCode(j+97) + (8-i).toString())
          }
        })
      })
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
    } //***************************************
  function wb(p) {
    return p < 'a' ? 'w' : 'b'
    } //***************************************
  })



