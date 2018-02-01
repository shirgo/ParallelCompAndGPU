function [isModelAssumptionValid,Yr,bars,groundDofs,actualToReduced]=trussCantilever(Nval,Hval,Aval,L,regenerateElementEquations)
% Model of two-dimensional cantilevered truss stimulated by a forcing function
% Includes check for linear assumption
% Material and stimulus properties are set within the code
%
% Inputs 
%    Nval, number of horizontal segments (recommend range [2 20])
%    Hval, height of truss (recommended range [0.1 1])
%    Aval, cross section area for each rod (recommended range [ 0.1 1])
%    L, horizontal length of the truss (suggested value 1)
%
% Copyright 2014-2015 The MathWorks, Inc

if nargin<5
   regenerateElementEquations=0; 
end

%% Local Stiffness matrix of a planar truss element
if regenerateElementEquations 
    % Note: regeneration requires Symbolic Math Toolbox
    syms Am E Lm t real;
    % Am is cross-section area, E is Modulus of Elasticity, Lm is length of
    % bar, t is the angle of the truss bar w.r.t. the horizontal axis
    G = [cos(t) sin(t) 0 0; 0 0 cos(t) sin(t)];
    kk = Am*E/Lm*[1 -1;-1 1];
    k = G'*kk*G;
    localStiffnessFn = matlabFunction(k,'vars',[Am,E,Lm,t],'file','localStiffness');
    syms rho;
    mm = Am*rho*Lm/6*[2 1;1 2];
    m = simplify(G'*mm*G);
    localMassFn = matlabFunction(m,'vars',[Am,rho,Lm,t],'file','localMass');
else
    localStiffnessFn = @localStiffness;
    localMassFn = @localMass;
end

%% Set material and simulation parameters

% Density of truss bar material
rhoval = 1;

% Modulus of Elasticity of truss bar material
Eval = 1e6;

% Rayleigh, "alpha,beta" damping coefficients
dampingCoeffAlpha = 0.001;
dampingCoeffBeta = 0.001;

% A downward force = max(0,(applyTime-t)*downwardForceMag/applyTime)*sin(2*pi*freq*t) is
% applied. The frequency of the force is 1 and the magnitude is linearly
% lowered from |downwardForceMag| to zero over the interval [0,applyTime].
% simTime is the simulation time. Because of the damping the vibrations
% should die out.
downwardForceMag = 0.02;
freq = 1;
applyTime = 200;  
simTime = 200;

%% Map reduced Dofs to actual Dofs
% The truss is fixed to the wall on the left hand side. Therefore the two
% nodes there are not mobile and can be eliminated. Create a map between
% the "reduced" degrees of freedom and the actual degrees of freedom
numDofs = 2*2*(Nval+1)-2; % -2 because the cantilever is pointed upwards at the end
groundDofs = [1,2,2*(Nval+1)+1,2*(Nval+1)+2]; % Degrees of Freedom that will be eliminated
reducedToActual = (1:numDofs);
reducedToActual = [reducedToActual,reducedToActual(groundDofs)];
reducedToActual(groundDofs) = [];
[~,actualToReduced] = sort(reducedToActual);

%% Add bars along with geometry
% bars are #of Bars X [Area,E,length of bar,angle of bar w.r.t. horizontal
% axis, node1 (from node), node2 (to node)]
bars = zeros(2*Nval+2*(Nval-1),4);
for n = 1:Nval
    % upper bars
    lelem = L/Nval;
    bars(n,:) = [lelem,0,n,n+1];
    % diagonal bars
    lelem = sqrt((L/Nval)^2+Hval^2);
    bars(Nval+n,:) = [lelem,atan2(Hval,L/Nval),Nval+1+n,n+1];
end
for n = 1:Nval-1
    % lower bars
    lelem = L/Nval;
    bars(2*Nval+n,:) = [lelem,0,Nval+1+n,Nval+1+n+1];
    % vertical bars
    lelem = Hval;
    bars(2*Nval+Nval-1+n,:) = [lelem,pi/2,Nval+1+n+1,n+1];
end

%% Assemble all bars into global stiffness and mass matrices

% use a dense matrix for insertion efficiency
K = zeros(numDofs,numDofs);
M = zeros(numDofs,numDofs);
for j=1:size(bars,1)
    % extract parameters for stiffness and mass matrices
    lelem = bars(j,1); telem = bars(j,2);
    kelem = localStiffnessFn(Aval,Eval,lelem,telem); % stiffness matrix
    melem = localMassFn(Aval,rhoval,lelem,telem); % mass matrix
    n1 = bars(j,3); n2 = bars(j,4);
    % convert to reduced dofs
    ix = actualToReduced([n1*2-1,2*n1,n2*2-1,n2*2]);
    % element "stamping"
    K(ix,ix) = K(ix,ix) + kelem;
    M(ix,ix) = M(ix,ix) + melem;
end

% This is the reduced dimension
redDim = numDofs-numel(groundDofs);

% convert to stiffness and mass matrices
Kr = sparse(K(1:redDim,1:redDim));
Mr = sparse(M(1:redDim,1:redDim));

% F is the force vector
Fr = zeros(size(Kr,1),1);

% apply the magnitude. the force vector is adjusted further below
Fr(actualToReduced(2*(Nval+1))) = downwardForceMag;

%% Transform M*d2x/dt2 + damping*dx/dt + K*x = F into dydt = A*y + f form
% Convert 2nd order ODE to first order ODE with y = dx/dt transformation.
% The state space is therefore [position,velocity] and in that order
[LM,UM] = lu(Mr);
A = [-UM\(LM\Kr),-UM\(LM\(dampingCoeffAlpha*Kr+dampingCoeffBeta*Mr));sparse(redDim,redDim),speye(redDim)];
f = [UM\(LM\Fr);zeros(redDim,1)];
myEvaluator = @(t,y) A*y + max(0,(applyTime-t)*f/applyTime)*sin(2*pi*freq*t);
initialCondition = zeros(redDim*2,1);

% Yr is #Time points X [position,velocity]
[~,Yr] = ode23t(myEvaluator,[0 simTime],initialCondition);

%% Check if small angle change assumptions are valid. This is important because 
% cos(t) and sin(t) where t is angle of the bar w.r.t. y=0 project forces
% and displacements along x=0 and y=0 and should change very little for the
% linear assumption to be valid.
isModelAssumptionValid = checkLinearAssumptions(Yr,bars,L,Nval,Hval,groundDofs,actualToReduced);

end