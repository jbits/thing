//
// Pimoroni Phat Dac Enclosure
//
// by Yasuhiro Wabiko
//
// This work is licensed under a Creative Commons Attribution 4.0 International License.
// https://creativecommons.org/licenses/by/4.0/
//
// See
//    https://github.com/ywabiko/thing/blob/master/Speaker/README.md
// for build instructions.
//

use <prim.scad>

board_x = 30.5;
board_y = 65;
board_z = 14.5;

microsd_dy = 2.5; // SD card clearance (2.5mm)
microsd_y = board_y+microsd_dy*2;  // including SD card clearance (2.5mm), the right side is dummy
microsd_z = 4;
led_x = 18.5;
led_y = 61;
led_z = 2;
pcb_z = 2;

arm_below_z = 2;
arm_lo_z = 2;
arm_up_z = 2+2.5;
arm_above_z = 0;
arm_left_t = 2;
arm_right_t = 2;
arm_front_t = 0;

stuff_x = board_x;
stuff_y = board_y+microsd_dy*2;
stuff_z = board_z+arm_lo_z+arm_up_z+arm_below_z+arm_above_z;

holder_wall_t = 1;
holder_x = stuff_x + holder_wall_t;
holder_y = stuff_y + holder_wall_t*2;
holder_z = stuff_z + holder_wall_t*2;
holder_bottom_cutouts = [[14, 7.5, 4], [14, -7.5, 4]]; // bottom cable slits
holder_front_cutouts = [[10.5, 3], [-10.5, 3]]; // front 3.5mm jacks
holder_top_cutous = [[61,14]]; // top LED cutouts

lid_x = 2;
lid_inner_x = 2;
lid_inner_t = 1;
lid_inner_ty = 4;

lid_arm_y = 5;
lid_arm_z = microsd_z;
lid_arm_x = 5;

audiojack_r = 3.2;
microusb_z = 3;
microusb_y = 9;
minihdmi_z = 3.5;
minihdmi_y = 12;
dacjack_x = 15;
dacjack_r = 2.6;

WELDING=0.1;
print_rotation    = [[0, 0, 0],[0, -90, 0]];
print_translation = [[16, 0, 0],[0, 0, 0]];

TARGET="default";

phatdac_main(target=TARGET);

// bbox: (x,y,z) = (same as board_x, same as board_y, board_z + space above*below it)
module phatdac_main(target="default"){

    if (target == "default") {
        with_body = 1;
        with_lid = 1;
        with_print = 1;
        //translate([-stuff_x-holder_wall_t,stuff_y/2-4.5,stuff_z/2]) // debug
        if (with_body) {
            rotate(print_rotation[with_print]) {
                translate([stuff_x/2+holder_wall_t,0,0]){
                    difference() {
                        union() {
                            phatdac_holder(with_round=1, with_hole_bottom=0, with_screw=0);
                            phatdac_arm(with_welding=1);
                        }
                        union() {
                            phatdac_holder_negative_volume(with_round=1, with_hole_bottom=0, with_screw=0, with_open_roof=0);
                        }
                    }
                }
            }
        }
        if (with_lid) {
            translate([holder_z+4,0,0]) {
                rotate(-print_rotation[with_print]) {
                    translate(print_translation[with_print]) {
                        phatdac_lid();
                    }
                }
            }
        }
    }

    if (target == "board_test") {
        with_print = 0;
        rotate(print_rotation[with_print]) {
            phatdac_board();
        }
    }

    if (target == "unit_test") {
        with_print = 1;
        rotate(print_rotation[with_print]) {
            phatdac_unit();
        }
    }

    if (target == "unit_fit_test") {
        with_print = 1;
        rotate(print_rotation[with_print]) {
            difference() {
                union() {
                    phatdac_unit();
                }
                union() {
                    translate([-holder_x+14,0,0]) {
                        cube([holder_x,holder_y*2,holder_z*2], center=true);
                    }
                    translate([holder_x-29,0,0]) {
                        cube([holder_x,holder_y*2,holder_z*2], center=true);
                    }
                }
            }
        }
    }

    if (target == "screw_negative_test") {
        with_print = 1;
        rotate(print_rotation[with_print]) {
            phatdac_screw(volume_type="negative");
        }
    }

    if (target == "unit_lid_negative_test") {
        with_print =0;
        rotate(print_rotation[with_print]) {
            phatdac_unit_lid_negative_volume();
        }
    }

    if (target == "lid_test") {
        with_print = 0;
        rotate(print_rotation[with_print]) {
            phatdac_lid();
        }
    }
}

module phatdac_unit() {
    translate([-holder_x, 0, holder_z/2]) {
        rotate([0,0,180]) {
            translate([holder_wall_t/2-holder_x/2,0,0]) {
                rotate([180,0,0]) {
                    phatdac_holder(holder_y=36, holder_x=45, with_round=1, with_hole_front=0, with_hole_bottom=1, with_vent=0, with_screw=1);
                    phatdac_arm(with_welding=1);
                }
            }
        }
    }
}

module phatdac_board() {
    dx = with_welding*WELDING;
    dy = with_welding*WELDING;
    dz = with_welding*WELDING;

    translate([-stuff_x/2,stuff_y/2-5,stuff_z/2]) {
        translate([-dx/2, 0, 0]) {
            // materialize board space if required (this is used to remove this volume from lid)
            // Zero
            translate([0, 0, -stuff_z/2+arm_below_z+arm_lo_z+pcb_z/2]) {
                #cube([board_x+WELDING, board_y+WELDING, pcb_z], center=true);
            }
            // Phatdac
            echo(stuff_z=stuff_z);
            echo(board_z=board_z);
                
            translate([0, 0, -stuff_z/2+arm_below_z+arm_lo_z+board_z-pcb_z/2]) {
                #cube([board_x+WELDING, board_y+WELDING, pcb_z], center=true);
            }
        }    

        // LED
        translate([0,0, stuff_z/2-led_z/2]) {
            translate([stuff_x/2-led_x/2,0,0]) {
                cube([led_x, led_y, led_z], center=true);
            }
        }
    }
}

module phatdac_unit_lid_negative_volume() {
    translate([0, 0, holder_z/2]) {
        rotate([0,0,180]) {
            translate([holder_wall_t/2-holder_x/2-2,0,0]) {
                rotate([180,0,0]) {
                    phatdac_holder(holder_y=36, holder_x=45, with_round=1, with_hole_front=0, with_hole_bottom=1, with_vent=0, with_screw=1);
                    phatdac_arm(with_welding=1, with_board_part=1);
                    scale([1.1,1,1])
                    phatdac_screw(volume_type="negative");

                    usb_z = 3;
                    usb_y = 8;
                    translate([board_x/2, 0, usb_z/2]) {
                        translate(board_surface_z(holder_z, board_z+arm_below_z+arm_lo_z)) {
                            #prim_round_xplate(holder_wall_t*6, usb_y, usb_z, 1, 16);
                        }
                    }
                    
                }
            }
        }
    }
}

module phatdac_arm(with_welding=1, left_cut_outs=[], right_cutouts=[],
                    with_cutout_left=0, with_cutout_right=0, with_board_part=0) {
// x,y-center of model = center of board
    // z-center of model = center of board space (i.e. board thickness + space above and below board)
    dx = with_welding*WELDING;
    dy = with_welding*WELDING;
    dz = with_welding*WELDING;
    holder_wall_ty = (holder_y - stuff_y)/2;
    holder_wall_tz = (holder_z - stuff_z)/2;
    holder_wall_tx = (holder_x - stuff_x)/2;

    translate([-dx/2, 0, 0]) {
        // materialize board space if required (this is used to remove this volume from lid)
        if (with_board_part) {
            translate([0, 0, -holder_z/2+arm_below_z+arm_lo_z+board_z/2]) {
                #cube([board_x+WELDING, board_y+WELDING, board_z+WELDING], center=true);
            }
        }
        difference() {
            union() {
                cube([stuff_x+dx, stuff_y+dy, stuff_z+dz], center=true);

            }
            union() {
                translate([arm_front_t, arm_left_t/2-arm_right_t/2, 0]) {
                    cube([board_x+WELDING, board_y-arm_left_t-arm_right_t, stuff_z*2], center=true);
                }

                // cut board space (zero)
                translate([0, 0, -holder_z/2+arm_below_z+arm_lo_z+pcb_z/2]) {
                    #cube([board_x+WELDING+10, board_y+WELDING, pcb_z], center=true);
                }
                echo (holder_z=holder_z);
                // cut board space (phat)
                translate([0, 0, -holder_z/2+arm_below_z+arm_lo_z+board_z-pcb_z/2]) {
                    #cube([board_x+WELDING+10, board_y+WELDING, pcb_z], center=true);
                }

                // cut microsd clearance
                translate([0, 0, -holder_z/2+arm_below_z+arm_lo_z+2+microsd_z/2]) {
                    #cube([board_x+WELDING+10, microsd_y+WELDING, microsd_z], center=true);
                }

                // left cut out
                if (with_cutout_left) {
                    translate(left_center(board_y, arm_left_t)) {
                        #cube([1, arm_left_t+WELDING,10], center=true);
                    }
                }

                // right cut out
                if (with_cutout_right) {
                    translate(right_center(board_y, arm_right_t)) {
                        #cube([1, arm_right_t+WELDING,10], center=true);
                    }
                }

                // top (above-arm) cut out
                translate(top_center(stuff_z, 0)) {
                    #cube([stuff_x+dx, stuff_y+dy, arm_above_z*2], center=true);
                }

                // screw hole
                translate(back_center(holder_x,0)) {
                    phatdac_screw_hole_negative_volume();
                }
            }
        }
    }
}

module phatdac_screw_hole_negative_volume() {
    for (v=[left_center(holder_y, (holder_y-board_y)/2+2.5),
            right_center(holder_y, (holder_y-board_y)/2+2.5)]) {
        translate(v) {
            translate([0, 0, -holder_z/2+arm_below_z+arm_lo_z+board_z-pcb_z-2.5-1]) {
                #screw_hole_d28_h95(align="x",volume_type="negative");
            }
        }
    }
}


// with_round = { 1: round the corners of holder's outer surface, 0: sharp (normal cube) edge. }
// with_round_inner = { 1: round the corners of holder's inner surface, 0: sharp (normal cube) edge. }
module phatdac_holder(holder_x=holder_x, holder_y=holder_y,
                      front_cutouts=holder_front_cutouts,
                      bottom_cutouts=holder_bottom_cutouts,
                      with_screw=0,
                      with_hole_front=0,
                      with_hole_bottom=1,
                      with_vent=1,
                      with_vent_top=0,
                      with_vent_bottom=1,
                      with_vent_side=1,
                      with_open_roof=1, with_open_bottom=0, with_round=0, with_round_inner=1) {

    holder_wall_ty = (holder_y - stuff_y)/2;
    holder_wall_tz = (holder_z - stuff_z)/2;
    holder_wall_tx = (holder_x - stuff_x)/2;
    
    translate([-holder_wall_t/2,0,0]) {
        difference() {
            union() {
                if (with_round) {
                    prim_round_xplate0(holder_x, holder_y, holder_z, 1, 32);
                } else {
                    cube([holder_x, holder_y, holder_z], center=true);
                }
            }
            union() {
                translate([+holder_wall_t/2+WELDING/2,0,0]) {
                    if (with_round_inner) {
                        prim_round_xplate0(stuff_x+WELDING, stuff_y, stuff_z, 1, 32);
                    } else {
                        cube([stuff_x+WELDING, stuff_y, stuff_z], center=true);
                    }
                }
            }

        }
        if (with_screw) {
            phatdac_screw(volume_type="positive");
        }
    } // translate
}

// with_round = { 1: round the corners of holder's outer surface, 0: sharp (normal cube) edge. }
// with_round_inner = { 1: round the corners of holder's inner surface, 0: sharp (normal cube) edge. }
module phatdac_holder_negative_volume(holder_x=holder_x, holder_y=holder_y,
                                           front_cutouts=holder_front_cutouts,
                                           bottom_cutouts=holder_bottom_cutouts,
                                           with_screw=0,
                                           with_hole_front=0,
                                           with_hole_bottom=1,
                                           with_vent=1,
                                           with_vent_top=1,
                                           with_vent_bottom=1,
                                           with_vent_side=1,
                                           with_open_roof=1, with_open_bottom=0, with_round=0, with_round_inner=1) {

    holder_wall_ty = (holder_y - stuff_y)/2;
    holder_wall_tz = (holder_z - stuff_z)/2;
    holder_wall_tx = (holder_x - stuff_x)/2;
    
    translate([-holder_wall_t/2,0,0]) {
        union() {
            if (with_screw) {
                #phatdac_screw(volume_type="negative");
            }

            if (with_open_roof) {
                // open roof
                translate(top_center(holder_z, holder_wall_t)) {
                    translate([holder_x/2-led_x/2,0,0]) {
                        cube([led_x, led_y, holder_wall_t+WELDING], center=true);
                    }
                }
            }
            if (with_open_bottom) {
                // open bottom
                translate(bottom_center(holder_z, holder_wall_t)) {
                    #cube([holder_x*2, holder_y*2, holder_wall_t+WELDING], center=true);
                }
            }

            // front cut outs
            if (with_hole_front) {
                translate(front_center(board_x, arm_front_t+WELDING)) {
                    translate(board_surface_z(holder_z, board_z+arm_below_z+arm_lo_z-1)) {
                        for (cutout=front_cutouts){
                            cpos_x = cutout[0];
                            cr = cutout[1];
                            translate([0, cpos_x, audiojack_r]) {
                                //#cube([arm_front_t+WELDING+WELDING, cwidth, 10], center=true);
                                rotate([0,90,0]) {
                                    #cylinder(r=audiojack_r, h=cr, $fn=16, center=true);
                                }
                            }
                        }
                    }
                }
            }
                
            // bottom cut out
            if (with_hole_bottom) {
                translate(bottom_center(holder_z, holder_wall_t)) {
                    for (cutout=bottom_cutouts) {
                        pos_x = cutout[0];
                        pos_y = cutout[1];
                        width = cutout[2];
                        translate([holder_wall_t+pos_x/2,pos_y,0]){
                            #cube([holder_x-pos_x, width, holder_wall_t+WELDING], center=true);
                        }
                    }
                }
            }

            // vent
            if (with_vent) {
                // top vent
                if (with_vent_top) {
                    translate(top_center(holder_z, holder_wall_tz)) {
                        //translate(front_center(board_x, arm_front_t+WELDING)) {
                            translate([0,0,0]) {
                                for (iy=[-5:1:5]) {
                                    translate([0, iy*5.5, 0]) {
                                        prim_round_zplate0(holder_x*0.6, 2, holder_wall_tz*2, 1, 16);
                                    }
                                }
                            }
                        //}
                    }
                }
                // bottom vent
                if (with_vent_bottom) {
                    translate(bottom_center(holder_z, holder_wall_tz)) {
                        for (iy=[-5:1:5]) {
                            translate([0, iy*5.5, 0]) {
                                prim_round_zplate0(holder_x*0.6, 2, holder_wall_tz*2, 1, 16);
                            }
                        }
                    }
                }
                // side vent
                if (with_vent_side) {
                    for (vp=[left_center(holder_y, holder_wall_ty),
                             right_center(holder_y, holder_wall_ty)]) {
                        translate(vp) {
                            for (iz=[-0.2, 0.7]) {
                                translate([0, 0, iz*4]) {
                                    //#prim_round_yplate0(holder_x*0.7, holder_wall_ty*10, 2, 1, 16);
                                }
                            }
                        }
                    }
                }
            }
        } // union
    } // translate
}

module phatdac_screw(volume_type="positive") {
    holder_wall_ty = (holder_y - stuff_y)/2;
    holder_wall_tz = (holder_z - stuff_z)/2;
    holder_wall_tx = (holder_x - stuff_x)/2;

    translate([holder_x/2,0, -holder_z/2+3]){
        for (vp=[left_center(holder_y, holder_wall_ty+4.5),
                 right_center(holder_y, holder_wall_ty+4.5)]) {
            translate(vp) {
                screw_hole_d2_h3(align="x", volume_type=volume_type,
                                 shell_x=6, shell_y=6, shell_z=holder_x-2, with_shell=1);
            }
        }
    }
}

module phatdac_lid(holder_x=holder_x, holder_y=holder_y,
                        front_cutouts=holder_front_cutouts,
                        bottom_cutouts=holder_bottom_cutouts,
                        with_screw=0,
                        with_hole_front=1,
                        with_hole_bottom=1,
                        with_vent=1,
                        with_vent_top=1,
                        with_vent_bottom=1,
                        with_vent_side=1,
                        with_vent_lid=1,
                        with_welding = 1,
                        with_open_roof=0, with_open_bottom=0, with_round=0, with_round_inner=1) {

    holder_wall_ty = (holder_y - stuff_y)/2;
    holder_wall_tz = (holder_z - stuff_z)/2;
    holder_wall_tx = (holder_x - stuff_x)/2;
    dx = with_welding*WELDING;

    difference() {
        union() {
            translate([-lid_x/2,0,0]) {
                prim_round_xplate0(lid_x, holder_y, holder_z, 1, 32);

                translate([-lid_x/2-lid_inner_x/2,0,0]) {
                    translate(board_surface_z(holder_z, pcb_z+arm_below_z+arm_lo_z)) {
                        // left lid arm
                        translate(left_center(holder_y, holder_wall_ty)) {
                            translate([0,holder_wall_ty/2+lid_arm_y/2,lid_arm_z/2]){
                                prim_round_xplate0(lid_arm_x, lid_arm_y, lid_arm_z, 1, 32);
                            }
                        }
                        // right lid arm
                        translate(right_center(holder_y, holder_wall_ty)) {
                            translate([0,-holder_wall_ty/2-lid_arm_y/2,lid_arm_z/2]){
                                prim_round_xplate0(lid_arm_x, lid_arm_y, lid_arm_z, 1, 32);
                            }
                        }
                    }

                    // bottom lid arm
                    translate(bottom_center(holder_z,holder_wall_tz*2)) {
                        translate([0,0, arm_below_z/2+WELDING]) {
                            prim_round_xplate0(lid_inner_x, board_y-arm_left_t-arm_right_t-WELDING, arm_below_z, 0.4, 32);
                        }
                    }
                }                    
            }

        }
        union() {
            translate([(stuff_x+dx)/2+lid_x,0, 0]) {
                //phatdac_arm(with_welding=1,with_board_part=1);
            }

            translate(left_center(holder_y, holder_wall_ty)) {
                translate([0, holder_wall_ty/2+microsd_dy, 0]) {
                    translate([0, 41.7, 0]) {
                        microusb_jack();
                    }
                    translate([0, 54.2, 0]) {
                        microusb_jack();
                    }
                    translate([0, 12.5, 0]) {
                        minihdmi_jack();
                    }
                }
            }

            phatdac_screw_hole_negative_volume();

            translate(board_surface_z(holder_z, pcb_z+arm_below_z+arm_lo_z)) {
                vent_area_y = holder_y*0.9;
                vent_each_y = 6;
                vent_area_y0 = (holder_y-vent_area_y)/2;
                vent_area_n = floor(vent_area_y/vent_each_y);
                vent_area_ey = vent_area_n * vent_each_y;
                vent_area_ey0 = (holder_y - vent_area_ey)/2;
                
                for (i=[3:vent_area_n-1]) {
                    translate([0,-holder_y/2+vent_area_ey0+vent_each_y/2+i*vent_each_y,8]) {
                        rotate([0,90,0])
                            #cylinder(h=holder_wall_t*6, r=2, $fn=16, center=true);
                            }
                }
            }                

            // Line Out Jack
            translate(left_center(holder_y, holder_wall_ty)) {
                translate([0, holder_wall_ty/2+dacjack_x, 0]) {
                    translate([0, dacjack_r, -holder_z/2+arm_below_z+arm_lo_z+board_z-pcb_z+dacjack_r+2]) {
                        rotate([0,90,0]) {
                            #cylinder(h=holder_wall_t*6, r=dacjack_r, $fn=16, center=true);
                        }
                    }
                }
            }
        }
    }
}

module microusb_jack() {
    translate([0, 0, microusb_z/2]) {
        translate(board_surface_z(holder_z, pcb_z+arm_below_z+arm_lo_z)) {
            #prim_round_xplate(holder_wall_t*6, microusb_y, microusb_z, 1, 16);
        }
    }
}
module minihdmi_jack() {
    translate([0, 0, minihdmi_z/2]) {
        translate(board_surface_z(holder_z, pcb_z+arm_below_z+arm_lo_z)) {
            #prim_round_xplate(holder_wall_t*6, minihdmi_y, minihdmi_z, 1, 16);
        }
    }
}
