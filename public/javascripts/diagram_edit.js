//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008-2011
//

google.setOnLoadCallback(function() {
  
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

  aBoard = []
  arrayOfOnes = ['1','1','1','1','1','1','1','1']
  eight = $(arrayOfOnes)

  notationEnglish = 'KQRBSPkqrbsp'
  notationFIDE    = 'KDTLSpKDTLSp'
  nEngl = 'kqrbsp'
  nFide = 'kdtlsp'
  
  $('#diagram_white').bind('keyup', updateFen)
  $('#diagram_black').bind('keyup', updateFen)
  $('#diagram_position').bind('keyup', updateFromFen)
  $('#white_c').bind('keyup', updateFen)
  $('#black_c').bind('keyup', updateFen)

  initVars()                             
  
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
      var piece = ui.draggable  
      
      aBoard
        [Math.floor((ui.offset.top - board.top + 12) / 25)]
        [Math.floor((ui.offset.left - board.left + 12) / 25)] = piece.data('id')
      if (piece.hasClass('pieceOnBoard')) { // remove
        aBoard[piece.data('x')][piece.data('y')] = '1'
        piece.remove()
        }
      fromInternal()
      }
    })
  

  $('.moveboard').button()
  $('.moveboard').click(function() { // move position left/up/down/up
    // ◁ ▽ △ ▷
    switch ($(this).data('name')) {
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

    aBoard = [];
    for(i=0;i<8;++i) {aBoard.push(arrayOfOnes.slice(0))}
  } //*************************************
  function initVars(){

    boobs = /^\[(.)(.+)\]/
    allPieces =
      [ 'wk','wq','wr','wb','ws','wp'
      , 'bk','bq','br','bb','bs','bp'
      , 'xwk','xwq','xwr','xwb','xws','xwp'
      , 'xbk','xbq','xbr','xbb','xbs','xbp']
    aPieces = {}                                       
    imgPieces = {}
    $.each(allPieces, function(i,p) {
      aPieces[p] = '/images/fig/' + p + '.gif'
      imgPieces[p] = $('<img>').attr('src', aPieces[p])
      })
  } //*************************************
  function fenToInternal(){
    
    var gf = fp = 0, acc = '', res = []
    var fen = $('#diagram_position').val()
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
             res.push(c)
             break
           default:
             acc += c
             }
           }
       })
       eight.each(function(i,c) {
         aBoard[i] = res.slice(i*8, i*8+8)
         })
    
  } //*************************************
  function notationToInternal(){

    var prefix, postfix, iswhite
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
         aBoard[8 - rank][file - 97]
            = prefix
            + iswhite( nEngl.charAt(nFide.indexOf(piece)) )
            + postfix
        })
      })
  } //*************************************
  function internalToDiagram(){

    var p, im, top, left, color, pp
    var gf_conf = ''
    for (var i=0; i<8; ++i) {
      for (var j=0; j<8; ++j) {
        p = aBoard[i][j]
        if (p == '1') {
          $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]').remove()
          continue
          }
        else {    
          pp = p.match(boobs) // general fairy piece condition
          if(pp) { p = pp[2] ;  gf_cond= 'x' }
          else { gf_cond = '' }
          color = p>'a'?'b':'w'
          left = j * 25 + 1
          top = i * 25 + 1
          if(p=='n') {p='s'}
          if(p=='N') {p='S'}
          im = imgPieces[gf_cond + color + p.toLowerCase()].clone()
          $('#divBlank').append(im)
          $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]').remove()
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
        .replace(/s/g,'n')
        .replace(/S/g,'N')
        .replace(/\d+/g,function(x){return x.length}))

  } //*************************************
  function internalToNotation(){
    var piece, pp, ham, f
    var fields = {diagram_white: [], diagram_black: [], white_c: [], black_c: []}
    for(var i=0;i<8;++i) {
      for(var j=0;j<8;++j) {
        piece = aBoard[i][j]
        pp = piece.match(boobs)
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
            notationFIDE.substr(notationEnglish.indexOf(piece),1) +
            String.fromCharCode(j+97) + (8-i).toString())
          }
        }
      }
    for (x in fields) {
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
    if (x = a.match(boobs)) { a = x[2] }
    if (x = b.match(boobs)) { b = x[2] }
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


