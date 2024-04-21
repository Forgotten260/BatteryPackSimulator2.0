function [ParallelString] = CellExchangeSR(ParallelString,CurrentDraw,ParallelCells)
%CELLEXCHANGESR (Series Resistance Only)
% This function is the core function that calculate the voltage and energy
% change in a cell as a result of the current suppleid to it. 

% For a normal pack with no balancing this will mean Current Draw is
% constant but for balancing pack this value may change a bit.
global CellSOC_OCV_Table;
global timestep
global VLimitFlag;

%CurrentOCV = ParallelString.V_OCV;
% ParallelString
CurrentCapacity = ParallelString.CurrentCapacity;

NewCapacity = CurrentCapacity + (CurrentDraw*timestep/3600);
NewSOC = NewCapacity/ParallelString.TotalCapacity;
NewOCV = interp1(CellSOC_OCV_Table(1,:),CellSOC_OCV_Table(2,:),NewSOC);
NewV_T = NewOCV+ (CurrentDraw/ParallelCells) * ParallelString.InternalResistance;

%INSERT CELL LIMIT STUFF HERE THEN CAN CHECK. If It's no bueno then the a
%FLAG can be triggered and somethibg cab be done about it later or
%something. Who tf knows

%Check Cell Voltage Stuff:

    if any(NewV_T>2.5 )&& any(NewV_T<4.2)
        VLimitFlag=0;
    
        ParallelString.V_OCV = NewOCV;
        ParallelString.V_Terminal = NewV_T ;
        ParallelString.CurrentCapacity = NewCapacity;
        ParallelString.CurrentSOC = NewSOC;
        ParallelString.CurrentCurrent = CurrentDraw;
        
    else
        VLimitFlag= 1;
        % Using flag like this provides better flexibility I think 
    end

end

