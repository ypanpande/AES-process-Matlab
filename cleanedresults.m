% function cleanedresults()

clear; clc; close all;
% set parameters
colres = 4; % the column number of rms in the dataset
maxres = 0.05; % the threshold of rms 

% choose the file for analysing
[name,curvePath] = uigetfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'}, ...
    'Pick a file');

if ~isempty(name) & ~isa(name,'double')% only if choose one or more files
    filename = cellstr(name);    
end


[data, txt, raw] = xlsread(fullfile(curvePath,filename{1}));
[row_data, col_data] = size(data);


% delete the rows with empty cells and cell value larger than threshold
new_raw(1,:) = raw(1,:);
for i = 1: row_data
    if ~isempty(data(i,colres)) 
        if data(i,colres) <= maxres
            new_raw(i+1,:) = raw(i+1,:);
        end
    end
end

output = new_raw(~all(cellfun('isempty',new_raw),2),:);
% output = new_raw(~cellfun('isempty', new_raw'));
% save the data in the certain files
        [resultfile,saveresultpath] = uiputfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'},'Save file of cleaned result', 'cleaned result.xls');
        ffresult = fullfile(saveresultpath, resultfile);
        xlswrite(ffresult,output)

msgbox('done!')

%end