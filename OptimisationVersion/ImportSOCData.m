function [SOC_LUT] = ImportSOCData(FileName)
%UNTITLED2 Summary of this function goes here
%   Detailed explanation goes here

O_LUT = table2array(readtable(FileName));

%Normalise Capacity and orientate so that soc 1 = 4.2V 

if any(O_LUT(1,:) == [max(O_LUT(:,1)), min(O_LUT(:,2))]) || any(O_LUT(1,:) == [min(O_LUT(:,1)), max(O_LUT(:,2))])

    Scaled_LUT(:,1) = flip(O_LUT(:,1)/max(O_LUT(:,1)));
    Scaled_LUT(:,2) = O_LUT(:,2);

else
    Scaled_LUT(:,1) = O_LUT(:,1)/max(O_LUT(:,1));
    Scaled_LUT(:,2) = O_LUT(:,2);

end

% Downsample 

%New SOC Points

SOCPoints = [linspace(0,0.15,10),linspace(0.25,0.75,5),linspace(0.775,1,10)];
VoltagePoints = interp1(Scaled_LUT(:,1),Scaled_LUT(:,2),SOCPoints,"linear");

SOC_LUT(1,:) = SOCPoints;
SOC_LUT(2,:) = VoltagePoints;


SOC_LUT = flip(SOC_LUT,2);
SOC_LUT(2,1)         = 4.2001;
SOC_LUT(2,end) =  2.4999;

end