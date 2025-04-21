// This script allows for collapsible items in summary page

document.addEventListener('DOMContentLoaded', function() {
  document.querySelectorAll('details').forEach(function(detail) {
    detail.addEventListener('toggle', function() {
      var summary = detail.querySelector('summary');
      if (detail.open) {
        summary.querySelector('.indicator').textContent = '▼';
      } else {
        summary.querySelector('.indicator').textContent = '▶';
      }
    });
  });
});