t=20; // thickness of the panels

module front(width, height) {
  // main wall with "v" cutouts
  difference() {
    cube([width, t, height]);
    translate([-1, -t/10,   height/3]) rotate([45, 0, 0]) cube([width+2, t, t]);
    translate([-1, -t/10, 2*height/3]) rotate([45, 0, 0]) cube([width+2, t, t]);
  }
}

module side(depth, front_height, back_height) {
  translate([t, 0, 0])
  rotate([0, -90, 0])
  linear_extrude(height=t)
  polygon([[0, 0], [0, depth], [back_height, depth], [front_height, 0]]);
}

module back(width, height) {
  translate([0, t, 0]) cube([width, t, height]);
}

module bottom(width, depth) {
  cube([width, depth, t]);
}

module arm(depth) {
  // this doesn't quite scale right, so I might redo it
  translate([-3*t, 0, 0])
  difference() {
    cube([4*t, depth, 6*t]);
    translate([t, -1, t])cube([2*t, depth+2, 4*t]);
  }
}

module dumpster(width, front_height, back_height, depth) {
                               front(width, front_height);
  translate([0, depth - t, 0]) back(width, back_height);
                               side(depth, front_height, back_height);
  translate([width - t, 0, 0]) side(depth, front_height, back_height);
                               bottom(width, depth);
  translate([0,         0, front_height/2]) arm(depth+t);
  translate([width+2*t, 0, front_height/2]) arm(depth+t);
}

dumpster(1800, 900, 1200, 900);