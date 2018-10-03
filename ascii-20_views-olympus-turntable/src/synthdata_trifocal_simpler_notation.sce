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
x_1_img = read('frame_0003-pts-2D.txt',-1,2)';
total_npts = size(x_1_img,2);

x_2_img = read('frame_0011-pts-2D.txt',-1,2)';
x_3_img = read('frame_0017-pts-2D.txt',-1,2)';

// cameras are read with rotation and camera center in one matrix
RC_1 = read('frame_0003.extrinsic',-1,3);
RC_2 = read('frame_0011.extrinsic',-1,3);
RC_3 = read('frame_0017.extrinsic',-1,3);

// Standard [R | t]
R_1w = RC_1(1:3,1:3);  // can use 0 instead of w for world coordinates
R_2w = RC_2(1:3,1:3);
R_3w = RC_3(1:3,1:3);
t_1w = -R_1w*RC_1(4,:)'; 
t_2w = -R_2w*RC_2(4,:)'; 
t_3w = -R_3w*RC_3(4,:)'; 

// R and t relative to first camera
R_2 = R_2w*R_1w';        // R_2 is shorthand for R_21 in this notation
t_2 = -R_2*t_1w + t_2w;

R_3 = R_3w*R_1w';
t_3 = -R_3*t_1w + t_3w;
                 
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


P_1w = K *[R_1w t_1w];

// sanity check 0: project 1st point matches supplied 2D point
proj=P_1w*[X(:,1); 1]; // we are selecting only 1st point
proj=proj/proj($);
proj=proj(1:2);
x_1_img(:,1);
max(abs(proj-x_1_img(:,1)))  // zero

// sanity check 1: all projections to cam 1 give supplied 2D points
proj_1 = P_1w * [X; ones(1,total_npts)];  // all points
proj_1 = proj_1 ./ [proj_1(3,:); proj_1(3,:); proj_1(3,:)];
proj_1 = proj_1(1:2,:);
max(abs(proj_1 - x_1_img))


// First index in symbol means view, second is point
// When there is only one index, it is view (eg, X_1 is 3D point X in view 1)
// When there is no index, it is world (eg, X)
//
X_1 = R_1w*X + t_1w*ones(1,total_npts);
X_2 = R_2*X_1 + t_2*ones(1,total_npts);
X_3 = R_3*X_1 + t_3*ones(1,total_npts);

// ---------------------------------------------------------------------
// CORE POINT EQUATIONS
// must output zero:

// Starting here we treat the 2D points as 3D vectors
// Apply the inverse K matrix!


size(x_2_img,2) - total_npts // sanity check, must be 0
x_1_img = [x_1_img; ones(1,total_npts)];
x_2_img = [x_2_img; ones(1,total_npts)];
x_3_img = [x_3_img; ones(1,total_npts)];

// x_1 = inv(K)*x_1;
x_1 = K\x_1_img;
x_2 = K\x_2_img;
x_3 = K\x_3_img;

// ground truth depth 'alpha' abbreviated as 'a'
a = zeros(nviews, total_npts);
a(1,:) = X_1(3,:);
a(2,:) = X_2(3,:);
a(3,:) = X_3(3,:);

for p=selected_point_ids
  a(2,p)*x_2(:,p) - a(1,p)*R_2*x_1(:,p) - t_2 // (*)
  a(3,p)*x_3(:,p) - a(1,p)*R_3*x_1(:,p) - t_3 // (**)
end
// beware a(3,:) is mostly zero except at the selected points

// Output to Bertini
//
// Example:
//
// % Trifocal point case for point-tangent ids 689 2086 4968
// % TODO: make pre-tests to make sure these points are far from degenerate
// % Indexing is eg x{view}{point}{coordinate}
//
// % INPUT data: 3 points and tangents
// constant x111 x112 x113 ... x333
// constant d111 d112 ... d332
//
// % Set these inputs: 
// % scilab: x_1(:,selected_point_ids(1))
// x111 = -0.01609589159371727;
// x112 = 0.0861548623366261;
// x113 = 1:
//
// x121 = -0.01421529931862033;
// x122 = 0.15164819506961155;
// x123 = 1;
//
// x131 = 0.0155829286858466;
// x132 = 0.12352302780175817;
// x133 = 1;
//
// x211 = 0.01389192462875502;
// x212 = 0.08595606183440178;
// x213 = 1;
//
// x221 = 0.0137394337121674;
// x222 = 0.1515915437407269;
// x223 = 1;
//
// x231 = 0.02520938938602093;
// x232 = 0.12793300445393241;
// x233 = 1;
//
// x311 = 0.03177299989757976;
// x312 = 0.08899413323286663;
// x313 = 1;
//
// x321 = 0.03004852302129869;
// x322 = 0.15543598064788686;
// x323 = 1;
//
// x331 = 0.02150970592535596;
// x332 = 0.13169055919273559;
// x333 = 1:


// 
// % Variables
// % Translation and depths are a homogeneous group in each eq
// %
// % -------------------
// % Point Equations
// % First set of three equations from the first vector point equation (*) above
// %% Point 1
// hom_variable_group a11, a21, t21, % TODO: eliminate dups
//                    a11, a21, t22,
//                    a11, a21, t23,
// %% Point 2
// a12, a22, t21,
// a12, a22, t22,
// a12, a22, t23,
//
// %% Point 3
// a13, a23, t21,
// a13, a23, t22,
// a13, a23, t23,
//
// % Second set of three equations per point from (*) above
// %% Point 1,
// a11, a31, t31,
// a11, a31, t32,
// a11, a31, t33,
//
// %% Point 2,
// a12, a32, t31,
// a12, a32, t32,
// a12, a32, t33,
//
// %% Point 3,
// a13, a33, t31,
// a13, a33, t32,
// a13, a33, t33;
//
// % Rotations
// % try different parametrizations for rotations. Lets try standard
//
// variable_group 
// r211, r212, r213,
// r221, r222, r223,
// r231, r232, r233,
//
// r311, r312, r313,
// r321, r322, r323,
// r331, r332, r333;
// % ---------------------------------------------------------------------
//
// Point equation (*), coordinate 1, point 1
// a21*x211 + a11*r211*x111 + a11*r212*x12 + // and so on..
//
//
// Equations
//
//  a(2,p)*x_2(:,p) - a(1,i)*R_2*x_1(:,i) - t_2 // (*)
//  a(3,i)*x_3(:,i) - a(1,i)*R_3*x_1(:,i) - t_3 // (**)


// ---------------------------------------------------------------------
// TANGENT EQUATIONS

// Read 3D tangents D and image tangents d

D = read('crv-3D-tgts.txt',-1,3)';
d_1_img=read('frame_0003-tgts-2D.txt',-1,2)';
d_2_img=read('frame_0011-tgts-2D.txt',-1,2)';
d_3_img=read('frame_0017-tgts-2D.txt',-1,2)';

exec synthdata_trifocal_tangents_simpler_notation.sce;

