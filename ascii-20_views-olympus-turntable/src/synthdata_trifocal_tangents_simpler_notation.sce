// to be included in synthdata_trifocal.sce

D1 = R1w*D;
D2 = R2*D1;
D3 = R3*D1;

// Starting here we treat the 2D vectors as 3D vectors
// Apply the inverse K matrix!
size(d1_img,2) - total_npts // sanity check: must be 0
d1_img = [d1_img; zeros(1,total_npts)];
d2_img = [d2_img; zeros(1,total_npts)];
d3_img = [d3_img; zeros(1,total_npts)];

// x1_vec = inv(K)*x1_vec;
d1 = K\d1_img;
d2 = K\d2_img;
d3 = K\d3_img;

tmpnorm = sqrt(sum(d1.*d1,1));
d1 = d1 ./ [tmpnorm;tmpnorm;tmpnorm;];
tmpnorm = sqrt(sum(d2.*d2,1));
d2 = d2 ./ [tmpnorm;tmpnorm;tmpnorm;];
tmpnorm = sqrt(sum(d3.*d3,1));
d3 = d3 ./ [tmpnorm;tmpnorm;tmpnorm;];


// Sanity check: projected tangents must match


// 3D parametrization relative to view 1 (ie, for g__1 = 1)
// From big notes book draft (6.2.3):


d1_proj = zeros(3,total_npts);
ddif = zeros(1,total_npts);

for i=1:total_npts // for each of all the points in the dataset
  // Just sanity-checking that tangents project to given tangents
  d1_proj(:,i) = D1(:,i) - D1(3,i)*x1(:,i);
  d1_proj(:,i) = d1_proj(:,i) / norm(d1_proj(:,i));
  ddif(i) = max(d1(:,i) - d1_proj(:,i));
end
disp 'tangent projection, way 1'
max(ddif)

// Y = X + eta*D (eta = 1)
y1 = X1 + D1;
y1 = y1 ./ [y1(3,:); y1(3,:); y1(3,:)];
y2 = X2 + D2;
y2 = y2 ./ [y2(3,:); y2(3,:); y2(3,:)];
y3 = X3 + D3;
y3 = y3 ./ [y3(3,:); y3(3,:); y3(3,:)];

d_proj_1_way2 = (y1 - x1);
d_proj_1_way2_norm = sqrt(sum(d_proj_1_way2.^2,1));
d_proj_1_way2_unit = d_proj_1_way2 ./ [d_proj_1_way2_norm;d_proj_1_way2_norm;d_proj_1_way2_norm];
disp 'tangent projection way 2 (explicit)'
max(d_proj_1_way2_unit - d1_proj)

d_proj_2_way2 = (y2 - x2);
d_proj_2_way2_norm = sqrt(sum(d_proj_2_way2.^2,1));
d_proj_2_way2_unit = d_proj_2_way2 ./ [d_proj_2_way2_norm;d_proj_2_way2_norm;d_proj_2_way2_norm];
max(d_proj_2_way2_unit - d2)

d_proj_3_way2 = (y3 - x3);
d_proj_3_way2_norm = sqrt(sum(d_proj_3_way2.^2,1));
d_proj_3_way2_unit = d_proj_3_way2 ./ [d_proj_3_way2_norm;d_proj_3_way2_norm;d_proj_3_way2_norm];
max(d_proj_3_way2_unit - d3)

///   for i=1:total_npts // for each of all the points in the dataset
///     // Just sanity-checking that tangents project to given tangents
///   
///     d1 - 
///     
///     ddif(i) = max(d1(:,i) - d1_proj(:,i));
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
  b1 = X1(3,p) + D1(3,p);
  b2 = X2(3,p) + D2(3,p);
  b3 = X3(3,p) + D3(3,p);
  
  // epsilons
  e1 = b1 - a(1,p);
  e2 = b2 - a(2,p);
  e3 = b3 - a(3,p);

  // gammas
  g1 = d_proj_1_way2_norm(p);
  g2 = d_proj_2_way2_norm(p);
  g3 = d_proj_3_way2_norm(p);

  // mu's
  m1 = b1*g1;
  m2 = b2*g2;
  m3 = b3*g3;
  
  //   TANGENT EQS
  e2*x2(:,p) + m2*d2(:,p) - R2*(e1*x1(:,p) + m1*d1(:,p)) // (***)
  e3*x3(:,p) + m3*d3(:,p) - R3*(e1*x1(:,p) + m1*d1(:,p)) // (****)
  
///   
///   //   TANGENT EQS VIEWS 1 and 3
///   e(2,p)*x2(:,p) + m(2,p)*d2(:,p) -
///   e(3,p)*x3(:,p) + m(3,p)*d3(:,p) -
///   R3*(e(1,p)*x1(:,p) + m(1,p)*d1(:,p))
end

//  n_w_1 =norm(D1(:,i) - D1(3,i)*x1_vec(:,i));
//  G = a_1(i) / n_w_1;

//  g__2(i) = G*norm(D2(:,i) - D2(3,i)*x2_vec(:,i))/a_2(i);
//  g__3(i) = G*norm(D3(:,i) - D3(3,i)*x3_vec(:,i))/a_3(i);
//  depth_gradiend_1(i) = G *D1(3,i);
//  depth_gradiend_2(i) = G *D2(3,i);
//  depth_gradiend_3(i) = G *D3(3,i);
//  
// //   TANGENT EQS
//  depth_gradiend_2(i)*x2_vec(:,i) + a_2(i)*g__2(i)*d2(:,i) -
//  R2*(depth_gradiend_1(i)*x)1_vec(:,i) + a_1(i)*d1(:,i))
//end



// TODO: compute area in each image and in 3D of triangle, to guarantee
// nondegeneracy


// Output ground truth to bertini

// a11, a12, a13,
// a21, a22, a23,
// a31, a32, a33,

//a(:,selected_point_ids)


