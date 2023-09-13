// Short shelf for annoying fridge drawer that takes on water

module grid(lenx=140, nx=8, leny=165, ny=4) {
  width = 3;
  height = 5;
  
  for (i = [0 : nx - 1]) {
    translate([(lenx - width) * i / (nx - 1), 0, 0])
      cube([width, leny, height]);
  }
  
  for (i = [0 : ny - 1]) {
    translate([0, width + (leny - width) * i / (ny - 1), 0])
      rotate([0, 0, -90])
        cube([width, lenx, height+3]);
  }
}

grid();