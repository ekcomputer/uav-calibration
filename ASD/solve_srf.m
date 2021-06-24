% Run after first cells of EVA_calibration.m (up to '%% resample SRF')

% clear;
addpath .. % adds select_panels function to path

%% I/O
panel_photo = 'F:\PAD2019\UAV\Cal_Panels_0819\Mapir\Photo\2019_0819_184742_010.JPG' % jpg for now

%% Select colors
panel_colors= {'pink', 'grey', 'brown', 'orange', 'blue-pale'} % just these five for now...
RGN_stretch=imread(panel_photo);
% h=imshow(RGN_stretch);

%% select panel pixels
[panel, panel_check] = select_panels(RGN_stretch, panel_colors, 0.008);

%% Make matrix of panels in RGN (matrix C)
% Make sure RGN is actually correct order of camera bands, so I don't get
% confused...

C = [[panel.meanValueR]', [panel.meanValueG]', [panel.meanValueN]']

%% Make matrix of spectra (matrix B)
A = spect(:, [10, 12, 3, 13, 8])' % and so on...

%% Solve inverse matrix problem (many unique solutions, I think)
% Try also mldivide, or linsolve for more control over parameters
B = A \ C; 