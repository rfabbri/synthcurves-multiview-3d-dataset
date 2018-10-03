cd /Users/rfabbri/lib/data/synthcurves-multiview-3d-dataset/ascii-20_views-olympus-turntable
clear all;

disp '/////////////////////////'
disp 'You should only see zeros, if all works (result of lines without semicolon).'
disp '/////////////////////////'

// chose 3 arbitrary points (do multiple runs when evaluating a solver)
point_ids=[689 869 968];

// read 3 arbitrary views
x_1_vec_img=read('frame_0003-pts-2D.txt',-1,2)';
x_2_vec_img=read('frame_0011-pts-2D.txt',-1,2)';
x_3_vec_img=read('frame_0017-pts-2D.txt',-1,2)';

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

X_vec = read('crv-3D-pts.txt',-1,3)';

// Plug into equations that must be zero

//depth_ =


P_1w = K *[R_1w t_1w];

// sanity check 0: project 1st point matches supplied 2D point
proj=P_1w*[X_vec(:,1); 1]; // we are selecting only 1st point
proj=proj/proj($);
proj=proj(1:2);
x_1_vec_img(:,1);
max(abs(proj-x_1_vec_img(:,1)))  // zero

// sanity check 1: all projections to cam 1 give supplied 2D points
proj_1 = P_1w * [X_vec; ones(1,size(X_vec,2))];  // all points
proj_1 = proj_1 ./ [proj_1(3,:); proj_1(3,:); proj_1(3,:)];
proj_1 = proj_1(1:2,:);
max(abs(proj_1 - x_1_vec_img))


// First index in symbol means view, second is point
// When there is only one index, it is view (eg, X_1 is 3D point X in view 1)
// When there is no index, it is world (eg, X)
//
X_1_vec = R_1w*X_vec + t_1w*ones(1,size(X_vec,2));
X_2_vec = R_2*X_1_vec + t_2*ones(1,size(X_vec,2));
X_3_vec = R_3*X_1_vec + t_3*ones(1,size(X_vec,2));

// ---------------------------------------------------------------------
// CORE POINT EQUATIONS
// must output zero:

// Starting here we treat the 2D points as 3D vectors
// Apply the inverse K matrix!

x_1_vec_img = [x_1_vec_img; ones(1,size(x_1_vec_img,2))];
x_2_vec_img = [x_2_vec_img; ones(1,size(x_2_vec_img,2))];
x_3_vec_img = [x_3_vec_img; ones(1,size(x_3_vec_img,2))];

// x_1_vec = inv(K)*x_1_vec;
x_1_vec = K\x_1_vec_img;
x_2_vec = K\x_2_vec_img;
x_3_vec = K\x_3_vec_img;

// ground truth depth 'alpha' or abbreviate as 'a'
alpha_1 = X_1_vec(3,:);
alpha_2 = X_2_vec(3,:);
alpha_3 = X_3_vec(3,:);

for i=point_ids
  alpha_2(i)*x_2_vec(:,i) - alpha_1(i)*R_2*x_1_vec(:,i) - t_2
  alpha_3(i)*x_3_vec(:,i) - alpha_1(i)*R_3*x_1_vec(:,i) - t_3
end

////   // ---------------------------------------------------------------------
////   // TANGENT EQUATIONS
////   
////   // Read 3D tangents
////   
////   T_w_vec = read('crv-3D-tgts.txt',-1,3)';
////   t__1_vec_img=read('frame_0003-tgts-2D.txt',-1,2)';
////   t__2_vec_img=read('frame_0011-tgts-2D.txt',-1,2)';
////   t__3_vec_img=read('frame_0017-tgts-2D.txt',-1,2)';
////   
////   exec synthdata_trifocal_tangents.sce;
////   
