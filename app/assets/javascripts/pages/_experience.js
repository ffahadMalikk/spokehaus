$(function() {
  var $subSections = $('#experience .page-sub-section');

  var hideSiblingsContent = function(el) {
    $subSections.not(el).removeClass('show-content');
  };

  $subSections.click(function() {
    hideSiblingsContent(this);
    $(this).toggleClass('show-content');
  }).hover(function() {
    hideSiblingsContent(this);
    $(this).addClass('show-content');
  }, function() {
    $(this).removeClass('show-content');
  });

});
