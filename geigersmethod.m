function geigersmethod()
%UNTITLED3 Summary of this function goes here
%   Detailed explanation goes here
clear; clc; close all;

format long



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
for eventnum = 1:row_data
    % observed arrive time
    dobs = data(eventnum,:)';
    % % inital guess 
    [t_ini,index] = min(dobs);
    mest = [sx(index)+randi(100),sy(index)+randi(100),t_ini-0.05];
   
    %div(1)=100;
    %Formulating the data kernel matrix and estimating the predicted models
    for iter=1:100 %for 10 iterations (termination criteria)
        
        % formulating data kernel
        G = spalloc(N,M,N*M); %N- total num of data,2*Ne*Ns; M is total num of model
        %parameters, 4*Ne
        dpre = zeros(N,1); %allocating space for predicted data matrix
        for i = 1:N % loop over stations
            
            dx = mest(1)-sx(i); % x- component of displacement obtained using the initial guess
            dy = mest(2)-sy(i); % y- component of displacement
            
            r = sqrt( dx^2 + dy^2 ); % source-receiver distance for each iteration
            
            weightv = abs(floor([dx, dy]/10)); % calculate the velocity
            vel = sum(v0.*weightv)/sum(weightv);
            
            dpre(i)=r/vel+mest(3); %predicted signal arrival time
            
            %data kernel matrix
            G(i,1) = dx/(r*vel); % first column of data kernel matrix
            G(i,2) = dy/(r*vel); % second column of data kernel matrix
            G(i,3) = 1; % third column of data kernel matrix
            
            
        end
        
        % solve with dampled least squares
        dd = dobs-dpre;
        dm = (G'*G)\(G'*dd);
        %dm=bicg(@dlsfun,G'*dd,1e-2); %solving using the biconjugate method
        %solving the damped least square equation G'dd = [ G'G + epsilon* I] dm
        % We use biconjugate method to reduce the computational cost (see for the dlsfun at the bottom)
        mest = mest+dm; %updated model parameter
        
        res = sqrt((dd'*dd)/(N-M));
%         div(iter+1) = res;
        
        if res <= epsilon
            break
        end
        
%          if div(iter) < res
%              mest = mest - dm;
%              res = div(iter);
%              break
%          end
        
    end

    aver_dd = sqrt((N-M)*res^2/N);
    addToRow = [{txt{eventnum+1}},{mest(1)},{mest(2)},{mest(3)},{res},{aver_dd},{t_ini},{index-1}];
    eventMatrix_file = [eventMatrix_file;addToRow];
end
    eventMatrix = [eventMatrix;eventMatrix_file];
end
result_matrix = [header;eventMatrix];

%% save the result
% save the data in the certain files
        [resultfile,saveresultpath] = uiputfile( ...
    {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
    '*.*',  'All Files (*.*)'},'Save file of geigersmethod result', 'geigersmethod result.xls');
        ffresult = fullfile(saveresultpath, resultfile);
        xlswrite(ffresult,result_matrix)
        
msgbox('done!')

end

