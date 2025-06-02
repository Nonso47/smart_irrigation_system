% Smart Irrigation System Simulation
% This script simulates a basic smart irrigation system.
% It includes simulated sensor data, decision logic, and actuator control.

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

% --- Main Simulation Loop ---
fprintf('Starting Smart Irrigation System Simulation...\n');

for i = 1:numSteps
    currentTime = timeVector(i);
    fprintf('Time: %d hours\n', currentTime);

    % --- 1. Simulate Sensor Readings ---

    % Simulate Temperature (e.g., a simple daily sinusoidal pattern)
    % Adjust amplitude and phase for a more realistic daily cycle if needed
    if i > 1
        dailyCycle = sin(2 * pi * currentTime / 24 + pi); % Simple daily fluctuation
        baseTemperature = 22; % Average daily temperature
        temperature(i) = baseTemperature + 5 * dailyCycle + (rand()-0.5)*2; % Add some noise
    end
    fprintf('  Current Temperature: %.2f C\n', temperature(i));

    % Simulate Soil Moisture
    if i > 1
        soilMoisture(i) = soilMoisture(i-1); % Start with previous value

        % Effect of drying
        soilMoisture(i) = soilMoisture(i) - dryingRate * (temperature(i)/20); % Drying rate influenced by temp

        % Effect of irrigation (if valve was ON in the previous step)
        if valveStatus(i-1) == 1
            soilMoisture(i) = soilMoisture(i) + irrigationRate;
        end

        % Ensure soil moisture stays within realistic bounds (0-100%)
        soilMoisture(i) = max(0, min(100, soilMoisture(i)));
    end
    fprintf('  Current Soil Moisture: %.2f %%\n', soilMoisture(i));

    % --- 2. Decision Logic ---
    % Decide whether to turn the valve ON or OFF

    if soilMoisture(i) < soilMoistureThreshold_Low
        % If soil is too dry, turn valve ON
        valveStatus(i) = 1;
        fprintf('  Decision: Soil moisture LOW. Turning valve ON.\n');
    elseif soilMoisture(i) > soilMoistureThreshold_High
        % If soil is sufficiently moist, turn valve OFF
        valveStatus(i) = 0;
        fprintf('  Decision: Soil moisture HIGH. Turning valve OFF.\n');
    elseif i > 1 % Maintain previous state if within deadband
        valveStatus(i) = valveStatus(i-1);
        if valveStatus(i) == 1
            fprintf('  Decision: Soil moisture in range, valve remains ON.\n');
        else
            fprintf('  Decision: Soil moisture in range, valve remains OFF.\n');
        end
    else % Initial state for valve (can be off)
        valveStatus(i) = 0;
         fprintf('  Decision: Initial state, valve OFF.\n');
    end

    % Optional: High temperature override (e.g., avoid watering during extreme heat to prevent scalding)
    % This is a simple example; real logic could be more complex.
    % if temperature(i) > temperatureThreshold_High && valveStatus(i) == 1
    %     valveStatus(i) = 0; % Turn off if too hot
    %     fprintf('  Override: Temperature HIGH. Turning valve OFF to prevent scalding.\n');
    % end

    % --- 3. Actuator Control (Simulated) ---
    % The valveStatus variable itself represents the actuator state.
    % In a real system, you would send a command to a physical valve here.
    if valveStatus(i) == 1
        fprintf('  Actuator: Valve is ON.\n');
    else
        fprintf('  Actuator: Valve is OFF.\n');
    end
    fprintf('-------------------------------------\n');

    % Pause for a very short duration to make simulation steps visible in command window (optional)
    % pause(0.01);
end

fprintf('Simulation Complete.\n');

% --- 4. Visualization ---
fprintf('Generating plots...\n');

figure('Name', 'Smart Irrigation System Simulation Results', 'NumberTitle', 'off');

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
% Use stairs plot for a clearer view of ON/OFF states
stairs(timeVector, valveStatus, 'k-', 'LineWidth', 1.5);
title('Irrigation Valve Status Over Time');
xlabel('Time (hours)');
ylabel('Valve Status (0=OFF, 1=ON)');
ylim([-0.1, 1.1]); % Set y-axis limits for better visualization
yticks([0 1]);
yticklabels({'OFF', 'ON'});
grid on;

sgtitle('Smart Irrigation System Simulation'); % Super title for the figure

fprintf('Plots generated. End of script.\n');

% --- Helper Functions (Optional - can be integrated above or separate) ---
% For this script, functions are simple enough to be inline.
% For more complex models, consider functions like:
% function newMoisture = updateSoilMoisture(currentMoisture, valveState, temp, params)
% function newTemp = updateTemperature(currentTime, params)
% function newValveState = controlLogic(currentMoisture, currentTemp, params)
