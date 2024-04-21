%%
close all
clear all

%NOTE: Current Leaving Pack is negative!

disp("Starting Simulation")
disp("SettingUp Simulation Parameters")
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%Program Paramers
global timestep
timestep = 0.5; % seconds

t_lengthExpected =450000;




% global t_current
t_current =1;

SavingEnabled = 1;
SavingDensity = 5;
BalancingEnabled =1;
BalancingEveryPeriod = round(0.25/timestep); % Balance every x seconds but values adjusted for timestep and rounded to make integer
OutputItterEveryNumber = 25000;
MaxSimulationLength = t_lengthExpected     ;
IntergrationMethod = 'RK4' ; % 'Euler' or 'RK4' (or 'None')
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell Input Paramaters:

%CellParameter = ImportCellParameters();

NominalCapacity = 3.5; %Units = Ah
CapacityStdDev = 0.04; % Units in %

NominalResistance = 0.18; % Units = ohms
ResistanceStdDev =  0.04;  % Units in %

Rp1Nom = 0.053;
Rp1Std =  0.03;
Rp2Nom = 0.03;
Rp2Std =  0.036;

Cp1Nom= 1590;
Cp1Std =  300;
Cp2Nom = 12600;
Cp2Std =  3733.24;

Ideal =0;
if Ideal ==1

CapacityStdDev = 0; % Units in %
ResistanceStdDev =  0;  % Units in %
Rp1Std =  0;
Rp2Std =  0;
Cp1Std =  0;
Cp2Std =  0;
end


%FOr Cell 52
% NominalResistance = 0.27; % Units = ohms
% ResistanceStdDev = 0.0;  % Units in %
% 
% Rp1Nom = 0.1;
% Rp1Std = 0.0;
% Rp2Nom = 0.07;
% Rp2Std = 0.0;
% 
% % Cp1Nom= 400;
% % Cp1Std = 0;
% % Cp2Nom = 15.79e3;
% % Cp2Std = 0;
% 
% Cp1Nom= 400e15;
% Cp1Std = 0;
% Cp2Nom = 15.79e30;
% Cp2Std = 0;


%%%%%%%%%%%%%%%%%%%%%%%%%%
% Cell SOC - OCV array
global CellSOC_OCV_Table
% CellSOC_OCV_Table  = [1 0.9943 0.9714 0.8571 0.7857 0.7143 0.5714 0.4286 0.2857 0.2143 0.1429 0.1143 0.0857 0.0571 0.0429 0.0286 0.0143 0;
%                        4.2 4.1 4.05 4 3.93 3.85 3.73 3.58 3.42 3.31 3.17 3.11 3.03 2.93 2.85 2.77 2.65 2.5];
disp("Importing SOC Curve");
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

%If Chosing Starting Voltage:
VOCV_Start = 4.2;
VTerminalStart = VOCV_Start;
SOC_Start = interp1(CellSOC_OCV_Table(2,:),CellSOC_OCV_Table(1,:),VOCV_Start);


ParallelStringArrayInit = PackInitialisation(NominalCapacity,CapacityStdDev,NominalResistance,ResistanceStdDev,SeriesCells,ParallelCells,VTerminalStart,VOCV_Start,SOC_Start,0,Rp1Nom,Rp1Std,Cp1Nom,Cp1Std,Rp2Nom,Rp2Std,Cp2Nom,Cp2Std);

SortedCellsID = 1:1:24;
SortedCellsIDStore = zeros(t_lengthExpected,SeriesCells);
BalanceStatus = zeros(1,SeriesCells);
BalanceStatusStore = zeros(t_lengthExpected,SeriesCells);

CurrentModifier = zeros(1,SeriesCells);
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Current Draw Setup

% PackCurrentDraw = -5*ParallelCells;   % in Amps (A)
% zz = 0;

Pos = -0.5;
Neg = 0.5 ;
% % CurrentFunction = @(t) -1 .* (t < 5000) + 0 .* (t >= 5000);
% tIntervals = [0, 5, 45, 225 ,260,685]./timestep;
% tIntervals = [0, 5, 35, 75 ,85,685]./timestep;
% CurrentVal = [0, Pos, 0, Neg, 0 ];
% 
% CurrentFunction = @(t)  (t < tIntervals(2)).*CurrentVal(1) +...
%                         (t >=tIntervals(2) & t <tIntervals(3)).*CurrentVal(2) +...
%                         (t >=tIntervals(3) & t <tIntervals(4)).*CurrentVal(3) +...
%                         (t >=tIntervals(4) & t <tIntervals(5)).*CurrentVal(4) +...
%                         (t >=tIntervals(5) & t <tIntervals(6)).*CurrentVal(5); % Set I to 0 after final instruction
% 

% tIntervals = [0, 5, 125, 1325]./timestep;
% CurrentVal = [0, Neg, 0];
% 
% CurrentFunction = @(t)  (t < tIntervals(2)).*CurrentVal(1) +...
%                         (t >=tIntervals(2) & t <tIntervals(3)).*CurrentVal(2) +...
%                         (t >=tIntervals(3) & t <tIntervals(4)).*CurrentVal(3);
%                         % (t >=tIntervals(4) & t <tIntervals(5)).*CurrentVal(4) +...
%                         % (t >=tIntervals(5) & t <tIntervals(6)).*CurrentVal(5); % Set I to 0 after final instruction
% % CurrentFunction = @(t) -3;
% 
% global GlobalCurrent;
 GlobalCurrent = -10;
% CurrentFunction = @(t) GlobalCurrent;
% CurrentInput  = importdata("CurrentInput.mat");
% % CurrentInput = interp1([1:1:length(CurrentInputTemp)],CurrentInputTemp,[1:0.5:length(CurrentInputTemp)]);
% CurrentFunction = @(t) CurrentInput(round(t));

ParallelStringArray(t_current,:) = ParallelStringArrayInit;

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Main Loop:
disp("Starting Main Loop")
StartTime = tic;

VLimitFlag = zeros(1,SeriesCells);
CurrentFlipCounter = 0;
InRestPeriod = 0;
RestCounter = 0;
CurrentOption = -2;
MaxCurrentFlips = 11;
tempParallelStringArray = ParallelString.PreAllocate(SeriesCells, 1);
tempVLimitFlag = zeros(1, SeriesCells);
while any(VLimitFlag == 0) && t_current <MaxSimulationLength

CurrentFunction = @(t) GlobalCurrent;  
VLimitFlag = zeros(1,SeriesCells);
%For Dynamic Current Draw add a function here that changed PackCurrentDraw


    for i = 1:SeriesCells
       % if strcmp(IntergrationMethod, 'RK4')
        [tempParallelString,tempFlag ] = CellExchangeRK4(ParallelStringArray(t_current,i),CurrentFunction,ParallelCells,CurrentModifier(i),t_current);
       
        tempParallelStringArray(i) = tempParallelString;
        tempVLimitFlag(i) = tempFlag;
       % elseif strcmp(IntergrationMethod, 'Euler')
        % ParallelStringArray(t_current+1,i) = CellExchangeEuler(ParallelStringArray(t_current,i),CurrentFunction,ParallelCells,CurrentModifier(i));
       % else
       %     disp('No intergration method chosen. Please try again')
       %     return;   
       % end
       
    end
ParallelStringArray(t_current+1,:) = tempParallelStringArray;
VLimitFlag = tempVLimitFlag;

    % if any(VLimitFlag == 1)
    %     break;
    % end

    % From Next Set of cell voltages, Work out the next set of balance
    % instructions. 
    
    if BalancingEnabled ==1
        if(rem(t_current,BalancingEveryPeriod))==0
        [BalanceStatus, SortedCellsID] = BalancingAlgV1(ParallelStringArray(t_current+1,:),SeriesCells,SortedCellsID);
        BalanceStatusStore(t_current+1,:)= BalanceStatus;
        SortedCellsIDStore(t_current+1,:)= SortedCellsID;
        CurrentModifier = BalanceStatusProcessor(BalanceStatus,SeriesCells);
        end
    end


    if rem(t_current,OutputItterEveryNumber)==0
        disp(t_current);
    end
    t_current = t_current+1;

    if any(VLimitFlag == 1 )
        CurrentFlipCounter = CurrentFlipCounter +1
        InRestPeriod = 1
        VLimitFlag = 0;
        if CurrentFlipCounter == MaxCurrentFlips
            MaxSimulationLength = t_current +3600/timestep;
            VLimitFlag =0;
            GlobalCurrent = 0;
            CurrentStopAtStep = t_current;
        end
    end

    if InRestPeriod == 1
        GlobalCurrent = 0;
        RestCounter = RestCounter +1;
        if RestCounter == 3600/timestep
            RestCounter=0;
            InRestPeriod=0
            GlobalCurrent = (-1)^CurrentFlipCounter*CurrentOption;
        end
    end
    % if any(VLimitFlag == 1 )
    %     VLimitFlag = 0;
    % end


end

%Trim UnusedPortion

ParallelStringArray = ParallelStringArray(1:SavingDensity:t_current,:);

BalanceStatusStore = BalanceStatusStore(1:SavingDensity:t_current,:);
endTime = toc(StartTime); % /SeriesCells;


fprintf("Time Taken: %f \n", round(endTime,5));      
%%
%Save Data 

if SavingEnabled == 1
tic;
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

% nextFileNumber = 94;
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
                                         'ResistanceStdDev', ResistanceStdDev,...
                                         'Rp1Nom', Rp1Nom, ...
                                         'Rp1Std', Rp1Std ,...
                                         'Cp1Non',Cp1Nom, ...
                                         'Cp1Std',Cp1Std, ...
                                         'Rp2Nom', Rp2Nom, ...
                                         'Rp2Std',Rp2Std, ...
                                         'Cp2Nom',Cp2Nom, ...
                                         'Cp2Std',Cp2Std ...
                                         );
simulationParams.TimeTaken = round(endTime,1);
% simulationParams.CurrentChange = CurrentStopAtStep;

% Example cell parameters

simulationParams.ParallelCells = ParallelCells; % Example additional parameter
simulationParams.SeriesCells = SeriesCells;
simulationParams.parallelStringArrayFile = newFileName; % Reference to main data file
simulatonParams.TimeTaken = endTime;

% Save parameters to a .mat file
newParamFileName = sprintf('SimulatorParameterData-%d.mat', nextFileNumber);
fullParamPath = fullfile(folderPath, newParamFileName);
save(fullParamPath, 'simulationParams');

disp ("Saving Data Done");
fprintf("Time Taken to Save: %4f \n", toc); 
else
    disp("Skipping Save ")
end

%%
% Any Post Processing

% % Assuming you want the terminal voltage of the first string of cells
% stringIndex = 1; % Index of the string you're interested in
% numTimesteps = t_current; % Number of timesteps
% f
% % Preallocate an array for the terminal voltages
% terminalVoltages = zeros(numTimesteps, 1);
% 
% % Extract the terminal voltage for each timestep
% for t_current = 1:numTimesteps
%     terminalVoltages(t_current) = ParallelStringArray(t_current, stringIndex).V_Terminal;
% end
% plot(terminalVoltages);
% xlabel('Time Step');
% ylabel('Terminal Voltage (V)');
% title('Terminal Voltage of String Over Time');
