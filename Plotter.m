% Script to Plot *Data* from the Simulator
% close all
% clear all
% Define the path to the .mat file
% If the file is in a subfolder named 'results' and the filename is 'SimulatorOutputData-1.mat'
FileNumber =119;

filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);


%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArray = data.ParallelStringArray;

filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);

paramdata = load(filePath);

ParamData = paramdata.simulationParams;

time = (1:5:ParamData.totaltimestep).*ParamData.timestepSize;

%%
PlotDensity = 5  %An Interger that dictates how many points are plotted. ie plot every 10th value. 
 
%% 1 Plot 1 Chosen String
disp("ok")
% Index of the string to plot
chosenStringIndex = 12; % Example: plot the first string

numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
terminalVoltages = zeros(numTimesteps, 1); % Preallocate for terminal voltages

for t = 1:numTimesteps
    terminalVoltages(t) = ParallelStringArray(t, chosenStringIndex).V_Terminal;
end
figure(1)
plot(time,terminalVoltages);
xlabel('Time (s)');
ylabel('Terminal Voltage (V)');
title(sprintf('Terminal Voltage of String %d Over Time', chosenStringIndex));

%% 2 Plot all Strings

numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
numStrings = size(ParallelStringArray, 2); % Number of strings

% Preallocate matrix for efficiency
terminalVoltagesMatrix = zeros(numTimesteps, numStrings);

% Extract terminal voltages for each string
for s = 1:numStrings
    for t = 1:numTimesteps
        terminalVoltagesMatrix(t, s) = ParallelStringArray(t, s).V_Terminal;
    end
end

% Plot the terminal voltage of each string over time
figure(2); % Create a new figure window
hold on; % Hold on to plot multiple lines
for s = 1:numStrings
    plot(time,terminalVoltagesMatrix(:, s), 'DisplayName', sprintf('String %d', s));
    s;
    % pause;
end
hold off;

xlabel('Time (s)');
ylabel('Terminal Voltage (V)');   
title('Terminal Voltage of All Strings Over Time');
%legend('show'); % Show legend to identify the strings


%% 3 Plot the Variance between cells 

% Assuming ParallelStringArray is already imported

% Step 1: Extract Terminal Voltages
numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
numStrings = size(ParallelStringArray, 2); % Number of strings

terminalVoltagesMatrix = zeros(numTimesteps, numStrings);

for t = 1:numTimesteps
    for s = 1:numStrings
        terminalVoltagesMatrix(t, s) = ParallelStringArray(t, s).V_Terminal;
    end
end

% Step 2: Calculate Voltage Spread (Max-Min Difference)
voltageSpread = max(terminalVoltagesMatrix, [], 2) - min(terminalVoltagesMatrix, [], 2);

% Step 3: Plot Voltage Spread Over Time
figure(3);
plot(time,voltageSpread);
xlabel('Time (s)');
ylabel('Voltage Spread (V)');
title('Voltage Spread Across Strings Over Time');

%% 4 Plot Vp1 


% Index of the string to plot
chosenStringIndex = 12; % Example: plot the first string

numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
terminalVoltages = zeros(numTimesteps, 1); % Preallocate for terminal voltages

for t = 1:numTimesteps
    VPol1(t) = ParallelStringArray(t, chosenStringIndex).CurrentVp1;
    VPol2(t) = ParallelStringArray(t, chosenStringIndex).CurrentVp2;
    
end
VPolTotal = VPol2+ VPol1;


WantedPoints = [1,2:PlotDensity:numTimesteps];

VPol1Reduced  = VPol1(WantedPoints);
VPol2Reduced  = VPol2(WantedPoints);
VPolTotalReduced = VPolTotal(WantedPoints);

Time_WantedPoints = WantedPoints.*ParamData.timestepSize;

 fig4 = figure(4);
plot(Time_WantedPoints,VPol1Reduced);
hold on
plot(Time_WantedPoints,VPol2Reduced);
hold on
plot(Time_WantedPoints,VPolTotalReduced);
xlabel('Time (s)');
ylabel('PolorisationVoltage (V)');
title(sprintf('Polarisation Voltage %d Over Time', chosenStringIndex));
legend('Vp1','Vp2','VpTotal')
% semilogy(time,VPol1);

% max(VPol1)
% min(VPol1)
%% 4 Plot Current Capacity 


% Index of the string to plot
chosenStringIndex = 12; % Example: plot the first string

numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
terminalVoltages = zeros(numTimesteps, 1); % Preallocate for terminal voltages
Capacity = zeros(numTimesteps,1);
for t = 1:numTimesteps
    Capacity(t) = ParallelStringArray(t, chosenStringIndex).CurrentCapacity;
end
figure(5)
plot(time,Capacity);
xlabel('Time (s)');
ylabel('Capacity (V)');
title(sprintf('Terminal Voltage of String %d Over Time', chosenStringIndex));


%% PlotCapacityVariance

CellCapacities = zeros(1, numStrings);

for i = 1:numStrings
CellCapacities(i)= ParallelStringArray(1,i).TotalCapacity;
end
figure(6)

    scatter(1:numStrings,CellCapacities)




    %% Plot Average V_T + Max and Min at each TimeStep 

% % Assuming ParallelStringArray is already imported for 
% 
% % Step 1: Extract Terminal Voltages
% numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
% numStrings = size(ParallelStringArray, 2); % Number of strings
% 
% terminalVoltagesMatrix = zeros(numTimesteps, numStrings);
% CapacityMatrix = zeros(numTimesteps, numStrings);
% for t = 1:numTimesteps
%     for s = 1:numStrings
%         terminalVoltagesMatrix(t, s) = ParallelStringArray(t, s).V_Terminal;
%         CapacityMatrix(t,s) = ParallelStringArray(t,s).CurrentCapacity;
%     end
% end
% 
% AverageVT = zeros(1,numTimesteps);
% AverageCapacity = zeros(1,numTimesteps);
% MaxVT= zeros(1,numTimesteps);
% MinVT= zeros(1,numTimesteps);
% %Average Max and Min
% for i = 1:numTimesteps
% 
%     AverageVT(i) = mean(terminalVoltagesMatrix(i,:));
%     MaxVT(i) = max(terminalVoltagesMatrix(i,:));
%     MinVT(i) = min(terminalVoltagesMatrix(i,:));
%     AverageCapacity(i) = mean(CapacityMatrix(i,:));
% 
% end
% 
% fig7 = figure(7);
% 
% fig7.Position = [100 100 1200 280];
% % Now, set the axes size relative to the figure
% ax7 = axes('Parent', fig7);% 'Position', [left bottom width height]);  % values are normalized relative to the figure
% 
% % Example: Create axes that take up the full figure
% ax7.Position = [0.05, 0.18, 0.92, 0.78];  % 10% padding on all sides
% 
% 
% plot(time,AverageVT,Color=[0.2 0.7 0.8],LineStyle="-",LineWidth=1.5);
% hold on
% plot(time,MaxVT,Color=[ 0.85,0.33,0.10],LineStyle="--",LineWidth=1.5);
% plot(time,MinVT,Color=[ 0.85,0.33,0.10],LineStyle="-.",LineWidth=1.5);
% 
% % yyaxis right
% % plot(time,AverageCapacity, Color = [0.45,0.00,0.74],LineStyle='-',LineWidth=1.5);
% xlabel('Time (hrs)',FontName='ArialBold',FontSize=10,FontWeight='bold')
% ylabel('Terminal Voltage (V)',FontName='ArialBold',FontSize=10,FontWeight='bold');
% set(gca, "Box" ,'on')
% set(gca,'LineWidth',1.5)
% set(gca,"FontWeight",'bold','FontSize',10,'FontName','Arial')
% 
% 
% ylim([2.2,5])
%  legend('Average VT','Maximum VT','Minimum VT','Capacity',FontName='ArialBold',FontSize=10,FontWeight='bold')
% 
% % TotalCapacityRemaining Calc in Wh cos Ah is per cell. 
% 
% 
% ax = gca; % Get the handle of the current axes
% 
% % Suppose your x-axis currently goes from 0 to 14400 seconds (i.e., 4 hours)
% % and you want to set ticks every 3600 seconds (i.e., every hour)
% ax.XLim = [0, max(time)];  % Set x-axis limits from 0 to 4 hours in seconds
% 
% % Set x-ticks for every hour
% hrsTicks = 0:3600:57270;  % Time in seconds
% ax.XTick = hrsTicks;
% 
% % Convert the tick labels to hours
% hrsTickLabels = arrayfun(@(x) sprintf('%d hrs', x/3600), hrsTicks, 'UniformOutput', false);
% ax.XTickLabel = hrsTickLabels;
% 
% % Optionally, if you want to increase the intervals to every other hour, you can do:
% ax.XTick = 0:7200:max(time);  % Every two hours in seconds
% ax.XTickLabel = arrayfun(@(x) sprintf('%d hrs', x/3600), ax.XTick, 'UniformOutput', false);
% 
% % Refresh the plot
% drawnow;
% % Step 2: Calculate Voltage Spread (Max-Min Difference)
% % voltageSpread = max(terminalVoltagesMatrix, [], 2) - min(terminalVoltagesMatrix, [], 2);
% 
% % Step 3: Plot Voltage Spread Over Time
% % figure(3);
% % plot(time,voltageSpread);
% % xlabel('Time (s)');
% % ylabel('Voltage Spread (V)');
% % title('Voltage Spread Across Strings Over Time');

    
%% Plot fig 7 again but with two axis including capacity + NON VARIANT DATA
% Step 1: Extract Terminal Voltages from Variant Data
numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
numStrings = size(ParallelStringArray, 2); % Number of strings

terminalVoltagesMatrix = zeros(numTimesteps, numStrings);
CapacityMatrix = zeros(numTimesteps, numStrings);
for t = 1:numTimesteps
    for s = 1:numStrings
        terminalVoltagesMatrix(t, s) = ParallelStringArray(t, s).V_Terminal;
        CapacityMatrix(t,s) = ParallelStringArray(t,s).CurrentCapacity;
    end
end

AverageVT = zeros(1,numTimesteps);
AverageCapacity = zeros(1,numTimesteps);
MaxVT= zeros(1,numTimesteps);
MinVT= zeros(1,numTimesteps);
%Average Max and Min
for i = 1:numTimesteps

    AverageVT(i) = mean(terminalVoltagesMatrix(i,:));
    MaxVT(i) = max(terminalVoltagesMatrix(i,:));
    MinVT(i) = min(terminalVoltagesMatrix(i,:));
    AverageCapacity(i) = mean(CapacityMatrix(i,:));

end

% Extract Values from NonVariantData
FileNumber =118;
filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);
%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArrayNonVar = data.ParallelStringArray;
filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);
paramdata = load(filePath);
ParamDataNonVar = paramdata.simulationParams;
timeNonVar = (1:5:ParamDataNonVar.totaltimestep).*ParamDataNonVar.timestepSize;

numTimestepsNonVar = length(timeNonVar);
NonVarV_T = zeros(1,numTimestepsNonVar);    
NonVarCapacity = zeros(1,numTimestepsNonVar);
for i = 1:numTimestepsNonVar
    NonVarV_T(i) = ParallelStringArrayNonVar(i,1).V_Terminal;
    NonVarCapacity(i) = ParallelStringArrayNonVar(i,1).CurrentCapacity;
end


 


fig7 = figure(7);
fig7.Position = [100, 100, 1200, 280];

ax7 = axes('Parent', fig7);
ax7.Position = [0.05, 0.18, 0.92, 0.78];  % Adjust the axes size as needed

% Plot the voltage data on the left y-axis
yyaxis left
plot(ax7, time, AverageVT, 'Color', [0.2, 0.7, 0.8], 'LineStyle', "-", 'LineWidth', 1.5);
hold on
plot(ax7, time, MaxVT, 'Color', [0.85, 0.33, 0.10], 'LineStyle', "--", 'LineWidth', 1.5);
plot(ax7, time, MinVT, 'Color', [0.85, 0.33, 0.10], 'LineStyle', "-.", 'LineWidth', 1.5);
% plot(ax7,timeNonVar,NonVarV_T,Color=[0.2,0.7,0.8],LineStyle='--',LineWidth=1);

% Set properties for the left y-axis
ylabel('Terminal Voltage (V)', 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
ylim([2.5, 4.2]);

% Set properties for the right y-axis
yyaxis right
plot(ax7, time, AverageCapacity, 'Color', [0.45, 0, 0.74], 'LineStyle', '-', 'LineWidth', 1.5);
plot(ax7, timeNonVar, NonVarCapacity, 'Color', [0.45, 0, 0.74], 'LineStyle', '--', 'LineWidth', 1.5);
ylabel('Average Capacity (Ah)', 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
% Adjust the right y-axis limits and tick marks as necessary
% For example:
% ylim([0, maxCapacity]);
% yticks(0:step:maxCapacity);

% Set x-axis properties
xlim([0 max(time)-1]);
xlabel('Time (hrs)', 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold');
% Convert time from seconds to hours for the x-axis
xticks(0:3600:time(end));  % Replace num_of_ticks with the number of tick marks you want
xticklabels(arrayfun(@(t) sprintf('%.1f', t/3600), get(ax7, 'XTick'), 'UniformOutput', false)); % Format as hours
xlim([0 82000])
% Set box and line width for both axes
set(ax7, 'Box', 'on', 'LineWidth', 1.5, 'FontWeight', 'bold', 'FontSize', 10, 'FontName', 'Arial');

% Add legend
lgd = legend('Average VT', 'Maximum VT', 'Minimum VT', 'Capacity','Ideal Capacity', 'FontName', 'Arial', 'FontSize', 10, 'FontWeight', 'bold' ,Interpreter='tex',location = 'northoutside',orientation = 'horizontal');
lgd_pos = lgd.Position;
set(lgd, LineWidth = 0.5);
% Manually adjust the height of the legend
% Increase the height by changing the fourth element of the position vector
lgd.Position = [lgd_pos(1), lgd_pos(2), lgd_pos(3), lgd_pos(4)]; % Adjust the multiplier as needed
% Ensure the plot holds the settings
hold off


%% Plot Average V_T + strongest and weakest cell

% Assuming ParallelStringArray is already imported

% Step 1: Extract Terminal Voltages
numTimesteps = size(ParallelStringArray, 1); % Number of timesteps
numStrings = size(ParallelStringArray, 2); % Number of strings

terminalVoltagesMatrix = zeros(numTimesteps, numStrings);

for t = 1:numTimesteps
    for s = 1:numStrings
        terminalVoltagesMatrix(t, s) = ParallelStringArray(t, s).V_Terminal;
    end
end

AverageVT = zeros(1,numTimesteps);
MaxVT= zeros(1,numTimesteps);
MinVT= zeros(1,numTimesteps);
%Average Max and Min
for i = 1:numTimesteps

    AverageVT(i) = mean(terminalVoltagesMatrix(i,:));
    % MaxVT(i) = max(terminalVoltagesMatrix(i,:));
    % MinVT(i) = min(terminalVoltagesMatrix(i,:));


end
Strongest = 1;
Weakest = 4;
fig8 = figure(8);

fig8.Position = [100 100 1200 280];
% Now, set the axes size relative to the figure
ax8 = axes('Parent', fig8);% 'Position', [left bottom width height]);  % values are normalized relative to the figure

% Example: Create axes that take up the full figure
ax8.Position = [0.05, 0.18, 0.85, 0.78];  % 10% padding on all sides
plot(time,AverageVT,Color=[0.2 0.7 0.8],LineStyle="-",LineWidth=1.5);
hold on
plot(time,terminalVoltagesMatrix(:,Strongest),Color=[ 0.85,0.33,0.10],LineStyle="--",LineWidth=1.5);
plot(time,terminalVoltagesMatrix(:,Weakest),Color=[ 0.85,0.33,0.10],LineStyle="-.",LineWidth=1.5);



xlabel('Time (s)',FontName='ArialBold',FontSize=10,FontWeight='bold')
ylabel('Terminal Voltage (V)',FontName='ArialBold',FontSize=10,FontWeight='bold');
set(gca, "Box" ,'on')
set(gca,'LineWidth',1.5)
set(gca,"FontWeight",'bold','FontSize',10,'FontName','Arial')

xlim([0 11000])
ylim([2.5,4.2])
legend('Average VT','Strongest Cell VT','Weakest Cell VT',FontName='ArialBold',FontSize=10,FontWeight='bold')

% TotalCapacityRemaining Calc in Wh cos Ah is per cell. 



% xlim([0 max(time)])
ylim([2.5,4.2])
 % legend()
ax = gca; % Get the handle of the current axes

% Suppose your x-axis currently goes from 0 to 14400 seconds (i.e., 4 hours)
% and you want to set ticks every 3600 seconds (i.e., every hour)
ax.XLim = [0, max(time)];  % Set x-axis limits from 0 to 4 hours in seconds

% Set x-ticks for every hour
hrsTicks = 0:3600:max(time);  % Time in seconds
ax.XTick = hrsTicks;

% Convert the tick labels to hours
hrsTickLabels = arrayfun(@(x) sprintf('%d hrs', x/3600), hrsTicks, 'UniformOutput', false);
ax.XTickLabel = hrsTickLabels;

% Optionally, if you want to increase the intervals to every other hour, you can do:
ax.XTick = 0:7200:max(time);  % Every two hours in seconds
ax.XTickLabel = arrayfun(@(x) sprintf('%d hrs', x/3600), ax.XTick, 'UniformOutput', false);

% Refresh the plot
drawnow;

%% Variance Plot


% VarainceBalanced = MaxVT - MinVT;

% Extract Values from NonBalancedData
FileNumber =115;
filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);
%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArrayNonBal = data.ParallelStringArray;
filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);
paramdata = load(filePath);
ParamDataNonBal = paramdata.simulationParams;
timeNonVar = (1:5:ParamDataNonBal.totaltimestep).*ParamDataNonBal.timestepSize;

numTimestepsNonVar = length(timeNonVar);
   
NonVarCapacity = zeros(1,numTimestepsNonVar);
terminalVoltagesMatrixNonBal  = zeros(numTimesteps, numStrings);
for t = 1:numTimestepsNonVar 
    for s = 1:numStrings
        terminalVoltagesMatrixNonBal(t, s) = ParallelStringArrayNonBal(t, s).V_Terminal;
    end
end

NonBalVariance = zeros(1,numTimestepsNonVar);
for i = 1:numTimestepsNonVar 

    NonBalVariance(i) = max(terminalVoltagesMatrixNonBal(i,:)) - min(terminalVoltagesMatrixNonBal(i,:));

end

figure (9)

plot(time,voltageSpread);
hold on
plot(timeNonVar,NonBalVariance);                  

legend


%% Capacity of all three
numStrings=24;

% IdealPack
FileNumber =118;
filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);
%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArrayIdeal = data.ParallelStringArray;
filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);
paramdata = load(filePath);
ParamDataIdea = paramdata.simulationParams;
timeIdeal = (1:5:ParamDataIdea.totaltimestep).*ParamDataIdea.timestepSize;

numTimestepsIdeal= length(timeIdeal);
   

CapacityMatrixIdeal = zeros(numTimestepsIdeal, numStrings);
VTMatrixIdeal = zeros(numTimestepsIdeal, numStrings);
for t = 1:numTimestepsIdeal 
    for s = 1:numStrings
        CapacityMatrixIdeal(t, s) = ParallelStringArrayIdeal(t, s).CurrentCapacity;
        VTMatrixIdeal(t,s)= ParallelStringArrayIdeal(t, s).V_Terminal;
    end
end
IdealCapacity = zeros(1,numTimestepsIdeal);
MinVT_Ideal = zeros(1,numTimestepsIdeal);
MaxVT_Ideal = zeros(1,numTimestepsIdeal);
for i = 1:numTimestepsIdeal 

    IdealCapacity(i) = sum(CapacityMatrixIdeal(i,:));
    MinVT_Ideal(i) = min(VTMatrixIdeal(i,:));
MaxVT_Ideal(i) = max(VTMatrixIdeal(i,:));
end

% BalancedPack
FileNumber =120 ;
filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);
%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArrayBal = data.ParallelStringArray;
filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);
paramdata = load(filePath);
ParamDataBal = paramdata.simulationParams;
timebal = (1:5:ParamDataBal.totaltimestep).*ParamDataBal.timestepSize;

numTimestepsbal= length(timebal);
   

capacityMatrixbal = zeros(numTimestepsbal, numStrings);
VTMatrixBal  = zeros(numTimestepsbal, numStrings);
for t = 1:numTimestepsbal
    for s = 1:numStrings
        capacityMatrixbal(t, s) = ParallelStringArrayBal(t, s).CurrentCapacity;
        VTMatrixBal (t,s) = ParallelStringArrayBal(t, s).V_Terminal;
    end
end
MinVT_Bal = zeros(1,numTimestepsbal);
BalCapacity = zeros(1,numTimestepsbal);
MaxVT_Bal = zeros(1,numTimestepsbal);
for i = 1:numTimestepsbal
   BalCapacity(i) = sum(capacityMatrixbal(i,:)) ;
   MinVT_Bal (i) = min(VTMatrixBal(i,:));
   MaxVT_Bal (i) = max(VTMatrixBal(i,:));
end


% Extract Values from NonBalancedData
FileNumber =119;
filePath = sprintf('DataOutput/SimulatorOutputData-%d.mat', FileNumber);
%Load Data
data = load(filePath);
% Assuming 'ParallelStringArray' is the variable name in the .mat file
ParallelStringArrayNonBal = data.ParallelStringArray;
filePath = sprintf('DataOutput/SimulatorParameterData-%d.mat', FileNumber);
paramdata = load(filePath);
ParamDataNonBal = paramdata.simulationParams;
timeNonVar = (1:5:ParamDataNonBal.totaltimestep).*ParamDataNonBal.timestepSize;

numTimestepsNonBal = length(timeNonVar);
   

CapacityMatrixNonBal  = zeros(numTimestepsNonBal, numStrings);
VTMattrixNonBal = zeros(numTimestepsNonBal, numStrings);
for t = 1:numTimestepsNonBal 
    for s = 1:numStrings
        CapacityMatrixNonBal(t, s) = ParallelStringArrayNonBal(t, s).CurrentCapacity;
        VTMattrixNonBal(t,s) = ParallelStringArrayNonBal(t, s).V_Terminal;
        
    end
end

NonBalCapacity = zeros(1,numTimestepsNonBal);
MinVT_NonBal= zeros(1,numTimestepsNonBal);
MaxVT_NonBal = zeros(1,numTimestepsNonBal);
for i = 1:numTimestepsNonBal

    NonBalCapacity(i) = sum(CapacityMatrixNonBal(i,:));
    MinVT_NonBal(i) = min(VTMattrixNonBal(i,:));
    MaxVT_NonBal(i) = max(VTMattrixNonBal(i,:));
end
%%


% figure (10)

% plot(timeNonVar,NonBalCapacity)
% hold on
% plot(timebal,BalCapacity)
% hold on
% plot(timeIdeal,IdealCapacity)
% legend
% xlim([0 59000]);
% legend('Non Balanced', 'Balanced', 'Ideal')


figure (11)
plot(timeNonVar,MinVT_NonBal,Color=[0.2 0.7 0.8],LineStyle="-",LineWidth=1.5)
hold on
plot(timebal,smooth(MinVT_Bal),Color=[0.8 0.2 0.7],LineStyle="-",LineWidth=1.5)
hold on
plot(timeIdeal,MinVT_Ideal,Color=[0.7 0.8 0.2],LineStyle="-",LineWidth=1.5)
legend
% xlim([0 60000]);
lgd = legend('Non Balanced', 'Balanced', 'Ideal',FontName='ArialBold',FontSize=10,FontWeight='bold');
set(lgd,"LineWidth",0.5)
ylabel('Minimum Terminal Voltage (V)')
xlabel('Time (s)')
set(gca, "Box" ,'on')
set(gca,'LineWidth',1.5)
set(gca,"FontWeight",'bold','FontSize',10,'FontName','Arial')
ax = gca; % Get the handle of the current axes

% Suppose your x-axis currently goes from 0 to 14400 seconds (i.e., 4 hours)
% and you want to set ticks every 3600 seconds (i.e., every hour)
ax.XLim = [0, max(timeIdeal)];  % Set x-axis limits from 0 to 4 hours in seconds

% % Set x-ticks for every hour
% hrsTicks = 0:3600:max(timeIdeal);  % Time in seconds
% ax.XTick = hrsTicks;
% 
% % Convert the tick labels to hours
% hrsTickLabels = arrayfun(@(x) sprintf('%d hrs', x/3600), hrsTicks, 'UniformOutput', false);
% ax.XTickLabel = hrsTickLabels;

% Optionally, if you want to increase the intervals to every other hour, you can do:
ax.XTick = 0:3600*5:max(timeIdeal);  % Every two hours in seconds
ax.XTickLabel = arrayfun(@(x) sprintf('%d hrs', x/3600), ax.XTick, 'UniformOutput', false);

% Refresh the plot
drawnow;
% figure (12)
% plot(timeNonVar,MaxVT_NonBal)
% hold on
% plot(timebal,MaxVT_Bal)
% hold on
% plot(timeIdeal,MaxVT_Ideal)
% legend
% xlim([0 59000]);
% legend('Non Balanced', 'Balanced', 'Ideal')







