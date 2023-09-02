t=40; // thickness of the panels

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


module dumpster_print_position(width, front_height, back_height, depth) {
   
  dh = back_height - front_height;
  lid_angle = atan2(dh, depth);
  lid_length = sqrt((dh*dh) + (depth*depth));
    
  translate([0, lid_length, 0])
    rotate([180 - lid_angle, 0, 0])
      translate([0, 0, -front_height])
        translate([width/-2, 0, 0])
          dumpster(width, front_height, back_height, depth);
}

default_dumpster_width = 1800;

default_hinge_length = default_dumpster_width; 
default_hinge_outer_d = 150; 
default_hinge_inner_d = 100;
default_n_lid_fins = 4;
default_fin_thickness = 40;
default_lid_thickness = 30;
default_slip_gap = 6;
lid_taper_angle = 30;
lid_taper_distance = default_hinge_outer_d * cos(lid_taper_angle);
default_hinge_span = default_hinge_length - 3 * default_fin_thickness;
large_dimension = 100000000;

module lid_hinge_base() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
  
  translate([0, 0, default_hinge_outer_d/2]) {
    difference() {
      // The outer solid of the hinge stator
      rotate([0, 90, 0])
        cylinder(h = default_hinge_length, r = default_hinge_outer_d/2, center = true, $fn = 128);
    
      translate([0,0,0]) {
        // The slots where the lid fins swivel
        for(i = [0:1:default_n_lid_fins-1]) {
          translate([default_hinge_span/-2 + (i + 0.5) * fin_distance, 0, 0])
            cube([default_fin_thickness + 2*default_slip_gap, large_dimension, large_dimension], center = true);
        }
        // The hollow where the rotor pin sits
        rotate([0, 90, 0]) 
          cylinder(h = default_hinge_length - 20, r = default_hinge_inner_d/2 + default_slip_gap, center = true, $fn = 128);
      }
    }
  }
}

module lid_hinge_subtract() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
  
  translate([0, 0, default_hinge_outer_d/2]) {
    // The outer solid of the hinge stator
    rotate([0, 90, 0])
      cylinder(h = default_hinge_length, r = default_hinge_outer_d/2, center = true, $fn = 128);
    
  }
}

module lid_hinge_base_cutout() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
  
  translate([0, 0, default_hinge_outer_d/2]) {
    difference() {
      // The outer solid of the hinge stator
      rotate([0, 90, 0])
        cylinder(h = default_hinge_length + 2*default_slip_gap, r = default_hinge_outer_d/2 + default_slip_gap, center = true, $fn = 128);
    
      translate([0,0,0]) {
        // The slots where the lid fins swivel
        for(i = [0:1:default_n_lid_fins-1]) {
          translate([default_hinge_span/-2 + (i + 0.5) * fin_distance, 0, 0])
            cube([default_fin_thickness, large_dimension, large_dimension], center = true);
        }
      }
    }
  }
}

module lid_hinge_rotor() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
    
  translate([0, 0, default_hinge_outer_d/2]) {
    // The inner pin of the hinge rotor
    rotate([0, 90, 0])
      cylinder(h = default_hinge_length - 40, r = default_hinge_inner_d/2, center = true, $fn = 128);
      
    // The rings where the lid fins connect
    for(i = [0:1:default_n_lid_fins-1]) {
      translate([default_hinge_span/-2 + (i + 0.5) * fin_distance, 0, 0])
            rotate([0, 90, 0])
              cylinder(h = default_fin_thickness, r = default_hinge_outer_d/2, center = true, $fn = 128);
        }
  }
}

module lid_hinge_rotor() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
    
  translate([0, 0, default_hinge_outer_d/2]) {
    // The inner pin of the hinge rotor
    rotate([0, 90, 0])
      cylinder(h = default_hinge_length - 50, r = default_hinge_inner_d/2, center = true, $fn = 128);
      
    // The rings where the lid fins connect
    for(i = [0:1:default_n_lid_fins-1]) {
      translate([default_hinge_span/-2 + (i + 0.5) * fin_distance, 0, 0])
            rotate([0, 90, 0])
              cylinder(h = default_fin_thickness, r = default_hinge_outer_d/2, center = true, $fn = 128);
        }
  }
}

module lid_hinge_rotor_cutout() {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
    
  translate([0, 0, default_hinge_outer_d/2]) {
    // The inner pin of the hinge rotor
    rotate([0, 90, 0])
      cylinder(h = default_hinge_length - 30 + 2*default_slip_gap, r = default_hinge_inner_d/2 + default_slip_gap, center = true, $fn = 128);
      
    // The rings where the lid fins connect
    for(i = [0:1:default_n_lid_fins-1]) {
      translate([default_hinge_span/-2 + (i + 0.5) * fin_distance, 0, 0])
            rotate([0, 90, 0])
              cylinder(h = default_fin_thickness + 2*default_slip_gap, r = default_hinge_outer_d/2 + default_slip_gap, center = true, $fn = 128);
        }
  }
}

module lid(width, front_height, back_height, depth) {
    
  fin_distance = default_hinge_span/default_n_lid_fins;
   
  dh = back_height - front_height;
  lid_length = sqrt((dh*dh) + (depth*depth));
  upper_fin_length = lid_length - 20;
  lower_fin_length = lid_length - lid_taper_distance - 20;
    
  // The lid fins
  for(i = [0:1:default_n_lid_fins-1]) {
    hull() {
      translate([ default_hinge_span/-2 + (i + 0.5) * fin_distance, 
                  lower_fin_length/-2, 
                  default_hinge_outer_d/2])
      cube([default_fin_thickness, lower_fin_length, default_hinge_outer_d], center = true);
      translate([ default_hinge_span/-2 + (i + 0.5) * fin_distance, 
                  upper_fin_length/-2, 
                  default_hinge_outer_d + default_lid_thickness/2])
      cube([default_fin_thickness, upper_fin_length, default_lid_thickness], center = true);
    }
  }
  
  // The lid
  translate([0, (lid_length)/-2, default_hinge_outer_d + default_lid_thickness/2]) 
    cube([width, lid_length, default_lid_thickness], center = true);
}


module lid_supports(width, front_height, back_height, depth) {

  dh = back_height - front_height;
  lid_length = sqrt((dh*dh) + (depth*depth));

  // The lid
  difference() {
    translate([0, (lid_length + 8*default_slip_gap)/-2, (default_hinge_outer_d-default_slip_gap)/2]) 
      cube([width + 5*default_slip_gap, lid_length + 8*default_slip_gap, default_hinge_outer_d-default_slip_gap], center = true);
    translate([0, 0, 0]) {
      translate([0, (lid_length - 2*default_slip_gap)/-2, 0]) 
        cube([width - 10*default_slip_gap, lid_length - 2*default_slip_gap, default_hinge_outer_d*2], center = true);
    }
  }
}

module assembly_with_lid() {
  scale([0.1, 0.1, 0.1]) {
    lid_hinge_base();
    difference() {
      dumpster_print_position(default_dumpster_width, 900, 1200, 900);
      translate([0,0,0]){
        lid_hinge_subtract();
        lid_hinge_rotor_cutout();
      }
    }
    lid_hinge_rotor();
    difference() {
        lid(default_dumpster_width, 900, 1200, 900);
        lid_hinge_base_cutout();
    }
    difference() {
      lid_supports(default_dumpster_width, 900, 1200, 900);
        lid_hinge_base_cutout();
    }
  }
}

assembly_with_lid();