import Toybox.Test;
import Toybox.Lang;

// Unit test to check if 2 + 2 == 4
(:test)
function myUnitTest(logger as Logger) as Boolean {
  var x = 2 + 2; logger.debug("x = " + x);
  return (x == 4); // returning true indicates pass, false indicates failure
}
