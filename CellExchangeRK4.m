function [ParallelString, VLimitFlag] = CellExchangeRK4(ParallelString,I_func,ParallelCells,CurrentModifier,t_current)
%CellChargeExchanger with dynamic parameters
%   Detailed explanation goes here

global CellSOC_OCV_Table;
global timestep
VLimitFlag = 0;
% global t_current;       

CurrentCapacity = ParallelString.CurrentCapacity;
NewCapacity = CurrentCapacity + ((I_func(t_current)+CurrentModifier)*timestep/3600);
NewSOC = NewCapacity/ParallelString.TotalCapacity;
NewOCV = interp1(CellSOC_OCV_Table(1,:),CellSOC_OCV_Table(2,:),NewSOC);

CurrentVp1 = ParallelString.CurrentVp1;
CurrentVp2 = ParallelString.CurrentVp2;
NewVP1 = RK4_step(CurrentVp1, I_func, ParallelString.Rp1, ParallelString.Cp1, t_current,CurrentModifier);
NewVP2 = RK4_step(CurrentVp2, I_func, ParallelString.Rp2, ParallelString.Cp2, t_current,CurrentModifier);

NewV_T = NewOCV + (I_func(t_current)+CurrentModifier)*ParallelString.InternalResistance + NewVP1 + NewVP2;

%Change current draw to current function to pass through 
%Need to add VP1 and VP2 to the Parallel string structure to allow passing
%through :0
%

%Work out VT in the same way + new VP1 and VP2 etc

ParallelString.V_OCV = NewOCV;
ParallelString.V_Terminal = NewV_T ;
ParallelString.CurrentCapacity = NewCapacity;
ParallelString.CurrentSOC = NewSOC;
ParallelString.CurrentCurrent = I_func(t_current)+CurrentModifier;
ParallelString.CurrentVp1 = NewVP1;
ParallelString.CurrentVp2 = NewVP2;

    if any(NewV_T>2.5 )&& any(NewV_T<4.2)
        VLimitFlag=0;
        % disp("Saving Next Itter");
        % ParallelString.V_OCV = NewOCV;
        % ParallelString.V_Terminal = NewV_T ;
        % ParallelString.CurrentCapacity = NewCapacity;
        % ParallelString.CurrentSOC = NewSOC;
        % ParallelString.CurrentCurrent = I_func(t_current)+CurrentModifier;
        % ParallelString.CurrentVp1 = NewVP1;
        % ParallelString.CurrentVp2 = NewVP2;
        
    else
        VLimitFlag= 1;
        % fprintf("HitLimit on Cell Number %d", ParallelString.CellSeriesID)
        % Using flag like this provides better flexibility I think 
        
    end


end