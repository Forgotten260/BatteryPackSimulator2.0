function [sortedOCVs, sortedCellIDs] = bubbleSortOCVsWithCellIDs(OCVs, cellIDs, prevSortedCellIDs)
    % Initialize sortedOCVs with the current OCV values in the order of prevSortedCellIDs
    [~, sortOrder] = ismember(prevSortedCellIDs, cellIDs);
    sortedOCVs = OCVs(sortOrder);
    sortedCellIDs = prevSortedCellIDs;
    
    % Get the number of elements
    n = length(sortedOCVs);
    
    % Perform the bubble sort algorithm
    for i = 1:n-1
        for j = 1:n-i
            % If the current item is greater than the next item, swap them
            if sortedOCVs(j) < sortedOCVs(j + 1)
                % Swap the OCVs
                tempOCV = sortedOCVs(j);
                sortedOCVs(j) = sortedOCVs(j + 1);
                sortedOCVs(j + 1) = tempOCV;
                
                % Swap the corresponding cell IDs
                tempID = sortedCellIDs(j);
                sortedCellIDs(j) = sortedCellIDs(j + 1);
                sortedCellIDs(j + 1) = tempID;
            end
        end
    end
end
