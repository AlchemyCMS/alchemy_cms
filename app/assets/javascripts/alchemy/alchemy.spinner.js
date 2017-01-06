Alchemy.Spinner = function Spinner(size, styles) {
  var html = HandlebarsTemplates.spinner(),
      $spinner = $(html),
      $svg = $spinner.find('svg'),
      className;

  switch (size) {
    case 'small': className = 'spinner--small';
      break;
    case 'large': className = 'spinner--large';
      break;
    default: className = 'spinner--medium';
  }

  $spinner.addClass(className);

  if (styles) {
    $svg.find('path').css(styles);
  }

  this.el = $spinner;

  this.spin = function spin(parent) {
    if (parent === undefined) parent = 'body';
    $(parent).append($spinner);
    return this;
  };

  this.stop = function stop() {
    $spinner.remove();
  };
};
