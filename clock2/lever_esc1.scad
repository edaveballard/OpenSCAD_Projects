/*
Clock Lever Escapement
by Dave Ballard
Sep 29, 2022

*/                                                                     

//as a rule, apply clearances to holes, not shafts
clearance_press = 0.1;
clearance_firm = 0.2;
clearance_loose = 0.4;
        
escWheel(15,20);                                                                                           
module keyShaft(h, r, cut = 0.25, cut_end = 0) {
    cut_z = cut_end < 0.01 ? 0 : 1.5*h+cut_end;
        
    difference() {
        cylinder(h,r,r,$fn=90);
        translate([2*r*(1-cut),0,cut_z])
            cube([r*2,r*2,h*3], center=true);
    }
}

module balanceWheel(ring_r, height = 3,  spokes = 3, spokewidth = 1.5, hub_r = 4, ring_w = 1){
    
    union() {
        cylinder(height, hub_r, hub_r, $fn=90);
        for(i=[0:spokes-1])
            rotate([0,0,i*360/spokes])
                translate([hub_r/2,-spokewidth/2,0])
                    cube([ring_r-ring_w/2-hub_r/2, spokewidth, height],  center=false);
        difference() {
                cylinder(height, ring_r, ring_r, $fn=90);
                cylinder(height*3,ring_r-ring_w,ring_r-ring_w, center=true, $fn=90);
        }
    }
}

module hairSpring(spacing, height, thickness, loops)
    linear_extrude(height=height) polygon(points= concat(
        [for(t = [90:360*loops]) 
            [(-thickness+spacing*t/90)*sin(t),(-thickness+spacing*t/90)*cos(t)]],
        [for(t = [360*loops:-1:90]) 
            [(spacing*t/90)*sin(t),(spacing*t/90)*cos(t)]]
            ));
        

module escWheel(teeth, ring_r, height = 3,  spokes = 3, spokewidth = 1.5, hub_r = 4, ring_w = 3){
    union() {
        balanceWheel(ring_r, height, spokes, spokewidth, hub_r, ring_w);
        for(i=[0:teeth-1])
            rotate([0,0,360*i/teeth])
            translate([ring_r-ring_w/2,0,0]) rotate([0,0,-30])  
                union() { 
                    cube([10,2,height]);
                    translate([10,0,0]) rotate([0,0,90]) cube([3,1,3]);
                }
    }
}

*translate([0,0,-2])
    union() {
        hairSpring(1.5, 1.5, 1, 5);
        difference() {
            keyShaft(5,2, cut_end=2);
            translate([0,0,-1]) cylinder(7,0.3,0.3);
        }
        translate([0,30-1,0]) cube([6,12,1.5]);
    }
    
//animation
*rotate([0,0,sin(360*$t)*90])
    union(){
        difference() {
            balanceWheel(30, 3, 3, 1.5, 4, 5);
            translate([0,0,-1])
                keyShaft(5,2+clearance_firm);
        }
        translate([8,0,3])
            cylinder(3,1,1, $fn=90);
    }
