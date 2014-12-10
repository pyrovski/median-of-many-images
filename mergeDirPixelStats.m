%{
input list of dirs
for each dir, add stats to global stats
%}
function [] = mergeDirPixelStats(path, dirList)
    file = fopen(dirList, 'r');
    if(file <= 0)
        return;
    end
    
    [status, result] = system( ['wc -l ', dirList, '|cut -d" " -f1'] );
    numDirs = str2num( result );
    [status, result] = system( ['wc -L ', dirList, '|cut -d" " -f1'] );
    maxLength = str2num(result);

    fprintf(1, '%d dirs\n', numDirs);
    
    clear mins maxes totals hists count;
    a = fgetl(file);
    fprintf(1, '%d of %ld: %s\n', 1, numDirs, a);
    % see if it exists already
    name = strcat(path, a, 'pixelStats.mat');
    % if does not exist, error
    if ~exist(name, 'file')
        fprintf(1, '%s does not exist\n', name);
        return;
    end
    try
        load(name);
    catch
        fprintf(1, 'error loading %s\n', a);
    end
    gtotals = totals;
    clear totals;
    gmaxes = maxes;
    clear maxes;
    gmins = mins;
    clear mins;
    gcount = count;
    clear count;
    ghists = hists;
    clear hists;
    for i=2:numDirs
	a = fgetl(file);
	fprintf(1, '%d of %ld: %s\n', i, numDirs, a);
        % see if it exists already
        name = strcat(path, a, 'pixelStats.mat');
        % if does not exist, error
        if ~exist(name, 'file')
            fprintf(1, '%s does not exist\n', name);
            continue;
        end
        try
            load(name);
        catch
            fprintf(1, 'error loading %s\n', a);
        end
        gmins = min(mins, gmins);
        gmaxes = max(maxes, gmaxes);
        gcount = count + gcount;
        gtotals = totals + gtotals;
        ghists = hists + ghists;
    end
    clear mins maxes totals hists;
    save(strcat(path, '/all.mat'), 'gmins', 'gmaxes', 'gtotals', 'ghists', 'gcount', '-v7.3');
end
