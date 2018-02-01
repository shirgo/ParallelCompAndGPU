function visualizeParamSweep(nVals, hVals, aVals, peakVals, hTopAxes)
% Plot routine to accompany parameter sweep for trussCantilever model
%
% Copyright 2014-2015 The MathWorks, Inc.

A=length(aVals); % dim3 
N=length(nVals); % dim2 if not squeezed

if numel(peakVals)>400
   LS='none';
else
   LS=':';
end

fontSizeTitle = 16;
fontSize = 12;
if A==1
	sf=surf(hTopAxes,nVals,hVals,log10(abs(peakVals)));
	title(hTopAxes,sprintf('Log of Maximum Y Deflection \n (%3.2f cross section)',aVals),...
		'Interpreter','none','FontSize', fontSizeTitle);
	view(hTopAxes,-37,38)
	set(hTopAxes,'ydir','reverse');
	set(hTopAxes,'xlim',[min(nVals) max(nVals)]);
	set(hTopAxes,'ylim',[min(hVals) max(hVals)]);
	set(sf,'LineStyle',LS);  
	set(sf,'FaceAlpha',1.0)
	
	xlabel(hTopAxes,'Number of horizontal Segments','FontSize',fontSize);
	ylabel(hTopAxes,'Height of truss','FontSize',fontSize);
else
	if N==1
		sf=surf(hTopAxes,aVals,hVals,log10(abs(squeeze(peakVals))));
		title(hTopAxes,sprintf('Log of Maximum Y Deflection (%i segments)',nVals),...
			'Interpreter','none','FontSize', fontSizeTitle);
		view(hTopAxes,-37,38)
		set(hTopAxes,'ydir','reverse');
		set(hTopAxes,'xlim',[min(aVals) max(aVals)]);
		set(hTopAxes,'ylim',[min(hVals) max(hVals)]);
		set(sf,'LineStyle',LS);  
		set(sf,'FaceAlpha',1.0)
		
		xlabel(hTopAxes,'Cross section','FontSize',fontSize);
		ylabel(hTopAxes,'Height of truss','FontSize',fontSize);
	else
		logPeakVals=log10(abs(peakVals));
		yMin=min(min(min(logPeakVals)));
		yMax=max(max(max(logPeakVals)));
		for nn=1:N
			subplot(N,1,nn);
			sf=surf(hTopAxes,nVals,hVals,logPeakVals(:,:,nn));
			if nn==1
				title(hTopAxes,sprintf('Log of Maximum Y Deflection \n(%3.2f cross section)',aVals(nn)),...
					'Interpreter','none','FontSize', fontSizeTitle);
			else
				title(hTopAxes,sprintf('(%3.2f cross section)',aVals(nn)),...
					'Interpreter','none','FontSize', fontSizeTitle);
			end
			view(hTopAxes,-37,38)
			set(hTopAxes,'ydir','reverse');
			set(hTopAxes,'xlim',[min(nVals) max(nVals)]);
			set(hTopAxes,'ylim',[min(hVals) max(hVals)]);
			set(hTopAxes,'zlim',[yMin yMax]);
			set(sf,'LineStyle',LS)
			set(sf,'FaceAlpha',1.0)
		end
		
		xlabel(hTopAxes,'Number of horizontal Segments','FontSize',fontSize);
		ylabel(hTopAxes,'Height of truss','FontSize',fontSize);
	end
end


end

