addpath(genpath(pwd))

cd Libraries
if ~exist(fullfile(pwd, 'HVAC_lib'), 'file')
    ssc_build HVAC
end
cd ..

vehicleHVAC

% Copyright 2017 The MathWorks, Inc.