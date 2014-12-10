% assume size(hists) = [256 size(image)] and length(size(image)) = 3
function hists = updateHists(hists, image)
%{
    for i=1:size(image,1)
        for j=1:size(image,2)
            for k=1:size(image,3)
                hists(image(i,j,k)+1,i,j,k) = hists(image(i,j,k)+1,i,j,k) + 1;
            end
        end
    end
%}
%{
array-storage: colum-major
val = img(row,col,color);
coords(row + rows*col + color*rows*cols) = val + row*256 + col*256*rows+color*256*rows*cols;
%}
    rows = uint32(size(image,1));
    cols = uint32(size(image,2));
    colors = uint32(size(image,3));
    % don't ask me why it exchanges rows and cols
    [x y z] = meshgrid(rows*256*(0:cols-1), 256*(0:rows-1), cols*rows*256*(0:colors-1));
    coords(:,:,:) = uint32(image(:,:,:)) + x + y + z;
    coords = reshape(coords, [numel(coords) 1]);
    hists(coords) = hists(coords) + 1;
end