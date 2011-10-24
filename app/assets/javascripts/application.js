//= require jquery
//= require jquery_ujs
//= require jquery-tokeninput
//= require jquery-ui
//= require_self


$.globals =
  { fig_path: '/assets/fig/'
  }

google =
  { load: function(){}
  , setOnLoadCallback: jQuery
  }


google.load("jquery", "1.5.2")
google.load("jqueryui", "1.8.11")

google.setOnLoadCallback(function() {

  String.prototype.times = function(num) {return new Array( num + 1 ).join( this )}
  Array.prototype.last = Array.prototype.last || function() {
    var l = this.length;
    return this[l-1];
    }                          
  String.prototype.isWhite = function() {return this < 'a'}
  
  String.prototype.n2s = function() {
    if (this == 'n') return 's'
    if (this == 'N') return 'S'
    return this + ''
    }

  function arrays_equal(a,b) { return !(a<b || b<a) }
  
  
  idem = function(x) {return x}
  
  $('.button').button()

  $('#lg_menu').click(function() {
    $('#lg_submenu').toggle()
    })            
    
  //$("input:visible:enabled:first").focus();
  $('input[type!="hidden"]:first:visible:enabled').focus();
  
  
  })
// -------------------------------------------------------------------

