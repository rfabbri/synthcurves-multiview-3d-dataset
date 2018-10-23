cd /Users/rfabbri/lib/data/synthcurves-multiview-3d-dataset/ascii-20_views-olympus-turntable
clear;
format(20) // show 20 digits

disp '/////////////////////////'
disp 'You should only see zeros, if all works (result of lines without semicolon).'
disp '/////////////////////////'

// chose 3 arbitrary points (do multiple runs when evaluating a solver)
selected_point_ids=[689 2086 4968];
selected_npts = size(selected_point_ids,'*');
nviews = 3; // for semantics sake
ncoordinates = 3; // just defined this for semantic reasons

// read 3 arbitrary views. Everything is indexed as (view,coordinate,point) for
// ease of matrix multiplication the way I did it, but it makes more sense to do
// (view,point,coordinate)
x1_img = read('frame_0003-pts-2D.txt',-1,2)';
total_npts = size(x1_img,2);

x2_img = read('frame_0011-pts-2D.txt',-1,2)';
x3_img = read('frame_0017-pts-2D.txt',-1,2)';

// cameras are read with rotation and camera center in one matrix
RC1 = read('frame_0003.extrinsic',-1,3);
RC2 = read('frame_0011.extrinsic',-1,3);
RC3 = read('frame_0017.extrinsic',-1,3);

// Standard [R | t]
R1w = RC1(1:3,1:3);  // can use 0 instead of w for world coordinates
R2w = RC2(1:3,1:3);
R3w = RC3(1:3,1:3);
t1w = -R1w*RC1(4,:)'; 
t2w = -R2w*RC2(4,:)'; 
t3w = -R3w*RC3(4,:)'; 

// R and t relative to first camera
R2 = R2w*R1w';        // R2 is shorthand for R21 in this notation
t2 = -R2*t1w + t2w;

R3 = R3w*R1w';
t3 = -R3*t1w + t3w;
                 
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
X3 = R3*X1 + t3*ones(1,total_npts);

// ---------------------------------------------------------------------
// CORE POINT EQUATIONS
// must output zero:

// Starting here we treat the 2D points as 3D vectors
// Apply the inverse K matrix!


size(x2_img,2) - total_npts // sanity check, must be 0
x1_img = [x1_img; ones(1,total_npts)];
x2_img = [x2_img; ones(1,total_npts)];
x3_img = [x3_img; ones(1,total_npts)];

// x1 = inv(K)*x1;
x1 = K\x1_img;
x2 = K\x2_img;
x3 = K\x3_img;

// ground truth depth 'alpha' abbreviated as 'a'
a = zeros(nviews, total_npts);
a(1,:) = X1(3,:);
a(2,:) = X2(3,:);
a(3,:) = X3(3,:);

for p=selected_point_ids
  disp 'non-eliminated point constraint'
  a(2,p)*x2(:,p) - a(1,p)*R2*x1(:,p) - t2 // (*)
  a(3,p)*x3(:,p) - a(1,p)*R3*x1(:,p) - t3 // (**)

  // Point equations eliminating depth (essential constraint)
  disp 'essential constraint'
  x2(:,p)'*cross(t2,R2*x1(:,p))
  x3(:,p)'*cross(t3,R3*x1(:,p))

end
// beware a(3,:) is mostly zero except at the selected points

disp 'Point equations eliminating rotations'

det([cross(x2(:,selected_point_ids(1)), R2*x1(:,selected_point_ids(1))) cross(x2(:,selected_point_ids(2)), R2*x1(:,selected_point_ids(2))) cross(x2(:,selected_point_ids(3)), R2*x1(:,selected_point_ids(3)))])

det([cross(x3(:,selected_point_ids(1)), R3*x1(:,selected_point_ids(1))) cross(x3(:,selected_point_ids(2)), R3*x1(:,selected_point_ids(2))) cross(x3(:,selected_point_ids(3)), R3*x1(:,selected_point_ids(3)))])


// TODO Output to Bertini etc

// a(1,selected_point_ids)'
// a(2,selected_point_ids)'
// a(3,selected_point_ids)'
// t2
// t3
// R2'(:)
// R3'(:)


// ---------------------------------------------------------------------
// TANGENT EQUATIONS

// Read 3D tangents D and image tangents d

D = read('crv-3D-tgts.txt',-1,3)';
d1_img=read('frame_0003-tgts-2D.txt',-1,2)';
d2_img=read('frame_0011-tgts-2D.txt',-1,2)';
d3_img=read('frame_0017-tgts-2D.txt',-1,2)';

exec synthdata_trifocal_tangents_simpler_notation.sce;

