function [medians] = mediansFromHists(hists)
    histSize = size(hists);
    histcumsums = zeros(histSize(1:3), 'single');
    histcumsummaxes = zeros(histSize(2:3), 'single');
    medians = zeros(histSize(2:4), 'uint8');
    for i=1:3
        histcumsums = cumsum(single(hists(:,:,:,i)), 1);
        histcumsummaxes = squeeze(max(histcumsums(:,:,:)));
        % find medians
        % for each pixel color,
        % medians(row, col, i) = find(histcumsums(:,row,col) >= 0.5, 1)
        for row=1:histSize(2)
            for col=1:histSize(3)
                medians(row,col,i) = find(histcumsums(:,row,col) >= .5 * histcumsummaxes(row,col), 1);
            end
            fprintf(1, 'row %d\n', row);
        end
    end
end
