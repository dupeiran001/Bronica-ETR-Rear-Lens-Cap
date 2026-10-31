/*
  Bronica ETR / ETRS / ETRSi rear lens cap — v4 L-STOP BAYONET — knurled exterior + engraved logo
  Original design 2026-10-30.  Fit-variant release 2026-10-30.
  Independently designed; dimensions NOT OEM spec.

  REFERENCE FACTS:
   - ETR: 4-claw bayonet (Bronica instruction manual)
   - 81.59 mm OD, 21.95 mm H from one published third-party STL envelope
     (WIDE variant enlarges OD to 83.6 for printable wall thickness)
   - Japanese ETR printed adapter: red ring OD82, black OD79.6,
     both height7. Those ARE ADAPTER PART dimensions, NOT lens lug measurements!
   - OEM / printed examples show 4 near-rim retaining features roughly 90deg apart

  v4 retains the v3 four L-shaped engagement channels: axial-entry gaps, circumferential
  retaining lips and a positive downward end stop on each lip. No endless rotation.

  USER FIT REPORT: Standard geometry was tested on a Bronica ETR 150mm lens.
  Slightly_loose is a new untested variation (+0.30mm on diameters).
  Geometry remains independently estimated, not from an OEM drawing.
  FIRST PRINT A TEST RING for any untested lens or printer.
  Do not force near delicate lens shutter linkage pins or rear glass.

  Intended FDM orientation: flat bottom of full cap / lower rim of test ring on bed.
  The inner undercuts ramp in with Z to limit unsupported overhangs.
*/
$fn=160;
part="full_cap";  // ["full_cap", "test_ring"]
fit="standard";   // ["standard", "slightly_loose", "safe", "wide", "snug"]
lock_direction="clockwise"; // ["clockwise", "counterclockwise"] viewed into cap

OD=fit == "wide" ? 83.6 : 81.59;
H=21.95;
base_t=2.90;
// Inferred from lens/rear-cap photos; NOT measured OEM dimensions.
bore_d= fit == "wide" ? 79.8 : fit == "safe" ? 78.6 : fit == "slightly_loose" ? 78.30 : fit == "snug" ? 77.4 : 78.0;
lip_tip_d= fit == "wide" ? 75.6 : fit == "safe" ? 74.8 : fit == "slightly_loose" ? 74.30 : fit == "snug" ? 73.2 : 74.0;
R=OD/2;
Ri=bore_d/2;
Rt=lip_tip_d/2;

// 4 equally-spaced pairs (as pictured) — angular datum is arbitrary.
lip_start=16;   // lip from 16 deg to 47 deg
lip_span=31;
stop_start=21;  // stop from 21 to 26 deg, inside the lip near locking end
stop_span=5;

// z=0 is outside flat base of the closed cap; +z faces lens.
// Slot entry at top Z=21.95; locking lip near mouth.
lip_root_z=17.90;  // lip undercut begins at outer wall
lip_tip_under_z=20.10; // inner underside, reached through gentle printable ramp
lip_top_z=21.34; // lip top: 0.61 mm beneath mouth edge
stop_root_z=16.30; // stop protrudes deeper than the lip so a claw cannot pass
stop_tip_under_z=18.95; // stop nose underside
stop_top_z=21.34;

// A low-waste calibration coupon whose L geometry matches the full cap.
ring_bottom_z=14.80;
assert(OD>bore_d+2.6, "Too thin a wall for robust FDM printing");
assert(Ri>Rt+1.55 && Ri-Rt<2.30, "Lip radial reach unexpected");
assert(lip_start<stop_start && stop_start+stop_span<lip_start+lip_span);
assert(H>lip_top_z);

// Sweep a radial/axial profile through a sector; theta offset starts in xy+X.
module sector_profile(a_start,a_end,verts){
 rotate([0,0,a_start])
 rotate_extrude(angle=a_end-a_start, convexity=6, $fn=60)
   polygon(verts);
}

module exterior(){
 if(part=="full_cap") {
  union(){
   cylinder(r=R,h=base_t);
   translate([0,0,base_t-.08])
     difference(){
       cylinder(r=R,h=H-base_t+.08);
       translate([0,0,-.1]) cylinder(r=Ri,h=H-base_t+.28);
     }
  }
 } else {
  translate([0,0,ring_bottom_z])
    difference(){
      cylinder(r=R,h=H-ring_bottom_z);
      translate([0,0,-.1]) cylinder(r=Ri,h=H-ring_bottom_z+.2);
    }
 }
}

// The horizontal part of each L track: retaining shelf.
// The sloping underside is designed for support-free upside-open printing.
module lip(s,e){
  sector_profile(s,e,[
     [Ri+.18, lip_root_z],
     [Ri-.12, lip_root_z],
     [Rt+.32, lip_tip_under_z-.32],
     [Rt, lip_tip_under_z],
     [Rt, lip_top_z],
     [Rt+.25, lip_top_z+.25],
     [Ri+.18, lip_top_z+.25]
   ]);
}

// The vertical part: POSITIVE anti-overtravel wall at closed end of L.
// This wall descends 1.6 mm farther than shelf root and is thick enough in
// the circumferential direction to resist gentle hand torque.
module stop_bar(s,e){
  sector_profile(s,e,[
     [Ri+.18, stop_root_z],
     [Ri-.12, stop_root_z],
     [Rt+.36, stop_tip_under_z-.30],
     [Rt, stop_tip_under_z],
     [Rt, stop_top_z],
     [Ri+.18, stop_top_z]
   ]);
}

module geometry(){
  union(){
   exterior();
   for(i=[0:3]) {
     a=i*90;
     // Mirror location of stop if cap twist direction is changed.
     if(lock_direction=="clockwise") {
       lip(a+lip_start,a+lip_start+lip_span);
       stop_bar(a+stop_start,a+stop_start+stop_span);
     } else {
       lip(a+lip_start,a+lip_start+lip_span);
       stop_bar(a+lip_start+lip_span-(stop_start-lip_start)-stop_span,
                a+lip_start+lip_span-(stop_start-lip_start));
     }
   }
  }
}

// ======================== OUTER SURFACE DESIGN (v4) ========================
// Perimeter of the mount is identical to v3. The grip is entirely OUTSIDE
// the original 81.59mm cylindrical body (peak raises OD by 0.95mm).
// Do not modify lip(), stop_bar(), or fit values to change decoration.
knurl_n=104;           // 104 flat-crested fine axial ribs
knurl_rise=0.48;       // mm maximum added radius, never reduces wall thickness
knurl_valley=0.045;    // valley keeps original tube solid
knurl_z0=2.0;          // leave clean bottom perimeter
knurl_z1=19.40;        // leave clean top lip

engrave_depth=0.68;    // engraving into exterior bottom z=0, bed side
border_r=34.40;
border_width=0.52;

// 4 vertices per period, deliberately leaving a low valley and flattened ridge
function knurl_contour() =
 [for (i=[0:knurl_n-1], j=[0:3])
   let(a=(i+(j==0?0:j==1?0.23:j==2?0.66:0.84))/knurl_n*360,
       rr=R+(j==1 || j==2 ? knurl_rise : knurl_valley))
   [rr*cos(a), rr*sin(a)] ];
module side_grip() {
 translate([0,0,knurl_z0])
   linear_extrude(height=knurl_z1-knurl_z0, convexity=10)
     difference(){
       polygon(points=knurl_contour());
       circle(r=R-0.24);
     }
}

// Artwork SVGs are actual curves (not text linked to a font), using an
// original Bronica-style serif mark and a star inside O; independent ETR mark.
// Keep both SVG files in the same directory as this SCAD project.
// X mirror is intentional: mark is engraved on z=0 outer face,
// and must read correctly when viewed from outside (-Z).
module exterior_engraving(){
 translate([0,0,-0.035]) {
   // Engraved circular bezel line
   linear_extrude(height=engrave_depth+0.035)
       difference(){circle(r=border_r);circle(r=border_r-border_width);}
   // Wordmark and ETR are separate and can be moved / replaced independently
   linear_extrude(height=engrave_depth+0.035)
       mirror([1,0,0]) translate([-38,-114]) import("zenza_bronica_logo.svg", center=false);
   linear_extrude(height=engrave_depth+0.035)
       mirror([1,0,0]) translate([-38,-114]) import("etr_subtitle.svg", center=false);
   // Two small horizontal accent bars alongside ETR
   for(s=[-1,1])
     translate([s*16.8,-12.7,0]) cube([12.0,0.42,engrave_depth+0.035],center=true);
 }
}

if(part=="test_ring")
 translate([0,0,-ring_bottom_z]) geometry();
else
 difference(){
   union(){geometry();side_grip();}
   exterior_engraving();
 }
