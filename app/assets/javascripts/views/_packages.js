$(function() {
  var $packagesLabels = $(".packages-list .package label");
  var $packagesRadios = $(".packages-list .package input[type='radio']");
  var $packagesModal = $("#packages-payment-modal");
  var $packagesErrors = $("#error_explanation");
  var $packagesSubtotal = $('#packages-payment-modal #price-breakdown .subtotal');
  var $packagesTax = $('#packages-payment-modal #price-breakdown .tax');
  var $packagesTotal = $('#packages-payment-modal #price-breakdown .total');
  var isAuthenticated = $packagesModal.data("is-authenticated");
  var $form = $("#new_purchase");

  if (!$packagesLabels.length) {return;}

  $packagesModal.modal({show: !!$packagesErrors.length});

  $packagesLabels.click(function() {
    if (isAuthenticated) {
      var subtotal = parseInt($(this).find('.package-price').data('subtotal'));
      var tax = subtotal * 0.13;
      var total = subtotal + tax;
      $packagesSubtotal.text('$' + subtotal.toFixed(2));
      $packagesTax.text('$' + tax.toFixed(2));
      $packagesTotal.text('$' + total.toFixed(2));
      $packagesModal.modal('show');
    } else {
      $form.submit();
    }
  });
});
