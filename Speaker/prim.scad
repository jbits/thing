//
// Misc library
//
// by Yasuhiro Wabiko
//
// This work is licensed under a Creative Commons Attribution 4.0 International License.
// https://creativecommons.org/licenses/by/4.0/
//
// See
//    https://github.com/ywabiko/3d/blob/master/Speaker/README.md
// for build instructions.
//

WELDING=0.1;

round2_plate(30,20,2);

translate([10,0,0])
  round2_plate(60,20,2);

translate([20,0,0])
  round2_plate(100,20,2);


module round2_plate(width, height, radius)
{
    hull(){
        translate([0,0,0])
            cylinder(r=radius, h=height, $fn=64);
        translate([0,width,0])
            cylinder(r=radius, h=height, $fn=64);
    }
}


module round2_plate_triangled(width, height, radius1, radius2)
{
    hull(){
        translate([0,0,0])
            cylinder(r=radius1, h=height, $fn=64);
        translate([0,width,0])
            cylinder(r=radius2, h=height, $fn=64);
    }
}


// px,py,pz has to be larger than r*2
// alignment: (x,y,z) = (0, py0/2, 0)
module prim_round_cube(px0, py0, pz0,  pr0, pf)
{
    pr = pr0;
    px = px0 - pr*2;
    py = py0 - pr*2;
    pz = pz0 - pr*2;
    translate([(px+pr*2)/2, 0, (pz+pr*2)/2])
    minkowski(){
        cube([px, py, pz], center=true);
        sphere(r=pr, $fn=32);
    }
}

// px,py,pz has to be larger than r*2
// alignment: (x,y,z) = (0, py0/2, 0)
module prim_round_cube0(px0, py0, pz0,  pr0, pf)
{
    pr = pr0;
    px = px0 - pr*2;
    py = py0 - pr*2;
    pz = pz0 - pr*2;
    translate([0, 0, 0])
    minkowski(){
        cube([px, py, pz], center=true);
        sphere(r=pr, $fn=pf);
    }
}

// px0,py0 = width(x-axis),height(y-axis), center at (0,0), facing x-axis posiive
// pz = thickness (z-axis from z=0)
// pr = r
// fn = $fn
module prim_round_xplate(px0, py0, pz0,  pr, pf)
{
    px = px0;
    py = py0-pr*2;
    pz = pz0-pr*2;
      
    hull(){
        translate([0,-py/2,-pz/2])
          rotate([0,90,0])
            cylinder(r=pr, h=px, $fn=pf, center=true);
        translate([0,+py/2, -pz/2])
          rotate([0,90,0])
            cylinder(r=pr,h=px, $fn=pf, center=true);
        translate([0,-py/2, +pz/2])
          rotate([0,90,0])
            cylinder(r=pr,h=px, $fn=pf, center=true);
        translate([0,+py/2, +pz/2])
          rotate([0,90,0])
            cylinder(r=pr, h=px, $fn=pf, center=true);
    }
}

// center at (x/2,y/2,z/2), facing z-axis positive
module prim_round_zplate0(px0, py0, pz0,  pr, pf)
{
    px = px0-pr*2;
    py = py0-pr*2;
    pz = pz0;
    hull(){
        translate([ px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([ px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
    }    
}

// center at (x/2,y/2,z/2), facing x-axis positive
module prim_round_xplate0(pz0, py0, px0,  pr, pf)
{
    px = px0-pr*2;
    py = py0-pr*2;
    pz = pz0;
    rotate([0,90,0])
    hull(){
        translate([ px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([ px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
    }    
}

// center at (x/2,y/2,z/2), facing y-axis positive
module prim_round_yplate0(px0, pz0, py0, pr, pf)
{
    px = px0-pr*2;
    py = py0-pr*2;
    pz = pz0;
    rotate([90,0,0])
    hull(){
        translate([ px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2,  py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([ px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
        translate([-px/2, -py/2, 0])
            cylinder(r=pr, h=pz, $fn=pf, center=true);
    }    
}


//
// Screw Holes
//
default_wall_t = 2;

// [Public]
// #2 1/8" screw hole (diameter 2mm x depth 3mm)
// wall thickness = 2mm by default, so overall dimension is 6mm x 6mm x 5mm high.
// align = { "none" : centered at (0,0,0) facing z-axis positive (same as zplate0)
//           "x"    : aligned to yz-plane, facing x-axis positive.
//           "y"    : aligned to zx-plane, facing y-axis positive.
//           "z"    : aligned to xy-plane, facing z-axis positive.
//          }
module screw_hole_d2_h3(align="none", wall_t = default_wall_t, volume_type="positive",
                        shell_x=0, shell_y=0, shell_z=0, with_shell=0){
    hole_d = 2;
    hole_z = 3;
    screw_hole_body(align=align, hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, volume_type=volume_type,
                    shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
}

// [Public]
// #4-3/8" screw (diameter 2.8mm x depth 9.5mm)
// wall thickness = 2mm by default, so overall dimension is 6.8mm x 6.8mm x 9.7mm high.
// align = { "none" : centered at (0,0,0) facing z-axis positive (same as zplate0)
//           "x"    : aligned to yz-plane, facing x-axis positive.
//           "y"    : aligned to zx-plane, facing y-axis positive.
//           "z"    : aligned to xy-plane, facing z-axis positive.
//          }
module screw_hole_d28_h95(align="none", wall_t = default_wall_t, volume_type="positive",
                          shell_x=0, shell_y=0, shell_z=0, with_shell=0)
{
    hole_d = 2.8;
    hole_z = 9.5;
    screw_hole_body(align=align, hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, volume_type=volume_type,
        shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
}


//
// internal modules
//

// Calculate shell dimension and delegate to each alignment-specific modules.
module screw_hole_body(align="none", hole_d, hole_z, wall_t = default_wall_t, volume_type="positive",
                       shell_x=0, shell_y=0, shell_z=0, with_shell=0) {

    unit_x = (1-with_shell)*(hole_d+wall_t*2) + with_shell*shell_x;
    unit_y = (1-with_shell)*(hole_d+wall_t*2) + with_shell*shell_y; 
    unit_z = (1-with_shell)*hole_z+wall_t + with_shell*shell_z;

    if (align == "none") {
        screw_hole_zplate0(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type,
                           shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
    }
    if (align == "x") {
        screw_hole_align_x(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type,
                           shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
    }
    if (align == "y") {
        screw_hole_align_y(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type,
                           shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
    }
    if (align == "z") {
        screw_hole_align_z(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type,
                           shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
    }
}

// align = { "x"    : face aligned to yz-plane, facing x-axis positive. }
module screw_hole_align_x(hole_d, hole_z, wall_t, unit_x, unit_y, unit_z, volume_type="positive")
{
    translate([-unit_z/2,0,0])
    {
        rotate([0,90,0]) {
            screw_hole_zplate0(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type);
        }
    }
}

// align = { "y"    : face aligned to zx-plane, facing y-axis positive. }
module screw_hole_align_y(hole_d, hole_z, wall_t, unit_x, unit_y, unit_z, volume_type="positive")
{
    translate([0,-unit_z/2,0]){
        rotate([-90,0,0]) {
            screw_hole_zplate0(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type);
        }
    }
}

// align = { "z"    : face aligned to xy-plane, facing z-axis positive. }
module screw_hole_align_z(hole_d, hole_z, wall_t, unit_x, unit_y, unit_z, volume_type="positive")
{
    translate([0,0,-unit_z/2])
    {
        rotate([0,0,0]) {
            screw_hole_zplate0(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, volume_type=volume_type);
        }
    }
}

// align = { "none" : centered at (0,0,0) facing z-axis positive (same as zplate0) }
module screw_hole_zplate0(hole_d, hole_z, wall_t, unit_x, unit_y, unit_z, volume_type="positive",
                          shell_x=0, shell_y=0, shell_z=0, with_shell=0) {

    if (volume_type == "positive") {
        difference() {
            cube([unit_x, unit_y, unit_z],center=true);
            screw_hole_negative_volume(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z,
                                       shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
        }
    } else {
        screw_hole_negative_volume(hole_d=hole_d, hole_z=hole_z, wall_t=wall_t, unit_x=unit_x, unit_y=unit_y, unit_z=unit_z, 
                                   shell_x=shell_x, shell_y=shell_y, shell_z=shell_z, with_shell=with_shell);
    }
}

// negative volume for align = "none" mode. (same as zplate0)
module screw_hole_negative_volume(hole_d, hole_z, wall_t, unit_x, unit_y, unit_z, 
                                  shell_x=0, shell_y=0, shell_z=0, with_shell=0) {


    translate([0,0,unit_z/2-hole_z]) {
        cylinder(r=hole_d/2, h=hole_z+WELDING, $fn=16);
    }
}


//
// class related stuff
// from
// http://forum.openscad.org/parameterized-models-td8303.html
//

// hash for flat style key-value pair
// see get_aligned() below for usage.
function hash00(h, k, _i_=0) = ( 
    _i_>len(h)-1 ? undef  // key not found 
    : h[_i_]==k ?    // key found 
    h[_i_+1]  // return v 
    : hash(h,k,_i_+2)           
    );

function hash(h, k, _i_=0) = ( 
    _i_>len(h)-1 ? undef  // key not found 
    : h[_i_][0]==k ?    // key found 
    h[_i_][1]  // return v 
    : hash(h,k,_i_+1)           
    );

//
// misc utilities
//

//
// get_aligned(align_x, align_y, align_z, size_x, size_y, size_z) 
//
// This returns a point that meets the specified alignment requirement.
// The point returned is located on an edge of the cube
//   - whose size is (size_x, size_y, size_z), and
//   - whose center is at (0,0,0).
//
// align_x = { "front" | "center" | "back" }
// align_y = { "left"  | "center" | "right" }
// align_z = { "top"   | "center" | "bottom" }
// size_x, size_y, size_z = size of the cube
//
// Note: to generate a flat style key-value pair in a human-readable way,
// you have to use concat() for now.
//
_alignment_map = concat([["front", 1],
                        ["center", 0],
                        ["back", -1],
                        ["left", -1],
                        ["right", 1],
                        ["top", 1],
                        ["bottom", -1]]);
    
function get_aligned(align_x, align_y, align_z, size_x, size_y, size_z) = (
    [ hash(_alignment_map, align_x)*size_x/2,
      hash(_alignment_map, align_y)*size_y/2,
      hash(_alignment_map, align_z)*size_z/2 ]);

module get_aligned_verbose(align_x, align_y, align_z, size_x, size_y, size_z) {
    get_aligned_result = get_aligned(align_x, align_y, align_z, size_x, size_y, size_z);
    get_aligned_result2 = [ hash(_alignment_map, align_x)*size_x/2,
                           hash(_alignment_map, align_y)*size_y/2,
                           hash(_alignment_map, align_z)*size_z/2 ];
    echo(get_aligned_result=get_aligned_result);
    echo(get_aligned_result2=get_aligned_result2);
    
}
function front_center(sx, tx) = [-sx/2+tx/2, 0, 0];
function back_center(sx, tx) = [sx/2, 0, 0];
function left_center(sy, ty)  = [0, -sy/2+ty/2, 0];
function right_center(sy, ty) = [0, sy/2-ty/2, 0];
function top_center(sz, tz) = [0, 0, sz/2-tz/2];
function bottom_center(sz, tz) = [0, 0, -sz/2+tz/2];
function board_surface_z(sz, tz) = [0, 0, -sz/2+tz];

