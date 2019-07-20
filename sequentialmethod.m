%function sequentialmethod()
%UNTITLED4 Summary of this function goes here
%   Detailed explanation goes here
clear; close all;
% determining the predicted arrival time using the sequential searching algorithms
format long
%% set the parameters
% sensor coordinates (xi, yi)
% sx=[5, 0, 505, 550];
% sy=[1555,0, 1482.5,82.5];
sx=[5, 0, 505, 550, -1650, -1650];
sy=[1555,0, 1482.5,82.5,1552.5, -2.5];

%velocity component
v0 = [4000, 2500];


N = length(sx); % number of sensor
M = 3; % number of model parameter [dx,dy,dt]

% save the result
eventMatrix = {}; 
header = [{'event name'},{'x0 (mm)'},{'y0 (mm)'},{'t0 (ms)'},{'RMS res time'},{'average res time (ms)'},{'tmin (ms)'},{'CH'}];

%% determining the predicted arrival time using the sequential searching algorithms


% choose the file for analysing
[name,curvePath] = uigetfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file', ...
    'MultiSelect', 'on');

if ~isempty(name) & ~isa(name,'double')% only if choose one or more files
    filename = cellstr(name);    
end

filenumber = length(filename);

for filesloop = 1:filenumber
  
[data, txt, raw] = xlsread(fullfile(curvePath,filename{filesloop}));
[row_data, col_data] = size(data);

eventMatrix_file = {}; 

% %       areatop = [-2000,2000]; areabottom = [1200,-400];
    switch index
        case 1
           areatop = [-840,2000]; areabottom = [260,760]; 
        case 2
            areatop = [-840,780]; areabottom =  [280,-400];
        case 3
            areatop = [240,2000]; areabottom = [1200,760];
        case 4
            areatop = [260,780]; areabottom = [1200,-400];
        case 5
            areatop = [-2000,2000]; areabottom = [-820,760];
        case 6
            areatop = [-2000,780]; areabottom = [-820,-400];
    end

    hornum = round((areabottom(1) - areatop(1))/block);
    vernum = round((areatop(2) - areabottom(2))/block);
    %rmsdd = spalloc(hornum,vernum,hornum*vernum);
    
    for i=1:vernum 
    for j = 1:hornum
        x = areatop(1)+ block/2 + (j-1)*block;
        y = areabottom(2)+ block/2 + (i-1)*block;
        a = [x,y];
        for sensornum = 1:N % loop over sensors
            dx = a(1)-sx(sensornum);
            dy = a(2)-sy(sensornum);
            % distance to sensors
            distance(sensornum) = sqrt(dx^2 + dy^2);
            % velocity to sensors % calculate the velocity
            weightv = abs(floor([dx, dy]/10));
            vel(sensornum) = sum(v0.*weightv)/sum(weightv);
            % time to sensors
            dcal(sensornum) = distance(sensornum)/vel(sensornum);           
        end
        
        % calculate the time difference between calculation and observation using r_i = (t_oi - sum(t_oi)/n) - (t_cali - sum(t_cali)/n)
        for sensornum2 = 1:N % loop over sensors
        
        dd(sensornum2) = (dobs(sensornum2) - sum(dobs)/N) - (dcal(sensornum2) - sum(dcal)/N);
        end
        
        % calculate the event rms 

        rmsdd(j,i) = sqrt((dd*dd')/(N-M));
        t0(j,i) = sum(dobs)/N - sum(dcal)/N;
    end
    end
    % find the index and value of the mininum rms of delta time
    vmin = min(rmsdd(:));
    [row_min,col_min] = find(rmsdd == vmin);
    % calculate the position
    xmin = areatop(1) + block/2 + (row_min(1)-1)*block;
    ymin = areabottom(2) + block/2 + (col_min(1)-1)*block;
    t0min = t0(row_min(1),col_min(1));
    aver_dd = sqrt((N-M)*vmin^2/N);
    addToRow = [{txt{eventnum+1}},{xmin},{ymin},{t0min},{vmin},{aver_dd},{t_ini},{index-1}];
    eventMatrix_file = [eventMatrix_file;addToRow];
end
    eventMatrix = [eventMatrix;eventMatrix_file];
end
result_matrix = [header;eventMatrix];
%% save the result
% save the data in the certain files
        [resultfile,saveresultpath] = uiputfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'},'Save file of sequential method result', 'sequential method result.xls');
        ffresult = fullfile(saveresultpath, resultfile);
        xlswrite(ffresult,result_matrix)

msgbox('done!')

%end
