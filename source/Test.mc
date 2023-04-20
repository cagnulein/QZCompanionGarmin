import Toybox.Test;

(:test)
function onShow() {
  var x = 1;
  var y = 1;
  // Prints an error to the console when x and y are equal
  Test.assertNotEqualMessage(x, y, "x and y are equal!");
}
