%% Read, take only the green dimension and then perform noise-removal via Gaussian filtering.
% Assume the image to be read is stored in the same directory as this
% script with the name 'image.bmp'
% Stuff we need to count is always coloured green.
% Literally any other colour is useless as we only need count nuclei
imgdata = imread('image.bmp');
% should be fine to extract rgb straight out of the image
red = imgdata(:,:,1);
green = imgdata(:,:,2);
blue = imgdata(:,:,3);

% clean noise by using matlab standard gaussian filtering
green = imgaussfilt(green);
% normalise colours by removing green component equal to the average of the
% red and blue component at each pixel in the image.
green = (green - (red + blue)/2.0);
%% Used implementation of Rosin Thresholding: https://uk.mathworks.com/matlabcentral/fileexchange/45443-rosin-thresholding
% Implementation not provided by myself as the inner implementation details
% are out of scope of this assignment.
hist_img = imhist(green);
plot(hist_img);
hold on;
[peak_max, pos_peak] = max(hist_img);
p1 = [pos_peak, peak_max];

% find last non-empty bin
ind_nonZero = find(hist_img>0);
last_zeroBin = ind_nonZero(end);
%plot([ind_nonZero(end), pos_peak], [last_zeroBin, peak_max]);
figure;
p2 = [last_zeroBin, hist_img(last_zeroBin)];
best_idx = -1;
max_dist = -1;
for x0 = pos_peak:last_zeroBin
    y0 = hist_img(x0);
    a = p1 - p2;
    b = [x0,y0] - p2;
    cross_ab = a(1)*b(2)-b(1)*a(2);
    d = norm(cross_ab)/norm(a);
    if(d>max_dist)
        best_idx = x0;
        max_dist = d;
    end
end
mean_threshold = best_idx;
%% Apply generated threshold to create the final binary image.
green(green < mean_threshold) = 0;
green(green > mean_threshold) = 255;
%% Count number of connected-components via the library function bwconncomp(image)
se = strel('disk', 3);
green = imopen(green, se);
imshow(green);
cc = bwconncomp(green);
fprintf('Num components = %d', cc.NumObjects);
