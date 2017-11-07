function [R,C,S,Z] = Reachability(T,thresh)
%
if nargin<2,
    Z = double(T>eps);
else
    Z = double(T>thresh);
end
N = size(T,1);
R = zeros(size(Z));
S = zeros(size(Z));
R = double((eye(N) + Z)^(N-1)>0);
C = R & R';
[V,D]=eig(Z);
d = diag(D);
Dn = repmat(d(:),1,N); pwers = repmat(0:(N-1),N,1);
Dnn = diag(sum(Dn.*pwers,2));%
S = V*Dnn*inv(V);
%for j=0:N-1,
 %   C = C + Z^j;
    %  = C + V*D^j*inv(V);
%end
%      = V*sum(D_{j=0:N-1})*inv(V)
%  
