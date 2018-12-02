//= require clipboard

$(function () {
  var clipboard = new Clipboard('.clb-copy-id-btn');
  clipboard.on('success', function(e) {
    e.clearSelection();
  });
});
