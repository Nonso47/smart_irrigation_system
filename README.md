#  Smart Irrigation System using MATLAB & Simulink <br>
<h2>Overview</h2>
The Smart Irrigation System is a model-based design developed using MATLAB and Simulink to automate water delivery to crops or gardens based on real-time environmental data. The objective is to conserve water, reduce manual intervention, and improve agricultural efficiency by intelligently monitoring soil moisture, temperature, and humidity levels. This project demonstrates how control logic and sensor feedback can be used to optimize irrigation in a simulated environment.
<h1>Tools and Technologies</h1>
<h3>Tool	Description</h3>
MATLAB (R202x)  Used for scripting, data analysis, and function logic <br>
Simulink	Used to build, simulate, and visualize system behavior <br>
Dashboard Blocks	GUI elements like knobs, gauges, scopes, and toggles <br>
Scope	Used to monitor real-time signals and trends <br>
Data Logging	For storing and analyzing simulation results
<h1>System Description</h1>
<h2>Components</h2>
<h3>Sensor Simulators</h3>
Simulated inputs for:
<li>Soil Moisture (random or waveform signal)</li>
<li>Temperature (sinusoidal or stepped profile)</li>
<li>Humidity (optional input for future scalability)</li>
<h2>Control Logic</h2>
Evaluates sensor data against predefined thresholds<br>
Contains decision-making blocks using:
<li>Relational Operators</li>
<li>Logical Operators (AND, OR, NOT)</li>
<li>Switch and If Blocks</li>
<h2>Actuator System</h2>
<li>Simulates a Water Pump using:</li>
<li>Gain Block (for flow rate)</li>
<li>Actuator Status LED or Display</li>
<li>Triggered based on logical control conditions</li>
<h2>Dashboard Interface</h2>
<li>Real-time visualization:</li>
<li>Soil moisture gauge</li>
<li>Pump status LED</li>
<li>Temperature display</li>
<li>Manual override switch</li>
<li>Enables user interaction and monitoring</li>
<h2>Timing Control</h2>
<li>Prevents pump from running beyond a safe duration</li>
<li>Resettable timer included for safety and scheduling</li>
<h1>Simulation Results</h1>
The model produces:
<li>A time-series plot of soil moisture and pump activity</li>
<li>Pump activation patterns based on input fluctuations</li>
<li>Water usage estimation (optional, based on flow rate)</li>
All key variables are logged and viewable in MATLAB's Simulation Data Inspector.
