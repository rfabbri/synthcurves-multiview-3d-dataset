syms x111 x112 x121 x122 x131 x132 x141 x142 x151 x152 x211 x212 x221 x222 x231 x232 x241 x242 x251 x252 c1 s1 c2 s2 c3 s3 r211 r212 r213 r221 r222 r223 r231 r232 r233;

x1 = [...
x111 x121 x131 x141   
x112 x122 x132 x142   
1     1   1    1];

x2 = [...
x211 x221 x231 x241   
x212 x222 x232 x242   
1     1   1    1];


r211 = c1*c2;
r212 = c1*s2*s3 - c3*s1;
r213 = s1*s3 + c1*c3*s2;
r221 = c2*s1;
r222 = c1*c3 + s1*s2*s3;
r223 = c3*s1*s2 - c1*s3;
r231 = -s2;
r232 = c2*s3;
r233 = c2*c3;

R2 = [...
r211 r212 r213
r221 r222 r223
r231 r232 r233];

dt = det([cross(x2(:,1), R2*x1(:,1)) cross(x2(:,2), R2*x1(:,2)) cross(x2(:,3), R2*x1(:,3))])


feval(symengine, 'degree', dt)
size(children(dt))

fid = fopen('a.txt', 'wt');
fprintf(fid, '%s\n', char(dt));
fclose(fid);

vars=[c1 s1 c2 s2 c3 s3];
ddt=collect(dt,vars)
polynomialDegree(ddt,vars)
fid = fopen('a-collect.txt', 'wt');
fprintf(fid, '%s\n', char(ddt));
fclose(fid);
