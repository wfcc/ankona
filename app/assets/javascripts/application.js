//= require jquery
//= require jquery_ujs
//= require jquery-tokeninput
//= require jquery-ui
//= require jquery_tablesorter
//= require jquery.to_json
//= require underscore
//= require settings
//= require_self

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
  String.prototype.replaceAt=function(index, char) {
    return this.substr(0, index) + char + this.substr(index+char.length);
    }
  String.prototype.pawnDown=function() {
    if (this.toLowerCase() === 'p') return 'p'
    return this.toUpperCase()
    }

  function arrays_equal(a,b) { return !(a<b || b<a) }
  
  idem = function(x) {return x}
  
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
  $('input[type="text"]:first:visible:enabled').focus();
  
  })
/*
  jQuery.fn.extend({ val: function (newValue) {
    if (newValue == null) {
      if ($(this).hasClass("placeholder")) {
        var pText = $(this).attr("placeholder");
        var val = $(this).attr("value");
        if (pText) {
          if (pText == val) {
            return '';
            }
          }
        }
        return $(this).val(); }
      else {
        $(this).val(newValue);
        }
      }
    })
*/