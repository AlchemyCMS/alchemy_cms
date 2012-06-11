String.prototype.beginsWith = function(t, i) {
  if (i == false) {
    return (t == this.substring(0, t.length));
  } else {
    return (t.toLowerCase() == this.substring(0, t.length).toLowerCase());
  }
};

String.prototype.endsWith = function(t, i) {
  if (i == false) {
    return (t == this.substring(this.length - t.length));
  } else {
    return (t.toLowerCase() == this.substring(this.length - t.length).toLowerCase());
  }
};
