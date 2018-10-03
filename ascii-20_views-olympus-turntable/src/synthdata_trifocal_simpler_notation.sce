cd /Users/rfabbri/lib/data/synthcurves-multiview-3d-dataset/ascii-20_views-olympus-turntable
clear all;

disp '/////////////////////////'
disp 'You should only see zeros, if all works (result of lines without semicolon).'
disp '/////////////////////////'

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



////   // last index in underscore is view, like so:
////   //    symbol_samplenumber_viewnumber
////   //    symbol__viewnumber(samplenumber)
////   //    symbol(samplenumber,viewnumber)
////   Gama_1_vec = R_1*Gama_w_vec + T_1*ones(1,size(Gama_w_vec,2));
////   Gama_2_vec = R_21*Gama_1_vec + T_21*ones(1,size(Gama_w_vec,2));
////   Gama_3_vec = R_31*Gama_1_vec + T_31*ones(1,size(Gama_w_vec,2));
////   
////   depth__1 = Gama_1_vec(3,:);
////   depth__2 = Gama_2_vec(3,:);
////   depth__3 = Gama_3_vec(3,:);
////   
////   // ---------------------------------------------------------------------
////   // CORE POINT EQUATIONS
////   // must output zero:
////   
////   // Starting here we treat the 2D points as 3D vectors
////   // Apply the inverse K matrix!
////   
////   gama__1_vec_img = [gama__1_vec_img; ones(1,size(gama__1_vec_img,2))]
////   gama__2_vec_img = [gama__2_vec_img; ones(1,size(gama__2_vec_img,2))]
////   gama__3_vec_img = [gama__3_vec_img; ones(1,size(gama__3_vec_img,2))]
////   
////   // gama__1_vec = inv(K)*gama__1_vec;
////   gama__1_vec = K\gama__1_vec_img;
////   gama__2_vec = K\gama__2_vec_img;
////   gama__3_vec = K\gama__3_vec_img;
////   
////   point_ids=[689 869 968]
////   for i=point_ids
////     depth__2(i)*gama__2_vec(:,i) - depth__1(i)*R_21*gama__1_vec(:,i) - T_21
////     depth__3(i)*gama__3_vec(:,i) - depth__1(i)*R_31*gama__1_vec(:,i) - T_31
////   end
////   
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
