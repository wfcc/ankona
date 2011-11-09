//= require jquery
//= require jquery_ujs
//= require jquery-tokeninput
//= require jquery-ui
//= require underscore
//= require_self
//= require fairy-pieces

google =
  { load: function(){} // dummy for now
  , setOnLoadCallback: jQuery
  }


google.load("jquery", "1.5.2")
google.load("jqueryui", "1.8.11")
;
//google.setOnLoadCallback(function() {
(function() {

  String.prototype.times = function(num) {return new Array( num + 1 ).join( this )}
  String.prototype.isWhite = function() {return this < 'a'}
  String.prototype.pad = function(padString, length)  {
  	var str = this
    while (str.length < length) str = str + padString
    return str
    }

  function arrays_equal(a,b) { return !(a<b || b<a) }
  
  idem = function(x) {return x}
  
  ik = {}
  ik.fig_path = '/assets/fig/'
  ik.figurines = 
    $('<img>').attr('src', '/assets/fig/figurines.gif')
    .appendTo('body')
    .hide()
  
  })(jQuery)
// -------------------------------------------------------------------
; $(document).ready(function() {
  $('.button').button()
  $('#lg_menu').click(function() {
    $('#lg_submenu').toggle()
    })            
  $('input[type!="hidden"]:first:visible:enabled').focus();

  })

