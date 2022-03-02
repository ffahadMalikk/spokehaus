$(function() {
  var $viewport = $('#viewport');
  var $mainFooter = $('#main-footer');

  // Add sections which require a full-height viewport here
  var $fullHeightSections = $('#home, #instructors-show');

  // Rsizing function
  var resizeViewport = function() {
    if ($fullHeightSections.length) {
      $fullHeightSections.css('min-height', $(window).height() - parseInt($viewport.css('marginTop')));
    }

    $viewport.add($mainFooter).addClass('ready');
  };

  // Trigger resizing function every time the window is resized
  $(window).smartResize(resizeViewport);

  // Trigger resizing function once on load
  resizeViewport();
});
