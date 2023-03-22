% Callback function to update psychrometric chart during simulation

% Copyright 2017 The MathWorks, Inc.

function updatePsychrometricChart(rto, ~)
persistent count
if isempty(count)
    count = 1;
end

% Update only every 10 time steps to speed up simulation
if count == 10
    hFig = get_param(rto.BlockHandle, 'UserData');
    if ~isempty(hFig)
        % Update plot with block output data from run-time object
        hFig.updatePlot(rto.OutputPort(1).Data);
    end
    count = 1;
else
    count = count + 1;
end

end