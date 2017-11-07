function res=rangepeak2d(I,rsize)
% I: image (gray scale or bw)
% rsize: size of range to find local maximum (usually odd number)
% rsize = 5;
im_size = size(I);
% make sure image is two dimension
if ndims(I)==3
    I = rgb2gray(I);
end
% Make the rsize to be odd number
if mod(rsize,2)==0
    rsize = rsize+1;
end

offset = floor(rsize/2);
% Put the image at the center of padding image
I_padding = zeros(im_size(1)+2*offset, im_size(2)+2*offset);
I_padding(offset+1:offset+im_size(1), offset+1:offset+im_size(2) ) = I;

% Sliding Window
parts = im2col(I_padding, [rsize, rsize], 'sliding'); % rsize^2 x im_size
[~,idx] = max(parts);
% fmax = zeros(rsize);
% fmax(offset+1,offset+1)=1;
% fmax = fmax(:);
% parts_filter = parts .* repmat(fmax,[1,im_size(1)*im_size(2)]);
fmax = offset*rsize + offset + 1;
res = reshape(idx==fmax,im_size(1),im_size(2));
% figure; imshow(res,[]);

