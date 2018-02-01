function isValid = checkLinearAssumptions(Yr,bars,L,N,H,groundDofs,actualToReduced)
% Check if small angle change assumptions are valid for truss cantilever. 
%
% This is important because cos(t) and sin(t) where t is angle of the bar w.r.t. y=0 
% project forces and displacements along x=0 and y=0 and should change very little 
% for the linear assumption to be valid.
%
% Copyright 2014-2015 The MathWorks, Inc.

%% Compute actual displacement
reducedDisp = [Yr(:,1:end/2),zeros(size(Yr,1),numel(groundDofs))];
actualDisp = reducedDisp(:,actualToReduced);
actualDispX = actualDisp(:,1:2:end);
actualDispY = actualDisp(:,2:2:end);

%% Compute baseline x,y positions
xyBase = [[(0:N)*L/N;zeros(1,N+1)],[(0:N-1)*L/N;ones(1,N)*(-H)]];
xyStartBase = xyBase(:,bars(:,3));
xyFinishBase = xyBase(:,bars(:,4));
isValid  = true;

% original angles w.r.t. y=0
angles = bars(:,2).';
cost = cos(angles);
sint = sin(angles);

% acceptable change in cos/sin
relTol = 0.1;
absTol = 1e-4;

% loop over all time till we find out first violator of model assumptions
for j=1:size(Yr,1)
    xyStart = xyStartBase + [actualDispX(j,bars(:,3));actualDispY(j,bars(:,3))];
    xyFinish = xyFinishBase + [actualDispX(j,bars(:,4));actualDispY(j,bars(:,4))];
    xyBar = xyFinish - xyStart;
    % compute new cosines and sines
    newLength = sqrt(xyBar(1,:).^2 + xyBar(2,:).^2);
    newCost = xyBar(1,:)./newLength;
    newSint = xyBar(2,:)./newLength;
    testCond1 = abs(newCost - cost) > max(relTol*abs(cost),absTol);
    testCond2 = abs(newSint - sint) > max(relTol*abs(sint),absTol);
     % bitwise OR gives us one of (x,y) violations of cos(t)
     % and sin(t) not deviating too much
    if find(testCond1 | testCond2,1)
        isValid = false;        
        break;
    end
end

end