function [CurrentModifier] = BalanceStatusProcessor(BalanceStatus,SeriesCells)
%BalanceStatusProcessor:
%Takes in the balance stattus and then tell the simulation how to modify
%the current for each cell. This has to be done because (it's dumb) the
%simulation isn't real. In real like this would be done by 

ChargingCells =0;
DischargingCells = 0;
CurrentModifier = zeros(1,SeriesCells);

for i =1:SeriesCells
    if BalanceStatus(i) == 1
        ChargingCells = ChargingCells +1;
    elseif BalanceStatus(i) ==2
        DischargingCells = DischargingCells +1;
    end
end

Ipeak = 2; %A
TransformerTurns =2;
ChargeEff = 0.85;

ChargingCellsCurrent = Ipeak/2 * ChargingCells* TransformerTurns/(ChargingCells+TransformerTurns)*ChargeEff;
DischargingCellsCurrent = Ipeak/2 * DischargingCells/(DischargingCells+TransformerTurns);

for i = 1:SeriesCells

    if BalanceStatus(i)==1
        CurrentModifier(i) = ChargingCellsCurrent;
    elseif BalanceStatus(i) ==2
        CurrentModifier(i) = -DischargingCellsCurrent;
    end
end 


