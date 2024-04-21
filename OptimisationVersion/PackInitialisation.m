function [ParallelStringArray] = PackInitialisation(NominalCapacity,CapacityStdDev,IntResistanceNominal,IntResistanceStdDev,SeriesCells,ParallelCells,V_TerminalStart,V_OCVStart,SOC_Start,InitalCurrentDraw,Rp1Nom,Rp1Std,Cp1Nom,Cp1Std,Rp2Nom,Rp2Std,Cp2Nom,Cp2Std)
%Function will take in cell parameters, pack dimenions and output an
%array of objects that will be the number of series cells required and flag
%to tell if everything is okay

%V_OCV and V_Terminal are both arrays passed through of the correct size to
%init the arrays with. If they're just 1x1 then it will just be duplicated
%in here
        global CellSOC_OCV_Table
        rng(53);
       
        TotalCapacity =         round((randn(SeriesCells,1)*CapacityStdDev+NominalCapacity)*ParallelCells,4) ;
        InternalResistance =    round((randn(SeriesCells,1)*IntResistanceStdDev+IntResistanceNominal)/ParallelCells,4);
        CurrentCapacity=        SOC_Start *TotalCapacity;
        Rp1 =                   round((randn(SeriesCells,1)*Rp1Std+Rp1Nom)/ParallelCells,4);
        Rp2 =                   round((randn(SeriesCells,1)*Rp2Std+Rp2Nom)/ParallelCells,4);
        Cp1 =                   round((randn(SeriesCells,1)*Cp1Std+Cp1Nom)*ParallelCells,4); % Capacitance is multipled by parallel components.
        Cp2 =                   round((randn(SeriesCells,1)*Cp2Std+Cp2Nom)*ParallelCells,4);

        if isequal(size(V_TerminalStart), [1, 1])
            V_Terminal = ones(SeriesCells, 1) * V_TerminalStart;
        else 
            V_Terminal = V_TerminalStart;
        end
        
        if isequal(size(V_OCVStart), [1, 1])
            V_OCV = ones(SeriesCells, 1) * V_OCVStart;
        else
            V_OCV = V_OCVStart;
        end

        CurrentSOC =interp1(CellSOC_OCV_Table(2,:),CellSOC_OCV_Table(1,:),V_OCV);

        
        for i = 1:SeriesCells
            ParallelStringArray(i) = ParallelString(i,TotalCapacity(i),InternalResistance(i),CurrentCapacity(i),CurrentSOC(i),V_Terminal(i),V_OCV(i),InitalCurrentDraw,0,0,Rp1(i),Rp2(i),Cp1(i),Cp2(i));
            % Set initla vp1 and vp2 to 0 for simplicity.
        end






end

