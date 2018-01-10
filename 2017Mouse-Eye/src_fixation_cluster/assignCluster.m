function idx = assignCluster(ctr, x,y)
% ctr: Cx2 center values of cluster (C=#class/cluster)
% x,y: Nx1 coordinate of points
N = length(x);
C = size(ctr,1);

cx = ctr(:,1);
cy = ctr(:,2);

% Generate N x C matrix for efficient computing
Ax = repmat(cx', [N,1]);
Ay = repmat(cy', [N,1]);

Bx = repmat(x, [1,C]);
By = repmat(y, [1,C]);

% Elementwise norm
elem_norm = sqrt( (Ax-Bx).^2 + (Ay-By).^2 );
% Find the cluster that is closest
[~,idx] = min(elem_norm,[],2);