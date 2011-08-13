
google.load("jquery", "1.5.2")
google.load("jqueryui", "1.8.11")

google.setOnLoadCallback(function() {

  String.prototype.times = function(num) {return new Array( num + 1 ).join( this )}
  Array.prototype.last = Array.prototype.last || function() {
      var l = this.length;
      return this[l-1];
  }                          
  String.prototype.isWhite = function() {return this < 'a'}
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

