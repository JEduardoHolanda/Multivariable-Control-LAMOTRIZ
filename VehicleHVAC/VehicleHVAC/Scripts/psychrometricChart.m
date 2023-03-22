% Function to create psychrometric chart and return the figure handle with
% added function handles for run-time updates

% Copyright 2017 The MathWorks, Inc.

function hFig = psychrometricChart(hFig, simlog)

hold on
LineColors = get(gca, 'ColorOrder');

% Moist air data
p_atm = 101325;    % Pa       Atmospheric pressure
MM_da = 28.96546;  % g/mol    Dry air molar mass
MM_w  = 18.015268; % g/mol    Water molar mass

T_ref     = 20;     % degC     Reference temperature for fluid properties
h_da_ref  = 20.12;  % kJ/kg    Dry air specific enthalpy at reference temperature
h_w_ref   = 2538.2; % kJ/kg    Saturated water vapor specific enthalpy at reference temperature
h_l_ref   = 83.72;  % kJ/kg    Saturated liquid water specific enthalpy at reference temperature
cp_da_ref = 1.006;  % kJ/kg/K  Dry air specific heat at constant pressure
cp_w_ref  = 1.86;   % kJ/kg/K  Saturated water vapor specific heat at constant pressure
cp_l_ref  = 4.186;  % kJ/kg/K  Saturated liquid water specific heat at constant pressure

% Water vapor saturation pressure correlation coefficients
% Data from ASHRAE Handbook Fundamentals 2013
% Valid from 0 degC to 200 degC
% ln(p) = c1/T + c2 + c3*T + c4*T^2 + c5*T^3 + c6*ln(T)
% p in Pa, T in K
p_w_sat_coeff = [
    -5.8002206e+03
    +1.3914993e+00
    -4.8640239e-02
    +4.1764768e-05
    -1.4452093e-08
    +6.5459673e+00];

% Range of temperature and humidity ratio for the psychrometric chart
T_range  = [0, 50]; % degC
HR_range = [0, 30]; % g w / kg da

% Relative humidity contour levels
RH_contours = 0 : 0.1 : 1;
% Specific enthalpy contour levels (kJ / kg da)
h_contours = 20 : 20 : 120;
% Web-bulb temperature contour levels (degC)
T_wet_contours = 0 : 5 : 35;

% Temperature grid for contour curves
N = 100;
T = linspace(T_range(1), T_range(2), N)';

% Water vapor saturation pressure (Pa)
p_w_sat = exp([bsxfun(@power, T + 273.15, -1:1:3), log(T + 273.15)] * p_w_sat_coeff(:));
% Water vapor pressure (Pa)
p_w = p_w_sat * RH_contours;
% Humidity ratio (g w / kg da) for relative humidity contours
HR_for_RH = MM_w/MM_da * p_w ./ (p_atm - p_w) * 1e3;

% Dry air specific enthalpy
h_da = h_da_ref + cp_da_ref*(T - T_ref);
% Water vapor specific enthalpy
h_w = h_w_ref + cp_w_ref *(T - T_ref);
% Humidity ratio (g w / kg da) for mixture specific enthalpy contours
HR_for_h = bsxfun(@rdivide, bsxfun(@minus, h_contours, h_da), h_w) * 1e3;

% Water vapor saturation pressure (Pa) at web-bulb temperature
p_w_sat_wet = exp([bsxfun(@power, T_wet_contours' + 273.15, -1:1:3), log(T_wet_contours' + 273.15)] * p_w_sat_coeff(:))';
% Saturation humidity ratio at web-bulb temperature
HR_sat_wet = MM_w/MM_da * p_w_sat_wet ./ (p_atm - p_w_sat_wet);
% Dry air specific enthalpy at web-bulb temperature
h_da_wet = h_da_ref + cp_da_ref*(T_wet_contours - T_ref);
% Water vapor specific enthalpy at web-bulb temperature
h_w_wet = h_w_ref + cp_w_ref *(T_wet_contours - T_ref);
% Liquid water specific enthalpy at web-bulb temperature
h_l_wet = h_l_ref + cp_l_ref *(T_wet_contours - T_ref);
% Humidity ratio (g w / kg da) for web-bulb temperature contours
HR_for_T_wet = bsxfun(@minus, HR_sat_wet .* (h_w_wet - h_l_wet) + h_da_wet, h_da) ./ bsxfun(@minus, h_w, h_l_wet) * 1e3;

% Plot relative humidity contours
for k = 1 : length(RH_contours)
    hContours = plot(T, HR_for_RH(:,k), 'Color', LineColors(1,:), 'LineWidth', 0.5);
    hContours.Annotation.LegendInformation.IconDisplayStyle = 'off';
    text(T(60), HR_for_RH(60,k) + 1, num2str(RH_contours(k)), ...
        'HorizontalAlignment', 'left', 'Rotation', 0, 'Color', LineColors(1,:))
end
hContours.DisplayName = 'Relative Humidity';
hContours.Annotation.LegendInformation.IconDisplayStyle = 'on';

% Plot specific enthalpy contours
for k = 1 : length(h_contours)
    hContours = plot(T, HR_for_h(:,k), 'Color', LineColors(2,:), 'LineWidth', 0.5);
    hContours.Annotation.LegendInformation.IconDisplayStyle = 'off';
    text(T(80), HR_for_h(80,k) + 1, num2str(h_contours(k)), ...
        'HorizontalAlignment', 'left', 'Rotation', -30, 'Color', LineColors(2,:))
end
hContours.DisplayName = 'Enthalpy (kJ / kg dry air)';
hContours.Annotation.LegendInformation.IconDisplayStyle = 'on';

% Plot wet-bulb temperature contours
for k = 1 : length(T_wet_contours)
    hContours = plot(T, HR_for_T_wet(:,k), 'Color', LineColors(3,:), 'LineWidth', 0.5);
    hContours.Annotation.LegendInformation.IconDisplayStyle = 'off';
    text(T(1) + 1, HR_for_T_wet(1,k) - 1, num2str(T_wet_contours(k)), ...
        'HorizontalAlignment', 'left', 'Rotation', -30, 'Color', LineColors(3,:))
end
hContours.DisplayName = 'Wet-Bulb Temperature (degC)';
hContours.Annotation.LegendInformation.IconDisplayStyle = 'on';

if nargin > 1
    % If simlog is provided, get simulation results
    simlog_t = simlog.Cabin.Moist_Air_Volume.T_I.series.time;
    simlog_T = simlog.Cabin.Moist_Air_Volume.T_I.series.values('degC');
    simlog_RH = simlog.Cabin.Moist_Air_Volume.RH_I.series.values;
    % Cabin air water vapor pressure (Pa)
    simlog_p_w = simlog_RH .* exp([bsxfun(@power, simlog_T + 273.15, -1:1:3), log(simlog_T + 273.15)] * p_w_sat_coeff(:));
    % Cabin air humidity ratio (g w / kg da)
    simlog_HR = MM_w/MM_da * simlog_p_w ./ (p_atm - simlog_p_w) * 1e3;
else
    % Otherwise, use dummy values
    simlog_t = 0;
    simlog_T = -100;
    simlog_HR = -100;
end

% Plot simulation results
hLine = plot(simlog_T, simlog_HR, 'k-', 'LineWidth', 1.5, 'MarkerFaceColor', 'k');
hLine.DisplayName = 'Cabin Air Trajectory';
hLine.Annotation.LegendInformation.IconDisplayStyle = 'on';
% Label start of trajectory
hStart = plot(simlog_T(1), simlog_HR(1), 'd', 'Color', LineColors(4,:));
hStart.Annotation.LegendInformation.IconDisplayStyle = 'off';
hStartText = text(simlog_T(1) + 1, simlog_HR(1), ['t = ' num2str(simlog_t(1))], ...
    'HorizontalAlignment', 'left', 'Color', LineColors(4,:));
% Label end of trajectory
hEnd = plot(simlog_T(end), simlog_HR(end), 'd', 'Color', LineColors(4,:));
hEnd.Annotation.LegendInformation.IconDisplayStyle = 'off';
hEndText = text(simlog_T(end) + 1, simlog_HR(end), ['t = ' num2str(simlog_t(end))], ...
    'HorizontalAlignment', 'left', 'Color', LineColors(4,:));

% Format axes
xlim(T_range)
ylim(HR_range)
set(gca, 'YAxisLocation', 'right')
xlabel('Dry-Bulb Temperature (degC)')
ylabel('Humidity Ratio (g w / kg dry air)')
hTitle = title('Psychrometric Chart (Predefined Inputs)');
legend('show', 'Location', 'northwest')
grid on
box on
hold off

% Store function handles to allow access from callbacks during run time
% Function handle to prepare psychrometric chart for manual system inputs
if ~isprop(hFig, 'prepManualInput')
    addprop(hFig, 'prepManualInput');
end
hFig.prepManualInput = @prepManualInput;
% Function handle to update psychrometric chart with new cabin air data
if ~isprop(hFig, 'updatePlot')
    addprop(hFig, 'updatePlot');
end
hFig.updatePlot = @updatePlot;



    function prepManualInput
        % Prepare psychrometric chart for manual system inputs
        % Clear existing data
        set(hLine, 'XData', -100, 'Ydata', -100, 'LineStyle', 'none', 'Marker', 'o', ...
            'DisplayName', 'Cabin Air State')
        set(hStart, 'XData', -100, 'YData', -100)
        set(hStartText, 'String', '')
        set(hEnd, 'XData', -100, 'YData', -100)
        set(hEndText, 'String', '')
        set(hTitle, 'String', 'Psychrometric Chart (Manual Inputs)')
    end

    function updatePlot(data)
        % Update psychrometric chart with new cabin air data
        T_data = data(1) + 273.15;
        if T_data <= 0
            return % Reject spurious values
        end
        RH_data = data(2);
        p_w_data = RH_data * exp( ...
            p_w_sat_coeff(1)/T_data + ...
            p_w_sat_coeff(2) + ...
            p_w_sat_coeff(3)*T_data + ...
            p_w_sat_coeff(4)*T_data^2 + ...
            p_w_sat_coeff(5)*T_data^3 + ...
            p_w_sat_coeff(6)*log(T_data));
        HR_data = MM_w/MM_da * p_w_data / (p_atm - p_w_data) * 1e3;
        % Refresh figure with new data
        set(hLine, 'XData', T_data - 273.15, 'Ydata', HR_data)
        drawnow limitrate nocallbacks
    end

end