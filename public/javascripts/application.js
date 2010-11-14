// Place your application-specific JavaScript functions and classes here
// This file is automatically included by javascript_include_tag :defaults

//--------------------------------------
// Converts traditional notation to FEN
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Updates "fen" input field
// Depends from prototype.js
//
// Iļja Ketris (c) 2008
//


aBoard = []
arrayOfOnes = ['1','1','1','1','1','1','1','1']
eight = $(arrayOfOnes)

notationEnglish = 'KQRBSPkqrbsp'
notationFIDE    = 'KDTLSpKDTLSp'
nEngl = 'kqrbsp'
nFide = 'kdtlsp'

String.prototype.times = function(num)
    {return new Array( num + 1 ).join( this )}


//--------------------------------------
function clearBoard() {
  $('.pieceOnBoard').each (function(i,p) {$(p).remove()})
  aBoard = [];
  for(i=0;i<8;++i) {aBoard.push(arrayOfOnes.slice(0))}
} //*************************************
function initVars(){

  ; WORB = ''; PIECE = ''
  ; allPieces = ['wk','wq','wr','wb','ws','wp','bk','bq','br','bb','bs','bp']
  ; aPieces = new Object
  ; $.each(allPieces, function(i,p)
      { aPieces[p] = new Image
      ; aPieces[p].src = '/images/fig/' + p + '.gif'
      })
} //*************************************
function fenToInternal(){

  var i = 0
  clearBoard()
  var fen = $('#diagram_position').val()
  fen = fen.replace(/n/g, 's')
  fen = fen.replace(/N/g, 'S') // no Nightriders in FEN, only Knights

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
  $('.pieceOnBoard').each (function(i,p) {$(p).remove()});
  for (var i=0; i<8; ++i) 
    { for (var j=0; j<8; ++j) {
      p = aBoard[i][j]
      var coor = i * 10 + j
      if (p=='1') {continue}
      color = p>'a'?'b':'w'
      left = j * 25 + 1
      top = i * 25 + 1 
      im = $('<img>')
      im.attr('src', aPieces[color + p.toLowerCase()].src)
        .css('position','absolute')
        .css('top', top)
        .css('left', left)
        .addClass('pieceOnBoard')
        .coor = [i, j]
        .kind = color + p.toLowerCase()
      $('#divBlank').append(im)
      }
    }  

  ; var b = aBoard.join('').match(/[a-z]/g)
  ; var w = aBoard.join('').match(/[A-Z]/g)
  ; $('#pcount').html('(' + (w?w.length:'0') +' + '+ (b?b.length:'0')+')')

} //*************************************
function internalToFen(){

  $('#diagram_position').attr('value',
    aBoard.join('/').replace(/,/g,'').replace(/\d+/g,function(x){return x.length}))

} //*************************************
function internalToNotation(){

  var aWhite=[], aBlack=[]
  for(var i=0;i<8;++i) {
    for(var j=0;j<8;++j) {
      var piece = aBoard[i][j]
      if(piece=='1') return;
      (piece < 'a' ? aWhite : aBlack).push(
          notationFIDE.substr(notationEnglish.indexOf(piece),1) +
          String.fromCharCode(j+97) + (8-i).toString())
      }
    }

   ; $('#diagram_white').html = aWhite.sort(sortPieces).join(' ')
   ; $('#diagram_black').html = aBlack.sort(sortPieces).join(' ')
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
function updateTwin(e){

  var m = [], r = ''
  $('$twin').attr('value', '')
  $('$twn').attr('value', $(toLowerCase().split(/.\)|\.|\,/).each(function(tw) {
      if (tw.length < 3) return;
      switch (true)
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
      default: return
      }
      ; $('#twin').attr('value', $('#twin').attr('value') + ('Twin ' + r + "\n"))
   })
} //*************************************
function updateFen(e){

   ; if (e.keyCode < 32 || e.keyCode > 58) return false;

   ; notationToInternal()
   ; internalToDiagram()
   ; internalToFen()
   ; return true

} //*************************************
function updateFromFen(e){

   ; fenToInternal()
   ; internalToDiagram()
   ; internalToNotation()
   ; return true

} //*************************************
function sortPieces(a,b) {

   ; var pcs = 'KDTLSp'
   ; return pcs.indexOf(a.substr(0,1)) -
      pcs.indexOf(b.substr(0,1)) 
} //*************************************
function figClicked(e) {

  ; var id = this.identify()
  ; if (id=='eraser')
    { WORB = ''
    ; $('status').update('Click to erase a piece')
    } else
    { WORB = id.charAt(0)
    ; PIECE = id.charAt(1) 
    ; $('status').update('Click on board to put ' +
      '<b>' + (id.charAt(0) + PIECE).toUpperCase() + '</b>') 
    }
} //*************************************
function boardClicked(e) {

  ; var ele = e.findElement()
  ; var rank =  ((e.clientX - this.offsetLeft) / 25).floor()
  ; var file =  ((e.clientY - this.offsetTop ) / 25).floor()


//  ; $('status').update(rank.toString() +' '+ file.toString())
  ; $('status').update('BC: ' + this.id+'.'+this.className + '/' + ele.id+'.'+ ele.className)
//  ; $('status').update(file, rank)

  ; switch (true)
  { case ele.className == 'pieceOnBoard'
    : if (WORB.empty() || ele.kind == WORB + PIECE) 
      { aBoard[file][rank] = '1'
      ; ele.remove()
      } else
      { aBoard[ele.coor[0]][ele.coor[1]] = WORB == 'w' ? PIECE.toUpperCase() : PIECE
      ; ele.remove()
      }
    ; break
    ; if (file<0 || rank<0) return false
  ; case ele.className == 'noBorder' && ! WORB.empty()
    : aBoard[file][rank] = WORB == 'w' ? PIECE.toUpperCase() : PIECE
    ; break
  ; default
    : $('status').update('nothing selected')
  }
  ; internalToDiagram()
  ; internalToNotation()
  ; internalToFen()
  ; return false

} //*************************************
function boardPressed(e) {

   $('diagram_white').value =
   'S'+
   String.fromCharCode(97 + (e.clientX - e.element().offsetLeft) / 25) + 
   String(Math.floor((- e.clientY + e.element().offsetTop) / 25) + 9) 
   ;

   ; updateFen({keyCode: 50})
   ; updateFromFen()

} //*************************************
function moveBoard(d) { // move position left/up/down/up
  // ◁ ▽ △ ▷
  switch (d) {
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
  case 'CCW' :
    newBoard = []
    eight.each (function() {newBoard.push(arrayOfOnes.slice(0))})
    eight.each (function(i, x) {
      eight.each (function(j, y) {
        newBoard[7-j][i] = aBoard[i][j]
      })
    })
    aBoard = newBoard
    break
  case 'CW' :
    newBoard = []
    eight.each (function() {newBoard.push(arrayOfOnes.slice(0))})
    eight.each (function(i, x) {
      eight.each (function(j, y) {
        newBoard[j][7-i] = aBoard[i][j]
      })
    })
    aBoard = newBoard
    break
  ; case '↕'
      : aBoard.reverse()
      ; break
  }
  ; internalToDiagram()
  ; internalToNotation()
  ; internalToFen()
  ; return false

} //*************************************
function addFairyCondition() {
  ; $('showfairy').hide()
  ; $('fairy').show()
}
