/*
* File:        jquery.execute-object.js
* Version:     1.0.0
* Author:      Iļja Ketris
* 
* Copyright 2012 Iļja Ketris
*
* This source file is free software, under either the GPL v2 license or a
* BSD style license, as supplied with this software.
* 
* This source file is distributed in the hope that it will be useful, but 
* WITHOUT ANY WARRANTY; without even the implied warranty of MERCHANTABILITY 
* or FITNESS FOR A PARTICULAR PURPOSE. 
*
* This file contains implementation of the jQuery function that
* executes jQuery methods on objects, retrieved in JSON compliant string or object.
*
*
* {"#my_id": ["addClass", "error"]}   $('#my_id').addClass("error")
*
* Logic-less:
*
* {"#my_input_field": "value"}          // $('#my_id').val("value")
* {"#my_checkbox": true}                // $('#my_id').prop("checked", true)
* {"#my_div": "my text"}                // $('#my_id').text("my text")
* {"#my_div": ["my text", ["addClass", "error"]]}  // multiple actions
*
*/
jQuery.extend({
  executeObject: function(data) {
    var matchCount = 0
    var isOnlyStrings = function (s) {
      if (typeof s == 'string') return true
      var filtered = $.grep(s, function(x){
        return typeof x == 'object'
      })
      return ! filtered.length
    }
    var callMethod = function (selector, array) {
      var method, args
      selector = $(selector)
      if (!selector.length) return
      if (!array) return
      if (!array.length) return
      method = array[0]
      args = array.slice(1)
      if (selector[method] instanceof Function) { // if callable
        selector[method].apply(selector, args)
        matchCount += 1
      }
    }

    if (!arguments.length) return
    try { if (typeof data == 'string') data = JSON.parse(data) }
    catch(e) { return 0 }

    for (selector in data) {
      var value = $.makeArray(data[selector])
      if (isOnlyStrings(value)) callMethod(selector, value)
      else $.each(value, function(i, y) {
        callMethod(selector, $.makeArray(y))
      })
    }
    return matchCount
  }
})
