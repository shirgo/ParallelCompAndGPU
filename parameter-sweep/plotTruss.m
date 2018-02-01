function plotTruss(Yr,bars,L,N,H,groundDofs,actualToReduced,figNo)
% Plot routine to accompany trussCantilever model
%
% Copyright 2014-2015 The MathWorks, Inc.

if nargin<8
    figNo=1;
end

figure(figNo); clf;

reducedDisp = [Yr(:,1:end/2),zeros(size(Yr,1),numel(groundDofs))];
actualDisp = reducedDisp(:,actualToReduced);
actualDispX = actualDisp(:,1:2:end);
actualDispY = actualDisp(:,2:2:end);
xyBase = [[(0:N)*L/N;zeros(1,N+1)],[(0:N-1)*L/N;ones(1,N)*(-H)]];
xyStartBase = xyBase(:,bars(:,3));
xyFinishBase = xyBase(:,bars(:,4));

jN=size(actualDispX,1);
skpr=max(1,floor(jN/300));
dispVec=1:skpr:jN;

for j=dispVec
    xyStart = xyStartBase + [actualDispX(j,bars(:,3));actualDispY(j,bars(:,3))];
    xyFinish = xyFinishBase + [actualDispX(j,bars(:,4));actualDispY(j,bars(:,4))];
    h = line([xyStart(1,:);xyFinish(1,:)],[xyStart(2,:);xyFinish(2,:)],'linewidth',1.5);
    set(h,'Parent',gca);
    hold on;
    p1 = plot(gca,xyStart(1,:),xyStart(2,:),'.','MarkerSize',18);
    p2 = plot(gca,xyFinish(1,:),xyFinish(2,:),'.','MarkerSize',18);
    axis([0 1.2*L -2*H +H]); shg;
    hold off;
    if j < dispVec(end)
        delete(h);
        set(p1,'color',[0.5 0.5 0.5]);
        set(p2,'color',[0.5 0.5 0.5]);
    end
end

end

