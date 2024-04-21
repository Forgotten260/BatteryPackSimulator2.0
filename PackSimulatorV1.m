%%
close all
clear all

%NOTE: Current Leaving Pack is negative!

disp("Starting Simulation")
disp("SettingUp Simulation Parameters")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Program Paramers
global timestep
timestep = 0.05; % seconds

t_lengthExpected = 50000;

global VLimitFlag;
VLimitFlag = 0;

global t_current
t_current =1;

BalancingEnabled =0;
OutputItterEveryNumber = 1000;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell Input Paramaters:

%CellParameter = ImportCellParameters();

NominalCapacity = 3.45; %Units = Ah
CapacityStdDev = 0.028; % Units in %

NominalResistance = 0.28; % Units = ohms
ResistanceStdDev = 0.001;  % Units in %

Rp1Nom = 0.073;
Rp1Std = 0.018;
Rp2Nom = 0.05;
Rp2Std = 0.026;

Cp1Nom= 1590;
Cp1Std = 600;
Cp2Nom = 12600;
Cp2Std = 5733.24;


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell SOC - OCV array
global CellSOC_OCV_Table
% CellSOC_OCV_Table  = [1 0.9943 0.9714 0.8571 0.7857 0.7143 0.5714 0.4286 0.2857 0.2143 0.1429 0.1143 0.0857 0.0571 0.0429 0.0286 0.0143 0;
%                        4.2 4.1 4.05 4 3.93 3.85 3.73 3.58 3.42 3.31 3.17 3.11 3.03 2.93 2.85 2.77 2.65 2.5];

CellSOC_OCV_Table = ImportSOCData("SOC_OCVCurve.csv");

%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Pack Paramters

SeriesCells = 24;
ParallelCells = 2;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Variable Inits:
disp("Initalising Parameters")
ParallelStringArray = ParallelString.PreAllocate(SeriesCells,t_lengthExpected);
ParallelStringArrayInit = ParallelString.PreAllocate(SeriesCells,1); 
ParallelStringArrayInit = PackInitialisation(NominalCapacity,CapacityStdDev,NominalResistance,ResistanceStdDev,SeriesCells,ParallelCells,4.2,4.2,0,Rp1Nom,Rp1Std,Cp1Nom,Cp1Std,Rp2Nom,Rp2Std,Cp2Nom,Cp2Std);

SortedCellsID = 1:1:24;
SortedCellsIDStore = zeros(t_lengthExpected,SeriesCells);
BalanceStatus = zeros(1,SeriesCells);
BalanceStatusStore = zeros(t_lengthExpected,SeriesCells);

CurrentModifier = zeros(1,SeriesCells);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Draw Setup

PackCurrentDraw = -5*ParallelCells;   % in Amps (A)
zz = 0;

ParallelStringArray(t_current,:) = ParallelStringArrayInit;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Loop:
disp("Starting Main Loop")
while VLimitFlag == 0

%For Dynamic Current Draw add a function here that changed PackCurrentDraw

    for i = 1:SeriesCells
        CellCurrent = PackCurrentDraw +CurrentModifier(i);  %Use currentModifer to affect indivual cell current as they get balanced. 
        ParallelStringArray(t_current+1,i) = CellExchangeSR(ParallelStringArray(t_current,i),CellCurrent,ParallelCells);
    end

    % From Next Set of cell voltages, Work out the next set of balance
    % instructions. 
    if BalancingEnabled ==1
        [BalanceStatus, SortedCellsID] = BalancingAlgV1(ParallelStringArray(t_current+1,:),SeriesCells,SortedCellsID);
        BalanceStatusStore(t_current+1,:)= BalanceStatus;
        SortedCellsIDStore(t_current+1,:)= SortedCellsID;
    
        CurrentModifier = BalanceStatusProcessor(BalanceStatus,SeriesCells);
    end

    if rem(t_current,OutputItterEveryNumber)==0
        t_current
    end
    t_current = t_current+1;

end

%Trim UnusedPortion

ParallelStringArray = ParallelStringArray(1:t_current,:);

%%
%Save Data 
disp("Saving Data")
folderPath = 'DataOutput'; % Specify the target folder path
files = dir(fullfile(folderPath, 'SimulatorOutputData-*.mat'));

% Initialize an array to hold the extracted numbers
fileNumbers = zeros(length(files), 1);

% Extract the numbers from the filenames
for i = 1:length(files)
    % Use regexp to find numbers in the filenames
    numStr = regexp(files(i).name, '\d+', 'match');
    if ~isempty(numStr)
        fileNumbers(i) = str2double(numStr{1});
    end
end

% Determine the next file number
if isempty(fileNumbers)
    nextFileNumber = 1;
else
    nextFileNumber = max(fileNumbers) + 1;
end

% Construct the new filename
newFileName = sprintf('SimulatorOutputData-%d.mat', nextFileNumber);
fullFilePath = fullfile(folderPath, newFileName);

% Save the ParallelStringArray in the new file
save(fullFilePath, 'ParallelStringArray');


% To save simulation parameters if needed:

% Organize simulation parameters
simulationParams = struct();
simulationParams.timestepSize = timestep; % Example timestep size
simulationParams.totaltimestep = t_current;
simulationParams.cellParameters = struct('NominalCapacity', NominalCapacity, ...
                                         'CapacityStdDev',CapacityStdDev,...
                                         'NominalResistance', NominalResistance, ...
                                         'ResistanceStdDev', ResistanceStdDev); % Example cell parameters

simulationParams.ParallelCells = ParallelCells; % Example additional parameter
simulationParams.SeriesCells = SeriesCells;
simulationParams.parallelStringArrayFile = newFileName; % Reference to main data file

% Save parameters to a .mat file
newParamFileName = sprintf('SimulatorParameterData-%d.mat', nextFileNumber);
fullParamPath = fullfile(folderPath, newParamFileName);
save(fullParamPath, 'simulationParams');

disp ("Saving Data Done");

%%
% Any Post Processing

% Assuming you want the terminal voltage of the first string of cells
stringIndex = 1; % Index of the string you're interested in
numTimesteps = t_current; % Number of timesteps

% Preallocate an array for the terminal voltages
terminalVoltages = zeros(numTimesteps, 1);

% Extract the terminal voltage for each timestep
for t_current = 1:numTimesteps
    terminalVoltages(t_current) = ParallelStringArray(t_current, stringIndex).V_Terminal;
end
plot(terminalVoltages);
xlabel('Time Step');
ylabel('Terminal Voltage (V)');
title('Terminal Voltage of String Over Time');
