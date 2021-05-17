% from bash output:
% ekyzivat@IBESSMITHLAB3:/mnt/f/PAD2019/UAV$ find . -type f | grep .RAW | awk '{print substr($0,length($0)-23,16)}' > ../Turbidity/raw-photo-list-times.txt
% script is messy- designed to run in chunks, not all at once


clear
pth_dates='F:\PAD2019\Turbidity\photo_lists\raw-photo-list-times.txt';
    % uncomment for jpg
% pth_dates='F:\PAD2019\Turbidity\photo_lists\jpg-photo-list.txt';

pth_paths='F:\PAD2019\Turbidity\photo_lists\raw-photo-list.txt';
%% 2

dat_dates=importdata(pth_dates);
    % only do below for RAW
    
%%
f=@(cell) datetime(cell, 'InputFormat', 'yyyy_MMdd_HHmmss', 'TimeZone', '-06:00');
dates_RAW=cellfun(f, dat_dates);
pths_RAW=importdata(pth_paths);

%% put RAW into structure
for i=1:length(dates_RAW)
   raw(i).path_lin=pths_RAW{i};
   str_win=replace(pths_RAW{i}, './', 'F:\PAD2019\UAV\');
   str_win=replace(str_win, '\', '/');
   raw(i).path_win=str_win;
   raw(i).date=dates_RAW(i);
end

%%
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%% JPG - run after step 2

for i = 1:length(dat_dates)
    str_win=replace(dat_dates{i}, './', 'F:\PAD2019\UAV\');
    str_win=replace(str_win, '\', '/');
    jpg(i).path_lin=dat_dates{i};
    jpg(i).path_win=str_win;
    jpg(i).imfinfo=imfinfo(str_win);
    try
        jpg(i).date=datetime(jpg(i).imfinfo.DateTime, 'InputFormat', 'yyyy:MM:dd HH:mm:ss', 'TimeZone', '-06:00');
    catch %not enough EXIF data
        jpg(i).date=datetime(jpg(i).path_lin(end-23:end-8), 'InputFormat', 'yyyy_MMdd_HHmmss', 'TimeZone', '-06:00');
    end
end

%% save
if photoType=='raw'
    mat_out='F:\PAD2019\Turbidity\photo_lists\photos_RAW.mat';
    save(mat_out, 'raw');
elseif photoType=='jpg'
    mat_out='F:\PAD2019\Turbidity\photo_lists\photos_JPG.mat';
    save(mat_out, 'jpg');
end

%% trash

%
% fid=fopen(pth);
% dat=textscan(fid, '%s', 'Delimiter', '_');

% f=@(cell) textscan(cell, '%s', 'Delimiter', '_');

% save(mat_out, 'dates_RAW', 'pths_RAW');
