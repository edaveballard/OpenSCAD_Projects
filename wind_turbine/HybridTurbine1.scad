/*
Darrieus Ugrinksy Hybrid Helical Wind Turbine
by Dave Ballard
Sep 12, 2022

A helical Darrieus/Ugrinsky hybrid wind turbine.

The Darrieus turbine uses lift and is efficient at higher wind speeds.
The Ugrinsky turbine uses drag and works at low wind speed.

Normally Darrieus turbines need a starting mechanism to begin working, but the Ugrinsky can serve that purpose when they are combined.

The helical shape allows the turbine to experience more uniform torque through its entire rotation, which can reduce vibrations and the stress on parts and avoid any "dead" angles where the turbine fails to start because of how it is oriented relative to the wind.

The Darrieus uses four s1046 airfoils.
*/


//Turbine General Parameters
height = 130;                   //total height of the turbine
base_thickness= 1;              //thickness of the top and bottom pieces
axle_radius = 3;                //radius of the axle going through the center of the turbine

//Ugrinsky (Inner) Parameters
ugrinksy_radius = 27;           //radius of the inner turbine section
ugrinsky_thickness = 0.5;       //thickness of inner turbine surfaces

//Darrieus (Outer) Parameters
airfoil_length = 25;            //cross-sectional size of Darrieus blades (width scales with length)
darrieus_radius = 62;           //radius of the outer turbine section
darrieus_spokes = 4;            //number of Darrieus blades



//Radius check
//color("#FF0000") linear_extrude(1) arc(ugrinksy_radius,[0,360],ugrinsky_thickness);
//color("#00FF00") linear_extrude(1) arc(darrieus_radius,[0,360],ugrinsky_thickness);


//Build the turbine
union() {
    //Ugrinsky
    linear_extrude(height,twist=180) ugrinsky(ugrinksy_radius, ugrinsky_thickness,$fn=100);
    //Darrieus
    linear_extrude(height,twist=(360/darrieus_spokes),$fn=100) darrieus(darrieus_radius,darrieus_spokes,airfoil_length);
    //Top and bottom pieces
    for(z = [0,height-base_thickness]) {
        translate([0,0,z]) difference() {
                union() {
                    //hub
                    cylinder(base_thickness, ugrinksy_radius+0.5*ugrinsky_thickness,ugrinksy_radius+0.5*ugrinsky_thickness);
                    //spokes
                    for(theta = [0:(360/darrieus_spokes):360]) {
                        rotate([0,0,theta]) translate([-0.25*airfoil_length,0,0]) cube([0.5*airfoil_length, darrieus_radius, base_thickness]);
                    }
                }
                //axle hole
                translate([0,0,-1*base_thickness]) cylinder(3*base_thickness,axle_radius,axle_radius,$fn=24);
        }
    }
}

//Draw the 2D shape of the Ugrinsky surfaces
//https://vawt.ro/page/3/
module ugrinsky(radius, thickness) {
        for(i = [0,1]) {
            rotate([0,0,180*i]) union() {
                translate([0.6*radius,0,0]) arc(0.4*radius, [0,180], thickness, 60);
                translate([-0.8*radius,0,0]) arc(radius, [-67,0], thickness, 60);
            }
        }

}

//Create the Darrieus turbine blades (airfoils)
module darrieus(radius, spokes, airfoil_size, airfoil_offset=0.3) {
    for(theta = [0:(360/spokes):360]) {
        rotate([0,0,theta]) translate([-airfoil_offset*airfoil_size,radius,0]) s1046_airfoil(airfoil_size);
    }
}

//https://openhome.cc/eGossip/OpenSCAD/SectorArc.html
module sector(radius, angles, fn = 24) {
    r = radius / cos(180 / fn);
    step = -360 / fn;

    points = concat([[0, 0]],
        [for(a = [angles[0] : step : angles[1] - 360]) 
            [r * cos(a), r * sin(a)]
        ],
        [[r * cos(angles[1]), r * sin(angles[1])]]
    );

    difference() {
        circle(radius, $fn = fn);
        polygon(points);
    }
}

//https://openhome.cc/eGossip/OpenSCAD/SectorArc.html
//modified to center the circle in the arc
module arc(radius, angles, width = 1, fn = 24) {
    difference() {
        sector(radius + 0.5*width, angles, fn);
        sector(radius - 0.5*width, angles, fn);
    }
} 

//Draw an S1046 airfoil
//https://m-selig.ae.illinois.edu/ads/coord_database.html
//https://m-selig.ae.illinois.edu/ads/coord/s1046.dat
module s1046_airfoil(length) {
    s1046 = [[1.00000,0.00000],[0.99616,0.00022],[0.98513,0.00134],[0.96778,0.00347],[0.94451,0.00634],[0.91556,0.01001],[0.88146,0.01459],[0.84282,0.02007],[0.80030,0.02639],[0.75460,0.03341],[0.70644,0.04097],[0.65656,0.04882],[0.60571,0.05665],[0.55447,0.06395],[0.50324,0.07044],[0.45251,0.07597],[0.40277,0.08035],[0.35450,0.08339],[0.30811,0.08495],[0.26398,0.08492],[0.22247,0.08324],[0.18385,0.07984],[0.14834,0.07476],[0.11614,0.06815],[0.08745,0.06017],[0.06246,0.05106],[0.04136,0.04107],[0.02431,0.03052],[0.01149,0.01974],[0.00306,0.00925],[0.00000,0.00000],[0.00306,-0.00925],[0.01149,-0.01974],[0.02431,-0.03052],[0.04136,-0.04107],[0.06246,-0.05106],[0.08745,-0.06017],[0.11614,-0.06815],[0.14834,-0.07476],[0.18385,-0.07984],[0.22247,-0.08324],[0.26398,-0.08492],[0.30811,-0.08495],[0.35450,-0.08339],[0.40277,-0.08035],[0.45251,-0.07597],[0.50324,-0.07044],[0.55447,-0.06395],[0.60571,-0.05665],[0.65656,-0.04882],[0.70644,-0.04097],[0.75460,-0.03341],[0.80030,-0.02639],[0.84282,-0.02007],[0.88146,-0.01459],[0.91556,-0.01001],[0.94451,-0.00634],[0.96778,-0.00347],[0.98513,-0.00134],[0.99616,-0.00022],[1.00000,0.00000]];
    polygon(length*s1046);
}