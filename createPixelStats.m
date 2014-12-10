% operate on a list of images

%{
 slow way:
    for each pixel:
        for each image:
            read pixel
            add pixel to list
        compile pixel stats
but this is equivalent to creating a histogram for each pixel for each color, each with 
256 entries.  This approach requires 540*720*3*8*256 = 2388787200 bytes.

   fast way:
    for each image:
        for each pixel:
            update pixel stats online, using approximation if necessary
Could compute distance to cone ([0,0,1],[0,1,0],[1,0,0])
c = (bSingleCone) ? acos(((Point-Apex).Axis)\(|Point-Apex|*|Axis|)) : acos(abs(((Point-Apex).Axis))\(|Point-Apex|*|Axis|)); // from dot product definition
if(abs(c - a) >= Pi/2)   return |Point-Apex|;
else   return |Point-Apex|;

from http://www.gamedev.net/topic/473029-distance-from-point-to-cone/

Matlab decodes <= 2 MBps of JPEG data on Fermi, or about 33 CS webcam images per second.
 - with hists, this is reduced to ~16 images per second

Many methods must be faster, including GPUs.
  - parallel for increases this to 1440 images in 32.8s = 2.5 MBps, or 43.9 fps.
  - this is CPU-limited, as 80 MB fits in RAM just fine
  - libjpeg-turbo gets 54 fps on a single core (3.6 MBps)
%}

function [mins, maxes, totals, hists, count] = createPixelStats(path, fileList)
    %minimum brightness threshold
    thresh = 2.5*10^7;

    % read list of images
    file = fopen(fileList, 'r');
    if(file <= 0)
        return;
    end
    
    [status, result] = system( ['wc -l ', fileList, '|cut -d" " -f1'] );
    numFiles = str2num( result );
    [status, result] = system( ['wc -L ', fileList, '|cut -d" " -f1'] );
    maxLength = str2num(result);
    a = fgetl(file);
    fseek(file,0,'bof');
    image = imread(strcat(path, '/', a));
    imSize = size(image);
    mins = uint8(255) + zeros(imSize, 'uint8');
    maxes = zeros(imSize, 'uint8');
    totals = zeros(imSize, 'uint64');

% todo this should be [imSize(1), imSize(2), 256, imSize(3)]
    hists = zeros([256 imSize], 'uint32');
    
    rows = uint32(size(image,1));
    cols = uint32(size(image,2));
    colors = uint32(size(image,3));


    % todo this should be row + col*rows + val*rows*cols + color * 256 * rows * cols
    % [x y z] = meshgrid(0:rows-1, rows*(0:cols-1), rows*cols*256*(0:colors-1));

    % don't ask me why it exchanges rows and cols
    [x y z] = meshgrid(rows*256*(0:(cols-1)), 256*(0:(rows-1)), cols*rows*256*(0:(colors-1)));
    grid = x + y + z;
    clear x y z rows cols colors;
    
    clear image;
    
    count = uint64(0);
    for i = 1:numFiles
        
        fprintf(1, '%ld of %ld\n', i, numFiles);
        a = fgetl(file);
        try
            image = imread(strcat(path, '/', a));
        catch me
            fprintf(1, 'skipping %d; error\n', i);
            continue;
        end
        s = norm(sum(squeeze(sum(image, 1)),1));
        if s < thresh
            fprintf(1, 'skipping %d; too dark (%e)\n', i, s);
            continue;
        end        
%{
Building the histogram is complicated; for each pixel, 
hists(images(row, col, color, j), row, col, color) = hists(images(row, col, color, j), row, col, color) + 1;
This can't be vectorized in matlab since dimensions are repeated.
We could expand each color of the image from 720x540 to from 720x540x256,
and set image_new(image(row,col,1),row,col,1) = 1, then add that
to hists(:,:,:,1).
The solution is to make a vector of coordinates, append it to a vector of
values, and increment hists(vector).
%}
        %hists = updateHists(hists, images(:,:,:,j));

% todo this should be (1+uint32(image))*rows*cols + grid
        coords = reshape(1 + uint32(image) + grid, [numel(grid) 1]);
        %{
        if numel(unique(coords)) ~= numel(coords)
            fprintf(1, 'coords error %d\n', i);
        end
        %}
        hists(coords) = hists(coords) + 1;
                
        count = count + 1;
                
        mins = min(image, mins);
        maxes = max(image, maxes);
        totals = totals + uint64(image);
        
    end
end
