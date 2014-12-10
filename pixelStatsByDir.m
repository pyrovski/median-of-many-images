				%{
input list of dirs
for each dir, createPixelStats, and save to disk
  this should benefit from large compression ratios
				%}
  function [] = pixelStatsByDir(path, dirList)
    file = fopen(dirList, 'r');
    if(file <= 0)
      return;
      end
      
      [status, result] = system( ['wc -l ', dirList, '|cut -d" " -f1'] );
      numDirs = str2num( result );
      [status, result] = system( ['wc -L ', dirList, '|cut -d" " -f1'] );
      maxLength = str2num(result);

      fprintf(1, '%d dirs\n', numDirs);
      
      count = uint32(0);
      for i=1:numDirs
	a = fgetl(file);
	fprintf(1, '%d of %ld: %s\n', i, numDirs, a);
		% see if it exists already
		name = strcat(path, a, 'pixelStats.mat');
		% if does not exist, ok
		% otherwise, error
		if exist(name, 'file')
		fprintf(1, '%s already exists\n', name);
			continue;
		end
		try
		[mins, maxes, totals, hists, count] = createPixelStats(strcat(path, a), strcat(path, a, '/files.txt'));
	      catch
		fprintf(1, 'error processing %s\n', a);
			end
			save(name, 'mins', 'maxes', 'totals', 'hists', 'count', '-v7.3');
			end

			end
