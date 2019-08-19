%% data import
clear; close all

%% user params
inPAD=1;
savecnv=1; % save output convolved struct
%% other params

if inPAD
    labs_pth='C:\Users\lsmith.DESKTOP-JJ8STSU\Google Drive\Research\Files\PAD\ASD\Labels.txt';
    trans_pth='C:\Users\lsmith.DESKTOP-JJ8STSU\Google Drive\Research\Files\PAD\ASD\RGN_transmittance.xlsx';
    asd_pth='C:\Users\lsmith.DESKTOP-JJ8STSU\Google Drive\Research\Files\PAD\ASD\EVA_Foam_All_Processed.xlsx';
    srf_pth='C:\Users\lsmith.DESKTOP-JJ8STSU\Google Drive\Research\Files\PAD\ASD\SRF.mat';
    cnv_pth='C:\Users\lsmith.DESKTOP-JJ8STSU\Google Drive\Research\Files\PAD\ASD\convolved.mat';
else
    labs_pth='D:\GoogleDrive\Research\Files\PAD\ASD\Labels.txt';
    trans_pth='D:\GoogleDrive\Research\Files\PAD\ASD\RGN_transmittance.xlsx';
    asd_pth='D:\GoogleDrive\Research\Files\PAD\ASD\EVA_Foam_All_Processed.xlsx';
    srf_pth='D:\GoogleDrive\Research\Files\PAD\ASD\SRF.mat';
    cnv_pth='D:\GoogleDrive\Research\Files\PAD\ASD\convolved.mat';
end

%% data import
asd=xlsread(asd_pth,1);
SRF=load(srf_pth);
%% open files
wl=asd(:,1);
fid=fopen(labs_pth, 'r');
labs=textscan(fid, '%s'); labs=labs{:};
fclose(fid);
xy_lim=[500, 900, 0, 1];
%% average spectra
for i=1:15
    spect(:,i)=mean(asd(:,3*i-1:3*i+1), 2);
    subplot(3,5,i)
    plot(wl, spect(:,i), '.'); title(labs{i})
%     set(gca, 'YTick', [0:0.1:1])
    axis(xy_lim)
end

%% load transmittance

rgn_t_raw=xlsread(trans_pth,1);
rgn_t=spline(rgn_t_raw(:,1),rgn_t_raw(:,2)/100, wl);
figure; plot(wl, rgn_t, '-'); axis(xy_lim); title('RGN filter transmitance')

%% resamplpe SRF
    % SRF is in strange format of cell wi struct
colors={'b','g','r'};
figure; hold on
for i=1:3
    SRF.SRF_rs{i}=interp1(SRF.SRF{i}(:,1),SRF.SRF{i}(:,2), wl);
%     figure(20); hold on; plot(SRF.SRF{i}(:,1),SRF.SRF{i}(:,2), colors{i}); 
    plot(wl,SRF.SRF_rs{i}, colors{i}); %% here use srf_t

end
hold off
title('Sensor response functions'); 
legend({'Blue', 'Green', 'Red'}); axis([400 700 0 1]);
%% multiply transmitance by reflectance curves
% *** need to account for camera spectral response function (SRF)
bands={'R', 'G', 'N'};
figure;
for i=1:15 % iterate over panels
    for j=1:3 % iterate over bands
        cnv=rgn_t.*spect(:,i).*SRF.SRF_rs{j}; % multiply SRF*filter*panel reflectivity
        cnv(isnan(cnv))=0; % hot fix to allow cnv to be multiplied
        convolved(i).(sprintf('spectra_%s',bands{j}))=cnv; % to have A SHORTER  vAR NAME
        convolved(i).(sprintf('mean_%s',bands{j}))=cnv(2:end)'*diff(wl)/range(wl); % average integral
        subplot(3,1,j); plot(wl, rescale(cnv));
        title(sprintf('Panel: %s\nBand: %s',labs{i}, bands{j}))
        axis(xy_lim); 
%         pause(0.1);
    end
    pause(0.5)
end

%% save convolution structure w theoretical refl valuees for each panel in R G N

if save_cnv
save(cnv_pth, 'convolved');
fprintf('Convolved struct saved to %s.\n', cnv_pth);
end
%% TODO: beyond 700 ... need better SRF
% better integration w movmean
% make helper function to save with overwrite prompt and success message w
% pathname
