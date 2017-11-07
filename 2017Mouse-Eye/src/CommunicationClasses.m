function  Cl = CommunicationClasses(R,C,Z)
U = unique(C,'rows'); %returns the unique classes in the "can reach (R)" & "can be reached by (R')" matrix C = R & R'
nclasses = size(U,1);
% each row of U is an indicator vector that codes the class members as ones
%Now we can compute the reduced transition matrix using projection to find
%the image of U in Z, the state to state transition matrix
%  Recall that if y = H*x,  and x has transition  x' = A*x, then the
%  transition for y is y' = H*x' = H*A*x = H*A*H'*y, using a transpose
%  trick.   So the matrix which governs communication class to
%  communication class is:  U*Z*U'.  If we only care about connectivity,
%  then:
M = double(U*Z*U'>0);
% and if we don't care about self -transitions, then
Mp = M & ~eye(size(M));  % removes the main diagonal  = Mp = M - eye(size(M));
% closed vs. open:  a communication class is open if it's connected to
% other classes, else it's closed - the set of states are absorbing once
% entered.  We should generalize these concepts to Soft measures
v = sum(Mp)>0;  % indicator vector for open vs. closed
Cl.U = U;
Cl.numclasses = nclasses;
Cl.isOpen = v;



