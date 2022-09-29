
/*
Involute Herringbone Gear Library
by Dave Ballard
Sep 29, 2022

Sources:
https://www.tec-science.com/mechanical-power-transmission/involute-gear/calculation-of-involute-gears/
https://www.engineersedge.com/gears/involute-gear-design.htm


TODO:
-implement clearances for all part surfaces
-confirm whether helical gears require any other modified values
-better undercut method
-chamfer corners of gear teeth?
-Cut out gear center (add spokes, hub) to reduce weight/material
-add center-distance calculator function
*/

//herringbone_involute_gear(30,0.7,1,40);

//Calculate the center distance for two gears
//function helical_involute_center_distance(mod, teeth1, teeth2, //pressure_angle=20,  helix_angle=0) = 0;

//Create a herringbone gear
//Unlike with a helical gear, the helix angle can be as high as 45 degrees, as the symmetric nature of the teeth cancels any axial thrust force on the gear
module herringbone_involute_gear(teeth, mod, thickness, helix_angle=25, pressure_angle=20, center=0) {
    translate([0,0,(1-center)*thickness/2]) union() {
        helical_involute_gear(teeth,mod,thickness/2,helix_angle,pressure_angle);
        mirror([0,0,-1]) helical_involute_gear(teeth,mod,thickness/2,helix_angle,pressure_angle);
    }
}

//Create a helical gear
//Please note that helix_angle should not exceed about 25 degrees because of the axial thrust forces applied to the gears at higher angles
module helical_involute_gear(teeth, mod, thickness, helix_angle=20, pressure_angle=20) {
    base_circle_radius = teeth*mod*cos(pressure_angle)/2;
    twist_angle = 2*asin(thickness*tan(helix_angle)/(2*base_circle_radius));
    linear_extrude(thickness, twist=twist_angle) involute_gear(teeth, mod, pressure_angle);
}

//Create a 2D involute gear profile, with undercut and tip shortened
module involute_gear(teeth, mod, pressure_angle=20) {
    base_circle_radius = teeth*mod*cos(pressure_angle)/2;
    outside_radius = teeth*mod/2+mod;
    angle_shift = 360/teeth;
    difference() {
        intersection() {
            circle(outside_radius);
            involute_gear_uncut(teeth, mod, pressure_angle);
        }
        for(i = [0:teeth]) {
            rotate(angle_shift*(i-0.25)) translate([base_circle_radius,0,0]) circle(0.75*mod,$fn=90);
        }
    }
}

//Create a 2D involute gear profile, without the undercut or tip shortening
module involute_gear_uncut(teeth, mod, pressure_angle=20) {
    base_circle_radius = teeth*mod*cos(pressure_angle)/2;
    angle_shift = 360/teeth;
    union() {
        circle(base_circle_radius);
        for(i = [0:teeth]) {
            rotate(i*angle_shift) involute_gear_tooth(teeth, mod, pressure_angle);
        }
    }
}


//Create a single gear tooth
module involute_gear_tooth(teeth, mod, pressure_angle=20) {
    base_circle_radius = teeth*mod*cos(pressure_angle)/2;
    angle_shift = 180/teeth;

    intersection() {
        polygon([for(i = [0:1:250])circle_involute_xy(base_circle_radius,i,start_angle=0, direction=1)]);
        polygon([for(i = [-angle_shift:1:250-angle_shift])circle_involute_xy(base_circle_radius,i,start_angle=-angle_shift, direction=-1)]);
    }
    
}

//Get the point at <angle> of the involute of a circle of radius <radius>
//Start angle is the angle of intersection
//Direction: 1=counter-clockwise -1=clockwise
//Note that when constructing the involute, you should start with angle=start_angle, not angle=0
function circle_involute_xy(radius, angle, start_angle=0, direction=1) =
[
    radius*(
        cos(direction*angle) + 
        (direction*(PI/180)*(angle-start_angle))*sin(direction*(angle))), 
    radius*(
        sin(direction*angle) - 
        (direction*(PI/180)*(angle-start_angle))*cos(direction*(angle))
    )
];