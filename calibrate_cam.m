% script to calibrate NIR camera to reflectance
% TODO: replace impoly with impoint and floodfill
clear; close all
%% user params
selectpanels=1; % load panels from file

%% load image
RGN=imread('C:\Users\lsmith.DESKTOP-JJ8STSU\Desktop\ETHAN\mapir_cal_test\2019_0811_183448_349.JPG');
h=imshow(RGN);
mp=numel(RGN(:,:,1)); % size in megapixels
R=RGN(:,:,1);
G=RGN(:,:,2);
N=RGN(:,:,3);
%% select cal panels
% panel order: 1-pink, 2-grey, 3-black, 4-yellow, 5-white, 6-red
if selectpanels==1
    pause(1)
    for i=1:6
%         p(i).poly=impoly(gca);
%         panel(i).mask=p(i).poly.createMask;
        panel(i).seed=impoint(gca);
        panel(i).mask=floodFillFromPt(RGN, panel(i).seed.getPosition, 0.03);
        panel(i).vals_R=R(panel(i).mask);
        panel(i).vals_G=G(panel(i).mask);
        panel(i).vals_N=N(panel(i).mask);
        panel(i).meanValueR=mean(panel(i).vals_R);
        panel(i).meanValueG=mean(panel(i).vals_G);
        panel(i).meanValueN=mean(panel(i).vals_N);
        fprintf('Panel %d mask created.\n', i)
    end
else load('panels.mat');
end;
fprintf('\tFinished selecting panels.\n')

%% plot cal panel reflectances
labels=categorical({'pink', 'grey', 'black', 'yellow', 'white', 'red'});
figure;
subplot(311); h1=bar([panel.meanValueR], 'r'); title('Red band'); set(gca, 'XTickLabel', {})
subplot(312); h2=bar([panel.meanValueG], 'g'); title('Green band'); set(gca, 'XTickLabel', {})
subplot(313); h3=bar(labels, [panel.meanValueN], 'm'); title('NIR band')

%% load actual reflectance values per panel color



   


%% select water via flood fill

% Convert NIR image into L*a*b* color space.
X = rgb2lab(RGN);

% Create empty mask.
BW = false(size(X,1),size(X,2));

% Flood fill
row = 2096;
column = 2768;
tolerance = 5.000000e-02;
normX = sum((X - X(row,column,:)).^2,3);
normX = mat2gray(normX);
addedRegion = grayconnected(normX, row, column, tolerance);
BW = BW | addedRegion;