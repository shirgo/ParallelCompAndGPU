function [peakVals,mainComputationTime,nVals,aVals,p]=paramSweepParfeval(nVals,hVals,aVals,L,showTruss,hTopAxes) %#ok<INUSL>
% Parameter sweep study to investigate deflection in a 2D cantilevered truss
%
% Assumes fixed material properties and fixed (configurable) length of truss
%
% Inputs
%    nVals, vector of number of horizontal segments (recommend values in range [2 20])
%    hVals, vector of height of truss (recommended values in range [0.1 1])
%    aVals, vector of cross section area for each rod (recommended values in range [ 0.1 1])
%    L, horizontal length of the truss (suggested value 1)
%
% Examples:
%   [~,mainComputationTime]=paramSweepParallel(2:1:18,0.1:.03:.7,[0.25],1)
%   [~,mainComputationTime]=paramSweepParallel(2:2:20,0.1:.05:.6,[0.25 0.5],1)
%   [~,mainComputationTime]=paramSweepParallel(2:1:18,0.1:.01:.7,[0.25],1)

if nargin<5
	showTruss=0;
end

if nargin<6
	hTopAxes=[];
end


%% Set up problem to provide a single index to loop on
[nGrid, hGrid, aGrid] = meshgrid(nVals, hVals, aVals);
peakVals = nan(size(nGrid));

if ~isempty(hTopAxes)
	visualizeParamSweep(nVals, hVals, aVals, peakVals, hTopAxes);
end

peakVals=squeeze(peakVals);

p=gcp;

%% Parameter Sweep

t0 = tic;

% Set number of groups
%N=numel(nGrid);    % Lots of overhead if setting up many jobs
%N=1;               % one big group
N=3*p.NumWorkers;   % similar to what parfor does


for ii = N:-1:1
    % Choose indices for groupings within parfeval submission.
    % Recommended to have 3*NumWorkers groups
    
    % Choose ordering 
    idx=(numel(nGrid)+1-ii):-N:1;  % reverse
    %idx=ii:N:numel(nGrid);  % forward
    
    
    % Note: with many iterations, overhead will be large, need a grouper
    %[isModelAssumptionValid,Y,bars,groundDofs,actualToReduced]=trussCantilever(nGrid(ii),hGrid(ii),aGrid(ii),L);
    
    f(idx)=parfeval(p, @Grouper, 2, nGrid(idx), hGrid(idx), aGrid(idx), L, idx);
end

% Can do other work while I wait ( Asyncrhonous)


for ii=1:N
    % fetchNext blocks until next results are available.
    [~, thisResult, thisIdx] = fetchNext(f);
    
    peakVals(thisIdx) = thisResult;
	
	if ~isempty(hTopAxes)
		hTopAxes.Children.ZData(thisIdx)=log10(abs(thisResult));
		%drawnow
    end
    
    % Plot trusses
    if showTruss
        plotTruss(Y,bars,L,nGrid(ii),hGrid(ii),groundDofs,actualToReduced)
    end

end

mainComputationTime = toc(t0);

% if ~isempty(hTopAxes)
% 	visualizeParamSweep(nVals, hVals, aVals, peakVals, hTopAxes);
% end

end

function [peakVals,idx]=Grouper(nVals,hVals,aVals,L,idx)
% Group sets of calculations to reduce effects of overhead
peakVals = zeros(length(nVals),1);
for ii = 1:length(hVals)
    [isModelAssumptionValid,Y,bars,groundDofs,actualToReduced]=trussCantilever(nVals(ii),hVals(ii),aVals(ii),L); %#ok<ASGLU>
    if isModelAssumptionValid
        % Determine peak Y deflection at any node
        % columns are all x,y pairs followed by all xdot,ydot pairs
        peakVals(ii) = max(max(abs(Y(:,2:2:end/2))));
    else
        fprintf('Linear model assumption not valid for N = %d and A = %e\n',nGrid(ii),hGrid(ii),aGrid(ii));
        peakVals(ii) = nan;
    end
end
end