$(document).ready(function() {
  var $jobs = $('#jobs').delegate('div.summary', 'click', showDetails).children('div.job');

  var read = localStorage.getItem('read');
  read = read == null ? [] : read.split('|');
  for(var i = 0; i < read.length; ++i) {
    var r = read[i];
    var found = $jobs.filter('[data-url="' + r +'"]');
    if (found.length == 0) {
      read.remove(i--);
    }else {
     found.children('.summary').addClass('read'); 
    }
  }
  
  var $active = null;
  function showDetails() {
    var $summary = $(this);
    var $parent = $summary.parent().addClass('active')
    
    if ($active != null) { 
      $active.children('.desc').hide(); 
      $active.removeClass('active');
      var $previous = $active;
      $active = null;
      if ($previous.attr('data-url') == $parent.attr('data-url')) { return; }
    }
    
    $active = $parent;
    var url = $parent.attr('data-url');
    $summary.addClass('read');
    $parent.children('.desc').toggle();
    
    if ($.inArray(url, read) == -1) {
      read.push(url)
      localStorage.setItem('read', read.join('|'));
    }
  }
  
  $(document).keydown(function(e) {
    var $item = null;
    if (e.keyCode == 40) {
      $item = $active == null ? $item = $jobs.first() : $jobs.eq($jobs.index($active)+1);
    }
    if (e.keyCode == 38) {
      if ($active == null) { $item = $jobs.last(); }
      else if ($jobs.index($active) > 0) { $item = $jobs.eq($jobs.index($active)-1); }
    }
    if ($item != null && $item.length> 0) {
      $item.children('.summary').click().get(0).scrollIntoView(); 
      return false;
    }
  });
});

Array.prototype.remove = function(from, to) {
  var rest = this.slice((to || from) + 1 || this.length);
  this.length = from < 0 ? this.length + from : from;
  return this.push.apply(this, rest);
};