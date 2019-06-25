
clear ; clc;
%% data preparation and picking for onset time

% choose the file for analysing
[name,curvePath] = uigetfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file for onset time picking', ...
    'MultiSelect', 'on');

if ~isempty(name) & ~isa(name,'double')% only if choose one or more files
    filename = cellstr(name);
    
end


% get the data from the files
filenumber = length(filename);

AICbatch_matrix = {'file name', 'CH0 (ms)','CH1 (ms)','CH2 (ms)','CH3 (ms)','CH4 (ms)','CH5 (ms)'};
% DeltaTbatch_matrix = {'file name', 'CH0-CH1 (ms)','CH1-CH1 (ms)','CH2-CH1 (ms)','CH3-CH1 (ms)','CH4-CH1 (ms)','CH5-CH1 (ms)'};
% NewDeltaTbatch_matrix = {'file name', 'CH0-CH1 (ms)','CH1-CH1 (ms)','CH2-CH1 (ms)','CH3-CH1 (ms)','CH4-CH1 (ms)','CH5-CH1 (ms)'};
% locbatch_matrix ={'file name', 'x (mm)','y (mm)'};


for fileloop = 1: filenumber
    
    [data, txt, raw] = xlsread(fullfile(curvePath,filename{fileloop}));
    [row_data, col_data] = size(data);
    
    minVar = 1e3; % set the minimum value of the variance of the signal
    V = find(var(data) <= minVar);
    %peakValue = 32768;
    if isempty(V) %length(V) <=2 % the number of noise data should less than 1
        
        for col_loop = 1: col_data
            DCH{col_loop} = data(:,col_loop); %one column data
            
            loc = AicPicker(DCH{col_loop}, 0); % AIC picking for no denoising the data
% % %             switch pickMethod  % choose the method for picking the onset time 
% % %                 case 'AIC0'
% % %                     loc = AicPicker(DCH{col_loop}, 0); % AIC picking for no denoising the data
% % %                 case 'AIC1'
% % %                     loc = AicPicker(DCH{col_loop}, 1); % AIC picking for denoising the data with cwt and dwt
% % %                 case 'CWT'
% % %                     loc = cwttest(DCH{col_loop}, 'morse'); % picking with the method CWT
% % %             end
            Temp_addrowTem{col_loop} = loc;
        end
        
        % get the indexs of time threshold
        time_threshold_index = find(cell2mat(Temp_addrowTem) <= 3 | cell2mat(Temp_addrowTem)  >= 6);
        if isempty(time_threshold_index)
            addrowTem = Temp_addrowTem;
            
            
            
            
            %timeCH1 = addrowTem{2}; % time of channel 1
            for col_loop_dt = 1: col_data
                deltaT = addrowTem{col_loop_dt} - addrowTem{2};
                delta{col_loop_dt} = deltaT;
                %delta_title{col_loop_dt} = ['CH' ,num2str(col_loop_dt-1), '-', 'CH1'];
            end
            
            
            
            
            % get the indexs of deltaT threshold
            threshold_index = find(cell2mat(delta) <= -1.2 | cell2mat(delta)  >= 1.2);
            if isempty(threshold_index) % deltaT of channels should in the range of -1.2 < dt < 1.2
                %save the picking time of signal
                addToRow_batch = [{filename{fileloop}},addrowTem];
                AICbatch_matrix = [AICbatch_matrix;addToRow_batch]; %for data of onset time saving
            else
                
                if ~exist(fullfile(curvePath,'deltatimeErrorFolder'),'dir')
                mkdir(fullfile(curvePath), 'deltatimeErrorFolder');
                end
                movefile(fullfile(curvePath,filename{fileloop}), fullfile(curvePath,'deltatimeErrorFolder'));
            end
        else
            if ~exist(fullfile(curvePath,'timeErrorFolder'),'dir')
             mkdir(fullfile(curvePath), 'timeErrorFolder');
            end
            movefile(fullfile(curvePath,filename{fileloop}), fullfile(curvePath,'timeErrorFolder'));
        end
    else
        if ~exist(fullfile(curvePath,'noiseFolder'),'dir')
         mkdir(fullfile(curvePath), 'noiseFolder'); 
        end
        movefile(fullfile(curvePath,filename{fileloop}), fullfile(curvePath,'noiseFolder'));
    end
    
end

% save the data in the certain files
[timefile,savetimepath] = uiputfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'},'Save file of picking time', 'pick time.xls');
ffTime = fullfile(savetimepath, timefile);
xlswrite(ffTime,AICbatch_matrix)

msgbox('done!')

function [loc,ind,k0,aicP1] = AicPicker(data_orignal,isDenoised)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%% data preprocess
data0 = data_orignal - mean(data_orignal); % substract the offset

switch isDenoised
    case  0
        data1 = data0;
    case  1
        data1 = wdenoise(data0,10, ...
            'Wavelet', 'bior4.4', ...
            'DenoisingMethod', 'SURE', ...
            'ThresholdRule', 'Hard', ...
            'NoiseEstimate', 'LevelDependent');
end
data=data1;
ind_peak = find(abs(data) == max(abs(data)));



k0=ind_peak;
%% calculating onset time using the AIC Algorithm with function equation in the window[1,k0]

% AIC(k) = k*log(var(x[1,k])) + (n-k-1)*log(var(x[k+1,n])) where k
%          goes from 1 to length(x)

x=data(1:k0);

if ~isempty(x)
    num = length(x);
    for k=1:num-1
        %calculate variance in first part
        xLogVar1 = var(x(1:k));
        if xLogVar1 <= 0
            xLogVar1 = 0;
        else
            xLogVar1=log(xLogVar1);
        end
        %compute variance in second part
        xLogVar2 = var(x(k+1:num));
        if xLogVar2 <= 0
            xLogVar2 = 0;
        else
            xLogVar2=log(xLogVar2);
        end
        aicP1(k) = k*(xLogVar1) + (num-k-1)*(xLogVar2);
    end
else
    aicP1 = 0;
end
% % find the position of the mininum
if aicP1 ~= 0
    ind = find(aicP1 == min(aicP1)) + 1;  % pick is one more than divide point
else
    ind = 0;
end



dt=0.004; % time step (unit: ms)

if ind~=0
    loc=(ind-1)*dt;
else
    loc=0;

end
end



