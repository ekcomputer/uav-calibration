function [panel, panel_check] = select_panels(RGN, panel_colors, tolerance)
    % Modified from calibrate_cam.m: Function for selecting pixels in an image
    % (corresponding to calibration panels).
    % Inputs:
    %   RGN_stretch     Image with cal panels  
    %   panel_colors    Cell array listing panel colors
    %   tolerance       Tolerance value for flood fill (good value - 0.008)  
    % 
    % Outputs:
    %   panel           struct of panels in order of colors in variable panel_colors
    %   panel_check     label image of pixels used for each panel
    % Caution: relies on floodfill algorithm, so make sure panels are
    % correctly delineated...
    
    %% Dynamic variables
    figure;
    h=imshow(RGN); % Note: might need to apply image stretch to tiffs...
    mp=numel(RGN(:,:,1)); % size in megapixels
    R=RGN(:,:,1);
    G=RGN(:,:,2);
    N=RGN(:,:,3);
    
    %% Begin
    zoom on
    disp('Zoom in to calibration panels, then press any key.'); pause
    zoom off
    for i=1:length(panel_colors)
    %         p(i).poly=impoly(gca);
    %         panel(i).mask=p(i).poly.createMask;
        fprintf('Select %s calibration panel.\n', panel_colors{i})
        panel(i).seed=impoint(gca);
        panel(i).mask=floodFillFromPt(RGN, panel(i).seed.getPosition, tolerance);
        panel(i).vals_R=R(panel(i).mask);
        panel(i).vals_G=G(panel(i).mask);
        panel(i).vals_N=N(panel(i).mask);
        panel(i).meanValueR=mean(panel(i).vals_R);
        panel(i).meanValueG=mean(panel(i).vals_G);
        panel(i).meanValueN=mean(panel(i).vals_N);
        fprintf('Panel %d mask created.\n', i)
    end
    fprintf('\tFinished selecting panels.\n')
    panel_check=panel(1).mask+2*panel(2).mask+3*panel(3).mask+4*panel(4).mask+5*panel(5).mask+6;
    figure;imagesc(panel_check)
    disp('Are the panels selected properly?')
    drawnow