classdef ParallelString
    properties
        TotalCapacity 
        InternalResistance
        Rp1
        Cp1
        Rp2
        Cp2
        CurrentCapacity
        CurrentSOC
        V_Terminal
        V_OCV
        CurrentCurrent
        CellSeriesID
        CurrentVp1
        CurrentVp2
        
    end

    methods
        function obj = ParallelString(SeriesID,TotalCapacity, InternalResistance, CurrentCapacity,CurrentSOC, V_Terminal, V_OCV,CurrentCurrent,CurrentVp1,CurrentVp2,Rp1,Rp2,Cp1,Cp2)
            % Constructor function for ParallelString class
            if nargin == 14
                obj.CellSeriesID = SeriesID;
                obj.TotalCapacity = TotalCapacity;
                obj.InternalResistance = InternalResistance;
                obj.CurrentCapacity = CurrentCapacity;
                obj.V_Terminal = V_Terminal;
                obj.V_OCV = V_OCV;
                obj.CurrentSOC = CurrentSOC;
                obj.CurrentCurrent = CurrentCurrent;
                obj.CurrentVp1 = CurrentVp1;
                obj.CurrentVp2 = CurrentVp2;
                obj.Rp1 = Rp1;
                obj.Rp2 = Rp2;
                obj.Cp1 = Cp1;
                obj.Cp2 = Cp2;
            else
                display("Incorect Number of Arguments in Parallel String.m function :0")
                
            end
        end    
    end

   methods(Static)
    function objArray = PreAllocate(SeriesCells, TotalExpectedIterations)
        % Initialize one object to define the array type
        obj = ParallelString();
        % Preallocate an array of objects
        objArray(TotalExpectedIterations, SeriesCells) = obj;
        % for i = 1:TotalExpectedIterations
        %     for j = 1:SeriesCells
        %         objArray(i, j) = ParallelString();
        %     end
        % end
    end
    end
end
