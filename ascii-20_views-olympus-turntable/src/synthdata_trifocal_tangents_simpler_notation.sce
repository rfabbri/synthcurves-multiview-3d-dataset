// to be included in synthdata_trifocal.sce

D_1 = R_1w*D;
D_2 = R_2*D_1;
D_3 = R_3*D_1;

// Starting here we treat the 2D vectors as 3D vectors
// Apply the inverse K matrix!
size(d_1_img,2) - total_npts // sanity check: must be 0
d_1_img = [d_1_img; zeros(1,total_npts)];
d_2_img = [d_2_img; zeros(1,total_npts)];
d_3_img = [d_3_img; zeros(1,total_npts)];

// x_1_vec = inv(K)*x_1_vec;
d_1 = K\d_1_img;
d_2 = K\d_2_img;
d_3 = K\d_3_img;

tmpnorm = sqrt(sum(d_1.*d_1,1));
d_1 = d_1 ./ [tmpnorm;tmpnorm;tmpnorm;];
tmpnorm = sqrt(sum(d_2.*d_2,1));
d_2 = d_2 ./ [tmpnorm;tmpnorm;tmpnorm;];
tmpnorm = sqrt(sum(d_3.*d_3,1));
d_3 = d_3 ./ [tmpnorm;tmpnorm;tmpnorm;];


// Sanity check: projected tangents must match


// 3D parametrization relative to view 1 (ie, for g__1 = 1)
// From big notes book draft (6.2.3):


d_1_proj = zeros(3,total_npts);
ddif = zeros(1,total_npts);

for i=1:total_npts // for each of all the points in the dataset
  // Just sanity-checking that tangents project to given tangents
  d_1_proj(:,i) = D_1(:,i) - D_1(3,i)*x_1(:,i);
  d_1_proj(:,i) = d_1_proj(:,i) / norm(d_1_proj(:,i));
  ddif(i) = max(d_1(:,i) - d_1_proj(:,i));
end
disp 'tangent projection, way 1'
max(ddif)

// Y = X + eta*D (eta = 1)
y_1 = X_1 + D_1;
y_1 = y_1 ./ [y_1(3,:); y_1(3,:); y_1(3,:)];
y_2 = X_2 + D_2;
y_2 = y_2 ./ [y_2(3,:); y_2(3,:); y_2(3,:)];
y_3 = X_3 + D_3;
y_3 = y_3 ./ [y_3(3,:); y_3(3,:); y_3(3,:)];

d_proj_1_way2 = (y_1 - x_1);
d_proj_1_way2_norm = sqrt(sum(d_proj_1_way2.^2,1));
d_proj_1_way2_unit = d_proj_1_way2 ./ [d_proj_1_way2_norm;d_proj_1_way2_norm;d_proj_1_way2_norm];
disp 'tangent projection way 2 (explicit)'
max(d_proj_1_way2_unit - d_1_proj)

d_proj_2_way2 = (y_2 - x_2);
d_proj_2_way2_norm = sqrt(sum(d_proj_2_way2.^2,1));
d_proj_2_way2_unit = d_proj_2_way2 ./ [d_proj_2_way2_norm;d_proj_2_way2_norm;d_proj_2_way2_norm];
max(d_proj_2_way2_unit - d_2)

d_proj_3_way2 = (y_3 - x_3);
d_proj_3_way2_norm = sqrt(sum(d_proj_3_way2.^2,1));
d_proj_3_way2_unit = d_proj_3_way2 ./ [d_proj_3_way2_norm;d_proj_3_way2_norm;d_proj_3_way2_norm];
max(d_proj_3_way2_unit - d_3)

///   for i=1:total_npts // for each of all the points in the dataset
///     // Just sanity-checking that tangents project to given tangents
///   
///     d_1 - 
///     
///     ddif(i) = max(d_1(:,i) - d_1_proj(:,i));
///   end
///   disp 'tangent projection, way 2'
///   max(ddif)

// scalars:
//b = zeros(nviews,total_npts); // 3-vector beta 
//g = zeros(nviews,total_npts); // 3-vector gamma (scalars)
//e = zeros(nviews,total_npts); // 3-vector epsilon
//m = zeros(nviews,total_npts); // 3-vector mu

disp 'tangent equations (must be zero)'
for p=selected_point_ids

  // let us build scalars that work, using known points and cameras

  // betas for eta = 1
  b_1 = X_1(3,p) + D_1(3,p);
  b_2 = X_2(3,p) + D_2(3,p);
  b_3 = X_3(3,p) + D_3(3,p);
  
  // epsilons
  e_1 = b_1 - a(1,p);
  e_2 = b_2 - a(2,p);
  e_3 = b_3 - a(3,p);

  // gammas
  g_1 = d_proj_1_way2_norm(p);
  g_2 = d_proj_2_way2_norm(p);
  g_3 = d_proj_3_way2_norm(p);

  // mu's
  m_1 = b_1*g_1;
  m_2 = b_2*g_2;
  m_3 = b_3*g_3;
  
///   //   TANGENT EQS VIEWS 1 and 2
  e_2*x_2(:,p) + m_2*d_2(:,p) - R_2*(e_1*x_1(:,p) + m_1*d_1(:,p))
///   
///   //   TANGENT EQS VIEWS 1 and 3
///   e(2,p)*x_2(:,p) + m(2,p)*d_2(:,p) -
///   e(3,p)*x_3(:,p) + m(3,p)*d_3(:,p) -
///   R_3*(e(1,p)*x_1(:,p) + m(1,p)*d_1(:,p))
end

//  n_w_1 =norm(D_1(:,i) - D_1(3,i)*x_1_vec(:,i));
//  G = a_1(i) / n_w_1;

//  g__2(i) = G*norm(D_2(:,i) - D_2(3,i)*x2_vec(:,i))/a_2(i);
//  g__3(i) = G*norm(D_3(:,i) - D_3(3,i)*x3_vec(:,i))/a_3(i);
//  depth_gradiend_1(i) = G *D_1(3,i);
//  depth_gradiend_2(i) = G *D_2(3,i);
//  depth_gradiend_3(i) = G *D_3(3,i);
//  
// //   TANGENT EQS
//  depth_gradiend_2(i)*x2_vec(:,i) + a_2(i)*g__2(i)*d_2(:,i) -
//  R_2*(depth_gradiend_1(i)*x)1_vec(:,i) + a_1(i)*d_1(:,i))
//end



// TODO: compute area in each image and in 3D of triangle, to guarantee
// nondegeneracy


