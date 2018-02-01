function [peakVals,mainComputationTime,nVals,hVals,aVals]=paramSweepSerial(nVals,hVals,aVals,L,showTruss, hTopAxes)
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

%% Parameter Sweep
t0 = tic;

for ii = 1:numel(nGrid)
    
    % Solve ODE for each parameter combination
    
    [isModelAssumptionValid,Y,bars,groundDofs,actualToReduced]=trussCantilever(nGrid(ii),hGrid(ii),aGrid(ii),L);
    if isModelAssumptionValid
        % Determine peak Y deflection at any node
        % columns are all x,y pairs followed by all xdot,ydot pairs
        peakVals(ii) = max(max(abs(Y(:,2:2:end/2))));
    else
        fprintf('Linear model assumption not valid for N = %d and A = %e\n',nGrid(ii),hGrid(ii),aGrid(ii));
        peakVals(ii) = nan;
    end
    
    % Plot trusses
    if showTruss
        plotTruss(Y,bars,L,nGrid(ii),hGrid(ii),groundDofs,actualToReduced)
    end
    
end

mainComputationTime = toc(t0);

if ~isempty(hTopAxes)
    visualizeParamSweep(nVals, hVals, aVals, peakVals, hTopAxes);
end

end
