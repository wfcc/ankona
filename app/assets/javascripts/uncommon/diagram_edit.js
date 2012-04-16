//--------------------------------------
// Expects input fields with IDs "diagram_white" and "diagram_black" with English notation
// Depends upon jQuery
//
// Iļja Ketris (c) 2008-2012
//

//google.setOnLoadCallback(function() {
; $(document).ready(function() {

  'use strict' // don't remove this line.  It's good for you.

  initVars()                             
  ik.treeToBoard()
  ik.fromInternal()
  initHdb()

  $('#squared select').live('change', function(e) {
    //alert($(this).parent().data('kind'))
    var select = $(this)
    var selected = select.find('option:selected').val()
    _(select.parent().next().next().children()).each(function(s){
      $(s).attr('disabled', selected == '')
      $(s).attr('name',
        'diagram[pieces][' + selected + '][' + $(s).data('color') + ']'
          ).attr('id',
        'diagram_pieces_' + selected + '_' + $(s).data('color')
          )
      })
    if (! $('#squared option[value=""]:selected').length) {
      ik.blankTr.clone(true).appendTo($('#squared')).find('select').removeAttr('disabled')
      }
    })

  $('a.show_version').live('click', function(e) {
    alert($(this).data('fef'))
  })

  $('#fen_button').click(function(e) {
    $('#fen-block').toggle()
    e.preventDefault()
  })
  $('#fairy_button').click(function(e) {
    $('#fairy-block').toggle()
    e.preventDefault()
  })

  var solve = function(f) {

    var form = $('form')
    if(f) $('#solve').val(' Solving... ')
    $.post('/diagrams/solve', 
      { stipulation: $('#diagram_stipulation').val()
      , position: $('#diagram_position').val()
      , pieces: form.toJSON().diagram.pieces
      , twin: $('#diagram_twin').val()
      , pyopts: $('#pyopts').val()
      , conds: $('#diagram_fairy').val()
      , solve: f
      }, function(data) {
        $('#solution').html(data)
        if(f) $('#solve').val('Finished.  Solve again.')
        }
    )
    }

  $('#solve').click(function(e){ solve(true); e.preventDefault()})
  $('#showpopeye').click(function(e) { solve(false); e.preventDefault()})

  $('#saveversion').click(function(e){
    var id = $('#diagram_id').val()
    $('#saveversion').attr('disabled', 'disabled')
    $.post('/diagrams/' + id + '/versions',
      { description: $('#verdes').val()
      , pieces: $('form').toJSON().diagram.pieces
      }, function(data){
        $('#versions_table').html(data)
        $('#verdes').val('')
        $('#saveversion').removeAttr('disabled')
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

  $('#pieceinputs input[type=text]:not(#diagram_position)').live('keyup blur', fromNotation)
  $('#diagram_position').bind('keyup', fromFen)

  $('#diagram_white').focus()

  $('.todrag').draggable( // from cassettes, static pieces
    { revertDuration: 0
    , revert: true
    , cursor: 'crosshair'
    //, containment: $('#blank')
    , zIndex: 5
    })

  // p class="sprite-#{color}#{figurine} todrag" data-id=figurine data-color=color data-kind='a'
  $('#blank').droppable(
    { drop: function(event, ui) {
      var board = $('#blank').offset()
        , piece = ui.draggable  
      ik.board
        [Math.floor((ui.offset.top - board.top + 12) / 25)]
        [Math.floor((ui.offset.left - board.left + 12) / 25)] =
          { p: piece.data('id')
          , k: piece.data('kind')
          , c: piece.data('color')
          , u: piece.data('u') || Math.random()
          }
      if (piece.hasClass('pieceOnBoard')) { // remove
        ik.board[piece.data('x')][piece.data('y')] = undefined
        piece.remove()
        }
      ik.fromInternal()
      }
    })
  
  //$('.moveboard').button()
  $('.moveboard').click(function() { // move position left/up/down/up
    // ◁ ▽ △ ▷
    var newBoard, rotate
    newBoard = [[],[],[],[],[],[],[],[]]
    switch ($(this).text()) {
    case '▷' :
        _.each(ik.board, function(row) {
          row.unshift(undefined)
          if(row.length > 8) row.pop()
          })
        break
    case '◁' :
        _.each(ik.board, function(row) { 
          row.shift()
          row.push(undefined)
          })
        break
    case '△' :
        ik.board.shift()
        ik.board.push([])
        break
    case '▽' :
        ik.board.pop()
        ik.board.unshift([])
        break
    case '↺' :
      rotate = function(i,j,pcs){ newBoard[7-j][i] = pcs }
    case '↻' :
      rotate = rotate || function(i,j,pcs){ newBoard[j][7-i] = pcs }
      _(ik.board).each(function(row, i){
        _(row).each(function(pcs, j){
          rotate(i,j,pcs)
          })
        })
      ik.board = newBoard
      break
    case '↕' :
        ik.board.reverse()
        break
    }
    ik.fromInternal()
    return false

  }) //*************************************
  function initHdb(){

    var diagram_id = $('#diagram_id').val()
    ik.verTemplate = Handlebars.compile($('#versions-template').html())

    $.getJSON('/diagrams/' + diagram_id + '/versions', function(data){
      var hbdata = { versions: data }
      $('#versions-body').html(ik.verTemplate(hbdata))
      })


    } //*************************************
  function initVars(){

    ik.fenish = {k:'k',d:'q',t:'r',l:'b',s:'n',p:'p','1':'1'}
    ik.solving_view = false
    ik.board = []
    ik.form = $('form.simple_form')
    ik.tree = ik.form.toJSON()
    ik.onex8 = '11111111'
    ik.blankTr = $('tr[data-id=NEW]').clone(true)
    //ik.figurines = $('<p>').css('background-image', 'url(' + ik.fig_path + 'figurines.gif' + ')')

    ik.boobs = /^\[(.)(.+)\]/
    ik.fromInternal = function fromInternal() {
      boardToDiagram()
      boardToNotation()
      boardToFen()
      } //***************************************
    ik.treeToBoard = function treeToBoard() {
      var m, file, rank
      ik.board = [[],[],[],[],[],[],[],[]]
      _(ik.tree.diagram.pieces).each(function(data, kind) {
        _(data).each(function(pcs, color){
          _(pcs.split(' ')).each(function(piece){
            piece = piece.toLowerCase()
            //if (piece.length === 0) return
            //if (piece.length === 2) piece = 'p' + piece // add pawn
            m = piece.match(/^(..?)(..)$/)
            if (!m) return ''
            file = m[2].charCodeAt(0)
            rank = m[2].charAt(1)
            if (isNaN(rank) || rank-0 > 8 || rank-0 < 1) return ''
            if (file > 122 || file < 97) return ''
            ik.board[8-rank][file-97] =
              { k: kind
              , c: color
              , p: m[1].toUpperCase()
              , u: Math.random()
              }
            })
          })
        })
      } //***************************************

    } //*************************************
  function e2f(piece){
    var x = {K:'K',Q:'D',R:'T',B:'L',N:'S',P:'p'}[piece.toUpperCase()]
    if (!x) return undefined
    return x.toLowerCase()

  } //*************************************
  function fenToBoard(){
    
    ik.board = [[],[],[],[],[],[],[],[]]
    var fen = $('#diagram_position').val().trim(), p, color

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
      _.each(row.split(''), function(piece, j) {
        var p = e2f(piece)
        if (!p) return // '1' included
        else {
          ik.board[i][j] =
            { k: 'a'
            , c: piece < 'a' ? 'w' : 'b'
            , p: e2f(piece).toUpperCase()
            , u: Math.random()
            }
          }
      })
    })

  } //*************************************
  function notationToTree(){ // new
    ik.tree = ik.form.toJSON()
  } //*************************************
  function boardToDiagram(){
    var p, im, x, top, left, oldPiece, color, squared
    _(ik.board).each(function(row, i) {
      _.each(_.range(8), function(p, j) {
        oldPiece = $('.pieceOnBoard[data-x="' + i + '"][data-y="' + j + '"]')
        p = row[j]
        if (p) {
          if (oldPiece.data('u') == p['u'] && p['u']) return
          } else { return oldPiece.remove() }
        squared = p.k && p.k != 'a' ? 'x' : ''
        color   = p.c
        oldPiece.remove()
        x = _(ik.pieces).find(function(x){ return x.code == p.p.toUpperCase() })
        x = x ? x.glyph1 : f2easy(p.p)
        x = squared + color + x
        im = $('<p>') //ik.figurines.clone()
        im.addClass('sprite-' + x)
        left = j * 25 + 1
        top = i * 25 + 1
        im.css(
            { 'position': 'absolute'
            , 'top': top + 'px'
            , 'left': left + 'px'
            })
          .attr('data-x', i)
          .attr('data-y', j)
          .data('id', p.p)
          .data('kind', p.k)
          .data('color', p.c)
          .data('u', p['u'] || Math.random())
          .addClass('pieceOnBoard')
          .draggable(
            { revert: false
            , zIndex: 5
            , stop: function(e,ui) { // remove off board
              var fig = $(this)
              ik.board[fig.data('x')][fig.data('y')] = undefined
              boardToNotation()
              boardToFen()
              fig.remove()
              }
            })
        $('#divBlank').append(im)
        })
      })
    var b = ik.board.join('').match(/[a-z]/g)
    var w = ik.board.join('').match(/[A-Z]/g)
    // $('#pcount').html('(' + (w?w.length:'0') +' + '+ (b?b.length:'0')+')')

  } //*************************************
  function boardToFen(){ // new

    var abort = false, p
    var x = _(ik.board).map(function(row) { 
      var r = ik.onex8
      _(row).each(function(pcs, pos) {
        if (pcs) {
          p = fenize(pcs)
          abort = 
            abort ||
            pcs.k != 'a' ||
            pcs.c == 'n' ||
            pcs.p.length != 1 || !p
          if (abort) return
          r = r.replaceAt(pos, p)
          }
        })
      return r
      })
      .join('/')
      .replace(/\d+/g,function(x){return x.length})

    $('#diagram_position').val(abort ? '' : x)

  } //*************************************

  function boardToNotation(){ // new

    var field = {}, index
    _(ik.board).each(function(row, i) {
      _(row).each(function(piece, j) {
        if (!piece) return
        index = piece.k + '_' + piece.c
        piece = piece.p
        field[index] = field[index] ? field[index] : []
        field[index].push(piece.pawnDown() + String.fromCharCode(j+97) + (8-i).toString())
        })
      })
    $('input[id^=diagram_pieces_]').val('')
    _.each(field, function(value, key){
      $('#diagram_pieces_' + key).val(value.sort(sortPieces).join(' '))
      })

    return

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
  function fromNotation(e){
    if (e.keyCode > 32 && e.keyCode < 91 || e.keyCode == 8 || e.type == 'focusout') {
      notationToTree()
      ik.treeToBoard()
      boardToDiagram()
      boardToFen()
      }
    if (e.type == 'focusout') { boardToNotation() }
    return true
  } //*************************************
  function fromFen(e){
    if (e.keyCode > 45 && e.keyCode < 91 || e.keyCode == 8 ) {
      fenToBoard()
      boardToDiagram()
      boardToNotation()
      return true
      } else { return false }
    } //*************************************
  function sortPieces(a,b) {
    var x
    if (x = a.match(ik.boobs)) { a = x[2] }
    if (x = b.match(ik.boobs)) { b = x[2] }
    var pcs = 'KDTLSp'
    return pcs.indexOf(a.substr(0,1)) -
        pcs.indexOf(b.substr(0,1)) 
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
  function wb(p) {
    if (!p) return undefined
    return p < 'a' ? 'w' : 'b'
    } //***************************************
  function f2easy(piece) {
    var r = ik.fenish[piece.toLowerCase()]
    return r || 'magic'
    } //***************************************
  function fenize(piece) {
    if (!piece) return
    var p = ik.fenish[piece.p.toLowerCase()]
    if (!p) return
    return piece.c.toLowerCase() === 'w'
      ? p.toUpperCase()
      : p.toLowerCase()
    } //***************************************

  }) // EOF
