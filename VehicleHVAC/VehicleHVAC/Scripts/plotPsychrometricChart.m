% This figure shows a psychrometric chart for the moist air inside the
% cabin. It is based on the ASHRAE Psychrometric Chart No. 1 and is used to
% convey thermodynamic properties of moist air, such as dry-bulb
% temperature, web-bulb temperature, relative humidity, humidity ratio, and
% enthalpy. The trajectory of the state of the cabin moist air during
% simulation is plotted on the chart.
%
% Copyright 2017 The MathWorks, Inc.

% Reuse figure if it exists, else create new figure
if ~exist('h1_vehicleHVAC', 'var') || ...
        ~isgraphics(h1_vehicleHVAC, 'figure')
    h1_vehicleHVAC = figure('Name', 'vehicleHVAC');
end
figure(h1_vehicleHVAC)
clf(h1_vehicleHVAC)

% Check for predefined system inputs or manual system inputs
% For predefined system inputs, plot simlog results on psychrometric chart
% For manual system inputs, prepare psychrometric to accept run-time results
if strcmp(get_param([bdroot '/System Inputs'], 'OverrideUsingVariant'), 'Predefined')
    % Generate simulation results if they don't exist
    if(~exist('simlog_vehicleHVAC', 'var'))
        sim(bdroot)
    end
    % Create psychrometric chart and plot simlog results
    h1_vehicleHVAC = psychrometricChart(h1_vehicleHVAC, simlog_vehicleHVAC);
else
    % Create psychrometric chart
    h1_vehicleHVAC = psychrometricChart(h1_vehicleHVAC);
    h1_vehicleHVAC.prepManualInput()
    
end

% Store figure handle in the block to allow access from other callbacks.
set_param([bdroot '/Cabin/Cabin Sensors/Cabin Outputs'], 'UserData', h1_vehicleHVAC)
% Clear figure handle from block when figure is closed.
set(h1_vehicleHVAC, 'DeleteFcn', ...
    @(~, ~) set_param([bdroot '/Cabin/Cabin Sensors/Cabin Outputs'], 'UserData', []))