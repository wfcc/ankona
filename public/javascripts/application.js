$(function() {
  $('.button').button()
  })
// -------------------------------------------------------------------
function dynamicAddRemove(parent, parents, child, children) {
  alert('a.' + child + '-add');
  $('a.' + child + '-add').live('click', function() {
    var parentId = $(this).closest('.' + children).attr('id').replace(parent + '-', '');
    indexData = ''
    // check to see if there is a parent div; this will be the case if we're doing a
    // grandchild (or deeper) insert
    if ($(this).closest('div.' + parent).size() > 0) {
      var matcher = new RegExp (parents + '_attributes\\]\\[(\\d*)\\]');
      var parentIndex = $(this).closest('div.' + parent).find(':input').attr('name').match(matcher)[1];
      indexData = 'index=' + parentIndex;
      }
    $.get('/' + parents + '/' + parentId + '/' + children + '/new', indexData, function(data) {
      $(data).hide().appendTo($('div.' + children + '#' + parent + '-' + parentId + ' div#new-' + children)).fadeIn('slow');
    });
    return false;
    });
  $('a.' + child + '-remove').live('click', function() {
    var childId = $(this).closest('.' + child).attr('id');
    var parentId = $(this).closest('.' + children).attr('id').replace(parent + '-', '');
    $.post('/' + parents + '/' + parentId + '/' + children + '/' + childId, { _method: 'delete' }, function(data, textStatus) {
      var response = JSON.parse(data);
      if (response.success) {
        $('div.' + child + '#' + childId).fadeOut('slow', function() {
          $(this).remove();
          });
        }
      else {
        alert('The ' + child + ' could not be removed because ' + response.msg);
        }
      });
      return false;
    });
  }

