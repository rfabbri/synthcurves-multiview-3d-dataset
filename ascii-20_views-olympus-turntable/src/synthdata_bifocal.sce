cd /Users/rfabbri/lib/data/synthcurves-multiview-3d-dataset/ascii-20_views-olympus-turntable
clear;
format(20) // show 20 digits

disp '/////////////////////////'
disp 'You should only see zeros, if all works (result of lines without semicolon).'
disp '/////////////////////////'

// chose 3 arbitrary points (do multiple runs when evaluating a solver)
selected_point_ids=[689 2086 4968 1029 3050];
selected_npts = size(selected_point_ids,'*');
nviews = 3; // for semantics sake
ncoordinates = 3; // just defined this for semantic reasons

// read 3 arbitrary views. Everything is indexed as (view,coordinate,point) for
// ease of matrix multiplication the way I did it, but it makes more sense to do
// (view,point,coordinate)
x1_img = read('frame_0003-pts-2D.txt',-1,2)';
total_npts = size(x1_img,2);

x2_img = read('frame_0011-pts-2D.txt',-1,2)';

// cameras are read with rotation and camera center in one matrix
RC1 = read('frame_0003.extrinsic',-1,3);
RC2 = read('frame_0011.extrinsic',-1,3);

// Standard [R | t]
R1w = RC1(1:3,1:3);  // can use 0 instead of w for world coordinates
R2w = RC2(1:3,1:3);
t1w = -R1w*RC1(4,:)'; 
t2w = -R2w*RC2(4,:)'; 

// R and t relative to first camera
R2 = R2w*R1w';        // R2 is shorthand for R21 in this notation
t2 = -R2*t1w + t2w;
                 
// calibration matrix / intrinsic parameters
K = read('calib.intrinsic',-1,3);
                 
// Compute ground-truth scalars epsilon and mu analytically

// Notice depths, depth derivatives and speeds are invariant to coordinate
// changes system

// 
// Approach 3C: Transform everything relative to cam 1


// === Specific points =====================
//

// Read 3D points

X = read('crv-3D-pts.txt',-1,3)';

// Plug into equations that must be zero

//depth_ =


P_1w = K *[R1w t1w];

// sanity check 0: project 1st point matches supplied 2D point
proj=P_1w*[X(:,1); 1]; // we are selecting only 1st point
proj=proj/proj($);
proj=proj(1:2);
x1_img(:,1);
max(abs(proj-x1_img(:,1)))  // zero

// sanity check 1: all projections to cam 1 give supplied 2D points
proj_1 = P_1w * [X; ones(1,total_npts)];  // all points
proj_1 = proj_1 ./ [proj_1(3,:); proj_1(3,:); proj_1(3,:)];
proj_1 = proj_1(1:2,:);
max(abs(proj_1 - x1_img))


// First index in symbol means view, second is point
// When there is only one index, it is view (eg, X1 is 3D point X in view 1)
// When there is no index, it is world (eg, X)
//
X1 = R1w*X + t1w*ones(1,total_npts);
X2 = R2*X1 + t2*ones(1,total_npts);

// ---------------------------------------------------------------------
// CORE POINT EQUATIONS
// must output zero:

// Starting here we treat the 2D points as 3D vectors
// Apply the inverse K matrix!


size(x2_img,2) - total_npts // sanity check, must be 0
x1_img = [x1_img; ones(1,total_npts)];
x2_img = [x2_img; ones(1,total_npts)];

// x1 = inv(K)*x1;
x1 = K\x1_img;
x2 = K\x2_img;

// ground truth depth 'alpha' abbreviated as 'a'
a = zeros(nviews, total_npts);
a(1,:) = X1(3,:);
a(2,:) = X2(3,:);

for p=selected_point_ids
  a(2,p)*x2(:,p) - a(1,p)*R2*x1(:,p) - t2 // (*)
end
// beware a(3,:) is mostly zero except at the selected points

// TODO Output to Bertini etc


disp 'Point equations eliminating rotations'

det([cross(x2(:,selected_point_ids(1)), R2*x1(:,selected_point_ids(1))) cross(x2(:,selected_point_ids(2)), R2*x1(:,selected_point_ids(2))) cross(x2(:,selected_point_ids(3)), R2*x1(:,selected_point_ids(3)))])

psi = atan(R2(3,2),R2(3,3));
phi = atan(-R2(3,1), norm(R2(3,2:3)))
theta = atan(R2(2,1),R2(1,1))

c1 = cos(theta);
s1 = sin(theta);
c2 = cos(phi);
s2 = sin(phi);
c3 = cos(psi);
s3 = sin(psi);

R2_tst =  [c1*c2  c1*s2*s3 - c3*s1  s1*s3 + c1*c3*s2
c2*s1  c1*c3 + s1*s2*s3  c3*s1*s2 - c1*s3
-s2  c2*s3  c2*c3];


t2hat = t2/norm(t2);
alpha = asin(t2hat(3));
bbeta = atan(t2hat(2),t2hat(1));

c4 = cos(alpha);
s4 = sin(alpha);
c5 = cos(bbeta);
s5 = sin(bbeta);
rho = norm(t2);

t2_tst = rho*[c4*c5; c4*s5; s4];

cs=[c1
 s1
 c2
 s2
 c3
 s3
 c4
 s4
 c5
 s5];


for p=selected_point_ids
  // a(2,p)*x2(:,p) - a(1,p)*R2*x1(:,p) - t2 // (* sincos version)
 disp 'point'
  
//  x1(2,p)*c1*c3*c4*c5+ x2(2,p)*c2*c3*c4*c5- x2(2,p)*x1(1,p)*c4*c5*s2- x2(2,p)*x1(1,p)*c1*c2*s4+ x1(2,p)*x2(1,p)*c1*c3*s4- x1(2,p)*x2(1,p)*c2*c4*s3*s5- x1(2,p)*c4*c5*s1*s3*s2+ x1(2,p)*c1*c4*s3*s5*s2- x2(2,p)*c1*c3*s4*s2- x1(2,p)*x2(2,p)*c1*s3*s4*s2- x1(2,p)*c3*c4*s1*s5+ x1(2,p)*x2(2,p)*c2*c4*c5*s3+ x1(2,p)*x2(2,p)*c3*s1*s4+ x2(1,p)*c3*s1*s4*s2+ x1(1,p)*x2(1,p)*c4*s5*s2- x1(1,p)*c2*c4*c5*s1+ x1(1,p)*c1*c2*c4*s5- x2(1,p)*c1*s3*s4- x2(1,p)*c2*c3*c4*s5+ x1(1,p)*x2(1,p)*c2*s1*s4-c3*c4*c5*s1*s2+c1*c3*c4*s5*s2+c1*c4*c5*s3+c4*s1*s3*s5+ x1(2,p)*x2(1,p)*s1*s3*s4*s2- x2(2,p)*s1*s3*s4
 
    (c4*c5 - s4*x2(1,p))*(-s2*x1(1,p)*x2(2,p) + c2*s3*x1(2,p)*x2(2,p) + c2*c3*x2(2,p)-c2*s1*x1(1,p) - c1*c3*x1(2,p) - s1*s2*s3*x1(2,p) - c3*s1*s2 + c1*s3) + (s4*x2(2,p) - c4*s5) * (-s2*x1(1,p)*x2(1,p) + c2*s3*x1(2,p)*x2(1,p) + c2*c3*x2(1,p) - c1*c2*x1(1,p) - c1*s2*s3*x1(2,p) + c3*s1*x1(2,p) - s1*s3-c1*c3*s2)


disp 'distrib'
    
-x1(2,p)*c1*c3*c4*c5 +x2(2,p)*c2*c3*c4*c5 -x2(2,p)*x1(1,p)*c4*c5*s2 -x2(2,p)*x1(1,p)*c1*c2*s4 +x1(2,p)*x2(1,p)*c1*c3*s4 -x1(2,p)*x2(1,p)*c2*c4*s3*s5 -x1(2,p)*c4*c5*s1*s3*s2 +x1(2,p)*c1*c4*s3*s5*s2 -x2(2,p)*c1*c3*s4*s2 -x1(2,p)*x2(2,p)*c1*s3*s4*s2 -x1(2,p)*c3*c4*s1*s5 +x1(2,p)*x2(2,p)*c2*c4*c5*s3 +x1(2,p)*x2(2,p)*c3*s1*s4 +x2(1,p)*c3*s1*s4*s2 +x1(1,p)*x2(1,p)*c4*s5*s2 -x1(1,p)*c2*c4*c5*s1 +x1(1,p)*c1*c2*c4*s5 -x2(1,p)*c1*s3*s4 -x2(1,p)*c2*c3*c4*s5 +x1(1,p)*x2(1,p)*c2*s1*s4 -c3*c4*c5*s1*s2 +c1*c3*c4*s5*s2 +c1*c4*c5*s3 +c4*s1*s3*s5 +x1(2,p)*x2(1,p)*s1*s3*s4*s2 -x2(2,p)*s1*s3*s4
  
 
end
