//= require jquery
//= require jquery_ujs
//= require jquery.smartresize
//= require fastclick
//= require bootstrap
//= require bootstrap-carousel-swipe
//= require_self
//= require_tree .
//= require_tree ./components
//= require_tree ./pages
//= require_tree ./views
/* global FastClick */

$(function() {
  FastClick.attach(document.body);

  // Forms
  // Mark all labels of focused inputs
  $('input, select, textarea', $('form'))
    .hover(
      function() {
        $(this).siblings('label').addClass('field-hover');
      },
      function() {
        $(this).siblings('label').removeClass('field-hover');
      }
    )
    .focusin(function() {
      $(this).siblings('label').addClass('field-focus');
    })
    .focusout(function() {
      $(this).siblings('label').removeClass('field-focus');
    });
});



$(document).ready(function () {
    var CurrentUrl= document.URL;
    var CurrentUrlEnd = CurrentUrl.split('/').filter(Boolean).pop();

    $( ".main-menu li a" ).each(function() {
        var ThisUrl = $(this).attr('href');
        var ThisUrlEnd = ThisUrl.split('/').filter(Boolean).pop();
        if(ThisUrlEnd == CurrentUrlEnd) {
            $(".main-menu li").each(function(){
                $(this).removeClass("active");
            });
            $(this).closest('li').addClass('active')
        }
    });
});
