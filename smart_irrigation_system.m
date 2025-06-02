% Smart Irrigation System Simulation
% This script simulates a basic smart irrigation system.
% It includes simulated sensor data, decision logic, actuator control,
% 2D plots, and a 3D animation.

% Clear workspace, command window, and close all figures
clear; clc; close all;

% --- Simulation Parameters ---
simulationDuration = 24 * 7; % Total simulation time in hours (e.g., 7 days)
timeStep = 1;                % Time step in hours
timeVector = 0:timeStep:(simulationDuration - timeStep); % Time vector for simulation
numSteps = length(timeVector);

% --- Irrigation System Parameters ---
soilMoistureThreshold_Low = 30;  % % - Irrigate if moisture drops below this
soilMoistureThreshold_High = 70; % % - Stop irrigating if moisture goes above this
irrigationRate = 20;             % %/hour - How much moisture increases when irrigating
dryingRate = 2;                  % %/hour - How much moisture decreases naturally (evaporation, plant uptake)
temperatureThreshold_High = 30;  % Celsius - High temperature might increase drying or trigger caution

% --- Initialize Variables to Store Data ---
soilMoisture = zeros(1, numSteps);
temperature = zeros(1, numSteps);
valveStatus = zeros(1, numSteps); % 0 for OFF, 1 for ON

% --- Initial Conditions ---
soilMoisture(1) = 25; % Start with relatively dry soil
temperature(1) = 20;  % Initial temperature
% valveStatus(1) will be determined in the first loop iteration.

% --- Setup for 3D Animation ---
fprintf('Setting up 3D animation window...\n');
fig3D = figure('Name', '3D Smart Irrigation Animation', 'NumberTitle', 'off', 'Position', [50, 50, 700, 550]);
ax3d = axes(fig3D);
hold(ax3d, 'on');
grid(ax3d, 'on');
axis(ax3d, 'equal'); % Set aspect ratio to be equal
view(ax3d, 35, 25);  % Azimuth and Elevation for 3D view
xlabel(ax3d, 'X-axis');
ylabel(ax3d, 'Y-axis');
zlabel(ax3d, 'Moisture Level / Valve Status');
zlim(ax3d, [0 120]); % Z-axis limits (max moisture 100, valve indicator above)
xlim(ax3d, [-15 15]);
ylim(ax3d, [-15 15]);

% Define 3D objects:
% 1. Soil Moisture Bar (cuboid)
% Base coordinates for the bar (centered at origin for this example)
bar_base_x = [-4, 4, 4, -4];
bar_base_y = [-4, -4, 4, 4];

% Vertices for the cuboid. Height will be updated.
% V = [bottom_face_vertices; top_face_vertices]
% Each face has 4 vertices (x,y,z)
initial_bar_height = max(0, soilMoisture(1)); % Ensure non-negative
V_bar = [bar_base_x', bar_base_y', zeros(4,1);         % Bottom face (z=0)
         bar_base_x', bar_base_y', initial_bar_height*ones(4,1)]; % Top face (z=height)

% Faces of the cuboid
F_bar = [1 2 3 4; % Bottom face
         5 6 7 8; % Top face
         1 2 6 5; % Side
         2 3 7 6; % Side
         3 4 8 7; % Side
         4 1 5 8]; % Side

% Initial color for moisture bar
initial_moisture_color_intensity = initial_bar_height / 100;
dry_color = [0.6, 0.4, 0.2]; % Brownish for dry
wet_color = [0.1, 0.5, 0.8]; % Bluish-green for wet
initial_bar_color = dry_color * (1-initial_moisture_color_intensity) + wet_color * initial_moisture_color_intensity;

moisture_bar_patch = patch(ax3d, 'Vertices', V_bar, 'Faces', F_bar, ...
                           'FaceColor', initial_bar_color, 'EdgeColor', 'black', 'FaceAlpha', 0.8);

% 2. Valve Status Indicator (e.g., a cone)
% Cone parameters: [base_radius, top_radius], number_of_sides
[Xc,Yc,Zc_unit] = cylinder([2 0], 12); % Cone shape (unit height 0 to 1)
% Scale and position the cone (e.g., above the max bar height)
valve_indicator_height = 10;
valve_indicator_base_z = 105;
Zc = Zc_unit * valve_indicator_height + valve_indicator_base_z;
% Position the cone slightly offset in X/Y
valve_indicator_surf = surf(ax3d, Xc+8, Yc+8, Zc, ...
                            'FaceColor', 'red', 'EdgeColor', 'none', 'Visible', 'off'); % Initially off

% Add lighting to the 3D scene
camlight(ax3d, 'headlight');
lighting(ax3d, 'gouraud');
material(ax3d, 'dull'); % Adjust material properties for better appearance

% --- Main Simulation Loop ---
fprintf('Starting Smart Irrigation System Simulation...\n');

for i = 1:numSteps
    currentTime = timeVector(i);
    if mod(currentTime, 24) == 0 % Print day number
        fprintf('--- Day %d ---\n', currentTime/24 + 1);
    end
    fprintf('Time: %d hours\n', currentTime);

    % --- 1. Simulate Sensor Readings ---
    % Simulate Temperature
    if i > 1
        dailyCycle = sin(2 * pi * currentTime / 24 - pi/2); % Adjusted phase for more typical daily cycle (low at night, high mid-day)
        baseTemperature = 20; % Average daily temperature
        tempAmplitude = 8;    % Amplitude of daily temperature fluctuation
        temperature(i) = baseTemperature + tempAmplitude * dailyCycle + (rand()-0.5)*2; % Add some noise
    elseif i == 1
        temperature(i) = temperature(1); % Use initial temperature for the first step
    end
    fprintf('  Current Temperature: %.2f C\n', temperature(i));

    % Simulate Soil Moisture
    if i > 1
        soilMoisture(i) = soilMoisture(i-1); % Start with previous value

        % Effect of drying (influenced by temperature)
        % Temperature factor: higher temp = higher drying. Normalized around 20C.
        tempFactor = max(0.5, temperature(i)/20); % Avoid excessively low/high factors
        soilMoisture(i) = soilMoisture(i) - dryingRate * tempFactor * timeStep;

        % Effect of irrigation (if valve was ON in the previous step)
        if valveStatus(i-1) == 1
            soilMoisture(i) = soilMoisture(i) + irrigationRate * timeStep;
        end
        % Ensure soil moisture stays within realistic bounds (0-100%)
        soilMoisture(i) = max(0, min(100, soilMoisture(i)));
    elseif i == 1
         soilMoisture(i) = soilMoisture(1); % Use initial moisture for the first step
    end
    fprintf('  Current Soil Moisture: %.2f %%\n', soilMoisture(i));

    % --- 2. Decision Logic ---
    if soilMoisture(i) < soilMoistureThreshold_Low
        valveStatus(i) = 1; % Turn valve ON
        fprintf('  Decision: Soil moisture LOW (%.1f%%). Turning valve ON.\n', soilMoisture(i));
    elseif soilMoisture(i) > soilMoistureThreshold_High
        valveStatus(i) = 0; % Turn valve OFF
        fprintf('  Decision: Soil moisture HIGH (%.1f%%). Turning valve OFF.\n', soilMoisture(i));
    elseif i > 1 % Maintain previous state if within deadband (hysteresis)
        valveStatus(i) = valveStatus(i-1);
        if valveStatus(i) == 1
            fprintf('  Decision: Soil moisture (%.1f%%) in range. Valve remains ON.\n', soilMoisture(i));
        else
            fprintf('  Decision: Soil moisture (%.1f%%) in range. Valve remains OFF.\n', soilMoisture(i));
        end
    else % Initial state for valve (i=1, and not yet determined by thresholds)
        valveStatus(i) = 0; % Default to OFF for the very first step if no other condition met
        fprintf('  Decision: Initial state check, valve OFF.\n');
    end

    % --- 3. Actuator Control (Simulated) ---
    if valveStatus(i) == 1
        fprintf('  Actuator: Valve is ON.\n');
    else
        fprintf('  Actuator: Valve is OFF.\n');
    end

    % --- 4. Update 3D Animation ---
    figure(fig3D); % Ensure the 3D figure is the current figure for updates

    % Update soil moisture bar height
    current_bar_height = max(0, soilMoisture(i)); % Ensure non-negative
    V_bar_new = [bar_base_x', bar_base_y', zeros(4,1);
                 bar_base_x', bar_base_y', current_bar_height*ones(4,1)];
    set(moisture_bar_patch, 'Vertices', V_bar_new);

    % Update soil moisture bar color
    moisture_color_intensity = current_bar_height / 100; % Normalized 0-1
    current_bar_color = dry_color * (1-moisture_color_intensity) + wet_color * moisture_color_intensity;
    set(moisture_bar_patch, 'FaceColor', current_bar_color);

    % Update valve indicator visibility and color
    if valveStatus(i) == 1 % Valve ON
        set(valve_indicator_surf, 'Visible', 'on', 'FaceColor', 'green');
    else % Valve OFF
        set(valve_indicator_surf, 'Visible', 'on', 'FaceColor', 'red'); % Keep visible but red for OFF
        % Alternatively, to make it disappear when OFF:
        % set(valve_indicator_surf, 'Visible', 'off');
    end
    
    % Update 3D plot title
    if valveStatus(i) == 1
        valveStr = 'ON';
    else
        valveStr = 'OFF';
    end
    title(ax3d, sprintf('Time: %d hrs | Soil Moisture: %.1f%% | Valve: %s', ...
                        currentTime, soilMoisture(i), valveStr));

    drawnow;       % Update the figure window
    pause(0.05);   % Pause for a short duration to control animation speed

    fprintf('-------------------------------------\n');
end

fprintf('Simulation Complete.\n');

% --- 5. 2D Visualization (Original Plots) ---
fprintf('Generating 2D plots...\n');
figure('Name', 'Smart Irrigation System Simulation Results (2D)', 'NumberTitle', 'off', 'Position', [800, 50, 700, 800]);

% Plot Soil Moisture
subplot(3,1,1);
plot(timeVector, soilMoisture, 'b-', 'LineWidth', 1.5);
hold on;
plot(timeVector, ones(1,numSteps)*soilMoistureThreshold_Low, 'r--', 'DisplayName', 'Low Threshold');
plot(timeVector, ones(1,numSteps)*soilMoistureThreshold_High, 'g--', 'DisplayName', 'High Threshold');
hold off;
title('Soil Moisture Level Over Time');
xlabel('Time (hours)');
ylabel('Soil Moisture (%)');
legend('Soil Moisture', 'Low Threshold', 'High Threshold', 'Location', 'best');
grid on;

% Plot Temperature
subplot(3,1,2);
plot(timeVector, temperature, 'm-', 'LineWidth', 1.5);
hold on;
plot(timeVector, ones(1,numSteps)*temperatureThreshold_High, 'k--', 'DisplayName', 'High Temp Threshold');
hold off;
title('Ambient Temperature Over Time');
xlabel('Time (hours)');
ylabel('Temperature (C)');
legend('Temperature', 'High Temp Threshold', 'Location', 'best');
grid on;

% Plot Valve Status
subplot(3,1,3);
stairs(timeVector, valveStatus, 'k-', 'LineWidth', 1.5); % Use stairs for clear ON/OFF states
title('Irrigation Valve Status Over Time');
xlabel('Time (hours)');
ylabel('Valve Status (0=OFF, 1=ON)');
ylim([-0.1, 1.1]);
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

sgtitle('Smart Irrigation System Simulation (2D Time Series)'); % Super title for the 2D figure

fprintf('Plots generated. End of script.\n');
