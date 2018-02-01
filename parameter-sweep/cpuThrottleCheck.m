function [percNow,data] = cpuThrottleCheck
% first pass at a function to report CPU throttling (Windows specific)
% will need to be updated to accomodate multiple processor computers

%Copyright 2015, The MathWorks, Inc

percNow=0;
data=[];

if ispc
    
    getList={'ExtClock','CurrentClockSpeed','MaxClockSpeed','Availability','NumberOfCores'};
    
    data=[];
    
    for gg=1:length(getList)
        [~,A]=system(sprintf('wmic cpu get %s',getList{gg}));
        [A,B]=strtok(A,10);
        B=B(2:end);
        data=setfield(data,A,str2double(B)); %#ok<SFLD>
    end
    
    percNow=round(100*data.CurrentClockSpeed/data.MaxClockSpeed);
    
end
