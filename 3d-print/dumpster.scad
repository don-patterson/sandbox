// All dimensions are in centimeters

// Variables
// General
support_gap = 0.02;
default_horz_slip_gap = 0.03;
default_rotor_slip_gap = 0.04;
large_dimension = 100000000;

// Core Dumpster Defaults
du_co_default_panel_thick = 0.25;
du_co_default_dumpster_width = 12;
du_co_default_dumpster_front_height = 6;
du_co_default_dumpster_back_height = 7;
du_co_default_dumpster_depth = 6;

// Hinge Defaults
du_hn_default_hinge_length = du_co_default_dumpster_width;
du_hn_default_hinge_outer_d = 0.866666666666666666666666666666;
du_hn_default_hinge_inner_d = 0.577777777777777777777777777777;

// Lid Defaults
du_ld_default_n_lid_fins = 4;
du_ld_default_fin_thickness = 0.231;
du_ld_default_lid_thickness = 0.173333333333333333333;
du_ld_lid_taper_angle = 30;
du_ld_lid_taper_distance = du_hn_default_hinge_outer_d * cos(du_ld_lid_taper_angle);
du_ld_default_fin_span = du_hn_default_hinge_length - 3 * du_ld_default_fin_thickness;


// Core Dumpster Modules
module front(
    width,
    height,
    thickness
    ) {
  // main wall with "v" cutouts
  difference() {
    cube([width, thickness, height]);
    translate([0, -thickness/10, height/3])
      rotate([45, 0, 0])
        cube([width, thickness, thickness]);
    translate([0, -thickness/10, 2*height/3])
      rotate([45, 0, 0])
        cube([width, thickness, thickness]);
  }
}

module side(
    depth,
    front_height,
    back_height,
    thickness
    ) {
  translate([thickness, 0, 0])
    rotate([0, -90, 0])
      linear_extrude(height=thickness)
        polygon([[0, 0], [0, depth], [back_height, depth], [front_height, 0]]);
}

module back(
    width,
    height,
    thickness
    ) {
  translate([0, thickness, 0])
    cube([width, thickness, height]);
}

module bottom(
    width,
    depth,
    thickness
    ) {
  cube([width, depth, thickness]);
}

module arm(
    depth,
    thickness
    ) {
  // this doesn't quite scale right, so I might redo it
  translate([-3*thickness, 0, 0]) {
    difference() {
      cube([4*thickness, depth, 6*thickness]);
      translate([thickness, -1, thickness])
        cube([2*thickness, depth+2, 4*thickness]);
    }
  }
}

module dumpster(
    width = du_co_default_dumpster_width,
    front_height = du_co_default_dumpster_front_height,
    back_height = du_co_default_dumpster_back_height,
    depth = du_co_default_dumpster_depth,
    thickness = du_co_default_panel_thick
    ) {

  front(width, front_height, thickness);
  translate([0, depth - thickness, 0])
    back(width, back_height, thickness);
  side(depth, front_height, back_height, thickness);
  translate([width - thickness, 0, 0])
    side(depth, front_height, back_height, thickness);
  bottom(width, depth, thickness);
  translate([0, 0, front_height/2])
    arm(depth+thickness, thickness);
  translate([width+2*thickness, 0, front_height/2])
    arm(depth+thickness, thickness);
}

module dumpster_print_position(
    width = du_co_default_dumpster_width,
    front_height = du_co_default_dumpster_front_height,
    back_height = du_co_default_dumpster_back_height,
    depth = du_co_default_dumpster_depth,
    thickness = du_co_default_panel_thick
    ) {

  dh = back_height - front_height;
  lid_angle = atan2(dh, depth);
  lid_length = sqrt((dh*dh) + (depth*depth));

  translate([0, lid_length, 0])
    rotate([180 - lid_angle, 0, 0])
      translate([0, 0, -front_height])
        translate([width/-2, 0, 0])
          dumpster(width, front_height, back_height, depth, thickness);
}



// Hinge Modules
module lid_hinge_base(
    hinge_length = du_hn_default_hinge_length,
    outer_d = du_hn_default_hinge_outer_d,
    inner_d = du_hn_default_hinge_inner_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  translate([0, 0, outer_d/2]) {
    difference() {
      // The outer solid of the hinge stator
      rotate([0, 90, 0])
        cylinder(h = hinge_length, r = outer_d/2, center = true, $fn = 128);

      // The slots where the lid fins swivel
      for(i = [0:1:n_fins-1]) {
        translate([fin_span/-2 + i * fin_distance, 0, 0])
          cube([fin_thickness + 2*default_horz_slip_gap, large_dimension, large_dimension], center = true);
      }
      // The hollow where the rotor pin sits
      rotate([0, 90, 0])
        cylinder(h = hinge_length - 2 * default_horz_slip_gap, r = inner_d/2 + default_rotor_slip_gap, center = true, $fn = 128);
      }
  }
}

module lid_hinge_subtract(
    hinge_length = du_hn_default_hinge_length,
    outer_d = du_hn_default_hinge_outer_d,
    ) {
  hull() {
    lid_hinge_base(hinge_length=hinge_length, outer_d=outer_d);
  }
}

module lid_hinge_base_cutout(
    hinge_length = du_hn_default_hinge_length,
    outer_d = du_hn_default_hinge_outer_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  translate([0, 0, outer_d/2]) {
    difference() {
      // The outer solid of the hinge stator
      rotate([0, 90, 0])
        cylinder(h = hinge_length + 4*default_horz_slip_gap, r = outer_d/2 + default_rotor_slip_gap, center = true, $fn = 128);

      translate([0,0,0]) {
        // The slots where the lid fins swivel
        for(i = [0:1:n_fins-1]) {
          translate([fin_span/-2 + i * fin_distance, 0, 0])
            cube([fin_thickness, large_dimension, large_dimension], center = true);
        }
      }
    }
  }
}

module lid_hinge_rotor(
    hinge_length = du_hn_default_hinge_length,
    outer_d = du_hn_default_hinge_outer_d,
    inner_d = du_hn_default_hinge_inner_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  translate([0, 0, outer_d/2]) {
    // The inner pin of the hinge rotor
    rotate([0, 90, 0])
      cylinder(h = hinge_length - 4 * default_horz_slip_gap, r = inner_d/2, center = true, $fn = 128);

    // The rings where the lid fins connect
    for(i = [0:1:n_fins-1]) {
      translate([fin_span/-2 + i * fin_distance, 0, 0])
            rotate([0, 90, 0])
              cylinder(h = fin_thickness, r = outer_d/2, center = true, $fn = 128);
        }
  }
}


module lid_hinge_rotor_cutout(
    hinge_length = du_hn_default_hinge_length,
    outer_d = du_hn_default_hinge_outer_d,
    inner_d = du_hn_default_hinge_inner_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  translate([0, 0, outer_d/2]) {
    // The inner pin of the hinge rotor
    rotate([0, 90, 0])
      cylinder(h = hinge_length + 2*default_horz_slip_gap, r = inner_d/2 + default_rotor_slip_gap, center = true, $fn = 128);

    // The rings where the lid fins connect
    for(i = [0:1:n_fins-1]) {
      translate([fin_span/-2 + i * fin_distance, 0, 0])
            rotate([0, 90, 0])
              cylinder(h = fin_thickness + 2*default_horz_slip_gap, r = outer_d/2 + default_rotor_slip_gap, center = true, $fn = 128);
        }
  }
}



// Lid Modules
module lid(
    width,
    front_height,
    back_height,
    depth,
    panel_thickness = du_co_default_panel_thick,
    lid_thickness = du_ld_default_lid_thickness,
    outer_d = du_hn_default_hinge_outer_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  dh = back_height - front_height;
  lid_length = sqrt((dh*dh) + (depth*depth));
  upper_fin_length = lid_length - panel_thickness;
  lower_fin_length = lid_length - du_ld_lid_taper_distance - panel_thickness;

  // The lid fins
  for(i = [0:1:n_fins-1]) {
    hull() {
      translate([ fin_span/-2 + i * fin_distance,
                  lower_fin_length/-2,
                  outer_d/2])
      cube([fin_thickness, lower_fin_length, outer_d], center = true);
      translate([ fin_span/-2 + i * fin_distance,
                  upper_fin_length/-2,
                  outer_d + lid_thickness/2])
      cube([fin_thickness, upper_fin_length, lid_thickness], center = true);
    }
  }

  // The lid
  translate([0, (lid_length)/-2, outer_d + lid_thickness/2])
    cube([width, lid_length, lid_thickness], center = true);
}

module lid_fin_cutout(
    width,
    front_height,
    back_height,
    depth,
    panel_thickness = du_co_default_panel_thick,
    lid_thickness = du_ld_default_lid_thickness,
    outer_d = du_hn_default_hinge_outer_d,
    n_fins = du_ld_default_n_lid_fins,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  fin_distance = fin_span/(n_fins-1);

  dh = back_height - front_height;
  lid_length = sqrt((dh*dh) + (depth*depth));
  upper_fin_length = lid_length - panel_thickness;
  lower_fin_length = lid_length - du_ld_lid_taper_distance - panel_thickness;

  // The lid fins
  for(i = [0:1:n_fins-1]) {
    hull() {
      translate([ fin_span/-2 + i * fin_distance,
                  lower_fin_length/-2,
                  outer_d/2])
      cube([
        fin_thickness + 2*default_horz_slip_gap,
        lower_fin_length + 2*default_horz_slip_gap,
        outer_d + 2*default_horz_slip_gap], center = true);
      translate([ fin_span/-2 + i * fin_distance,
                  upper_fin_length/-2,
                  outer_d + lid_thickness/2])
      cube([
        fin_thickness + 2*default_horz_slip_gap,
        upper_fin_length + 2*default_horz_slip_gap,
        lid_thickness + 2*default_horz_slip_gap], center = true);
    }
  }
}


module lid_supports(
    width,
    front_height,
    back_height,
    depth,
    outer_d = du_hn_default_hinge_outer_d,
    fin_span = du_ld_default_fin_span) {

  dh = back_height - front_height;
  lid_length = sqrt((dh*dh) + (depth*depth));

  // The lid perimeter
  difference() {
    translate([0, (lid_length + 8*support_gap)/-2, (outer_d-support_gap)/2])
      cube([width - support_gap, lid_length + 4*support_gap, outer_d-support_gap], center = true);
    translate([0, 0, 0]) {
      translate([0, (lid_length - 2*support_gap)/-2, 0])
        cube([width - 16*support_gap, lid_length - 6*support_gap, outer_d*2], center = true);
    }
  }
}



// Full Assembly Modules
module assembly_with_lid(
    width = du_co_default_dumpster_width,
    front_height = du_co_default_dumpster_front_height,
    back_height = du_co_default_dumpster_back_height,
    depth = du_co_default_dumpster_depth,
    thickness = du_co_default_panel_thick,
    hinge_inner_d = du_hn_default_hinge_inner_d,
    hinge_outer_d = du_hn_default_hinge_outer_d,
    n_lid_fins = du_ld_default_n_lid_fins,
    lid_thickness = du_ld_default_lid_thickness,
    fin_thickness = du_ld_default_fin_thickness,
    fin_span = du_ld_default_fin_span
    ) {

  hinge_length = width;

  lid_hinge_base(hinge_length, hinge_outer_d, hinge_inner_d, n_lid_fins, fin_thickness, fin_span);
  difference() {
    dumpster_print_position(width, front_height, back_height, depth, thickness);
    translate([0,0,0]){
      lid_hinge_subtract(hinge_length, hinge_outer_d);
      lid_hinge_rotor_cutout(hinge_length, hinge_outer_d, hinge_inner_d, n_lid_fins, fin_thickness, fin_span);
      // Rotate the lid fin cutout into the closed lid position.
      translate([0, 0, hinge_outer_d/2])
        rotate([180, 0, 0])
          translate([0, 0, hinge_outer_d/-2])
            lid_fin_cutout(width, front_height, back_height, depth, thickness, lid_thickness, hinge_outer_d, n_lid_fins, fin_thickness, fin_span);
    }
  }
  lid_hinge_rotor(hinge_length, hinge_outer_d, hinge_inner_d, n_lid_fins, fin_thickness, fin_span);
  difference() {
    lid(width, front_height, back_height, depth, thickness, lid_thickness, hinge_outer_d, n_lid_fins, fin_thickness, fin_span);
    lid_hinge_base_cutout(hinge_length, hinge_outer_d, n_lid_fins, fin_thickness, fin_span);
  }
  difference() {
    lid_supports(width, front_height, back_height, depth, hinge_outer_d);
    lid_hinge_base_cutout(hinge_length, hinge_outer_d, n_lid_fins, fin_thickness, fin_span);
  }
}

assembly_with_lid();
