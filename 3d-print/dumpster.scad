t=15; // thickness of the panels

module front(width, height) {
    // main wall with "v" cutouts
    rotate([90, 0, 0])
    difference() {
        cube([width, height, t]);
        translate([-1,   height/3, 3]) rotate([45, 0, 0]) cube([width+2, 2*t, 2*t]);
        translate([-1, 2*height/3, 3]) rotate([45, 0, 0]) cube([width+2, 2*t, 2*t]);
    }
}

module side(depth, front_height, back_height) {
    translate([t, -t, 0])
    rotate([0, -90, 0])
    linear_extrude(height=t)
    polygon([[0, 0], [0, depth], [back_height, depth], [front_height, 0]]);
}

module back(width, height) {
    cube([width, t, height]);
}

module bottom(width, depth) {
    cube([width, depth, t]);
}

module dumpster(width, front_height, back_height, depth) {
    // I have no idea how to format this to be readable
                                 front(width, front_height);
    translate([0, depth - t, 0]) back(width, back_height);    
                                 side(depth, front_height, back_height);
    translate([width - t, 0, 0]) side(depth, front_height, back_height);
                                 bottom(width, depth);
}

dumpster(1800, 900, 1200, 900);
