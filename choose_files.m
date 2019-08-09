function choose_files
clc;clear




curvePath = ''; %file address


dt = 0.004;% time step (unit: ms)
%pphasepicker
global type;  type = 'sm';
global Tn;    Tn = 0.01;
global nbins; nbins = round(2/dt);
global xi;    xi = 0.6;

%SBP picker
global pxThreshold   ;pxThreshold = 5;
global sWindow       ;sWindow     = 1;              % Window lenght for measuring signal amps after p-pick [sec]
global nWindow       ;nWindow     = 1;              % Window lenght for measuring noise before p-pick [sec]
global wmax          ;wmax        = 1e1;
global wmin          ;wmin        = .1;
global sWtFct        ;sWtFct      = 'exp';          % 'lin' or 'exp' or '1-exp'
global nWtFct        ;nWtFct      = 'exp';          % 'lin' or 'exp' or '1-exp'
global ntap          ;ntap        = 100;            %  No. of tapered samples

 %AIC picker
%  global wset;     wset = 50;
% global fold;    fold = 5;
global isDenoised; isDenoised = 0;

%hitsearch
global pref  ; pref = 1;
global hit_width  ; hit_width = 50;
global hit_dis  ; hit_dis = 100;

%AmpFre
global Fs  ; Fs = 250000;

%CWT
global wname; wname = 'morse';

%save data
global addToRow; addToRow ={};
global addToRow_Classic; addToRow_Classic = {};
global addToRow_Freq; addToRow_Freq = {};

%pphasebatch
batchflag_pphase = false;
ppbatch_loc = {};

%SBPbatch
batchflag_SBP = false;
SBP_loc = {};

%AICbatch
batchflag_AIC = false;
AICbatch_loc = {};

%CWTbatch
batchflag_CWT = false;
CWTbatch_loc = {};


S.pb_unbatch = uicontrol('style', 'pushButton','String','unbatch','position', [5 840 130 15], 'callback', {@unbatch, S});

%button for P_phase picker
S.pb_pphase = uicontrol('style', 'pushButton','String','pphase','position', [149 860 130 30], 'callback', {@getPphase, S});
S.pb_pphase_para = uicontrol('style', 'pushButton','String','parameter','position', [170 840 90 20], 'callback', {@getPphase_pare, S});
S.pb_pphase_batch = uicontrol('style', 'pushButton','String','ba','position', [265 840 20 20], 'callback', {@getPphase_batch, S});

%button for SBPpicker
S.pb_SBP = uicontrol('style', 'pushButton','String','SBP','position', [290 860 130 30], 'callback', {@getSBP, S});
S.pb_SBP_para = uicontrol('style', 'pushButton','String','parameter','position', [310 840 90 20], 'callback', {@getSBP_pare, S});
S.pb_SBP_batch = uicontrol('style', 'pushButton','String','ba','position', [405 840 20 20], 'callback', {@getSBP_batch, S});

%button for AIC picker
S.pb_AIC = uicontrol('style', 'pushButton','String','AIC','position', [430 860 130 30], 'callback', {@getAIC, S});
S.pb_AIC_para = uicontrol('style', 'pushButton','String','parameter','position', [450 840 90 20], 'callback', {@getAIC_pare, S});
S.pb_AIC_batch = uicontrol('style', 'pushButton','String','ba','position', [545 840 20 20], 'callback', {@getAIC_batch, S});

%button for hitsearch picker
S.pb_hitsearch = uicontrol('style', 'pushButton','String','Classic','position', [570 860 130 30], 'callback', {@gethitsearch, S});
S.pb_hitsearch_para = uicontrol('style', 'pushButton','String','parameter','position', [590 840 90 20], 'callback', {@gethitsearch_pare, S});

%button for frequency field
S.pb_AmpFre = uicontrol('style', 'pushButton','String','Frequency','position', [710 860 130 30], 'callback', {@getAmpFre, S});
S.pb_AmpFre_para = uicontrol('style', 'pushButton','String','parameter','position', [730 840 90 20], 'callback', {@getAmpFre_pare, S});

%button for CWT picker
S.pb_CWT = uicontrol('style', 'pushButton','String','CWT','position', [850 860 130 30], 'callback', {@getCWT, S});
S.pb_CWT_para = uicontrol('style', 'pushButton','String','parameter','position', [870 840 90 20], 'callback', {@getCWT_pare, S});
S.pb_CWT_batch = uicontrol('style', 'pushButton','String','ba','position', [965 840 20 20], 'callback', {@getCWT_batch, S});


%button for save data of onsets
S.pb_forDataSave = uicontrol('style', 'pushButton','String','forDataSave','position', [5 90 130 30], 'callback', {@forDataSave, S});

%button for save data of Classic
S.pb_forDataSave_Classic = uicontrol('style', 'pushButton','String','ClassicDataSave','position', [5 50 130 30], 'callback', {@forClassicDataSave, S});

%button for save data of frequency
S.pb_forDataSave_Freq = uicontrol('style', 'pushButton','String','FreqDataSave','position', [5 10 130 30], 'callback', {@forFreqDataSave, S});

%obtain the filenames 'filename' in the form of cell array
    function filename = getFilePath(varargin)
        S = varargin{3};% get the whole handles
        [name,curvePath] = uigetfile( ...
            {'*.txt; *.xls; *.csv','Text file(*.txt, *.xls, *.csv)';...
            '*.*',  'All Files (*.*)'}, ...
            'Pick a file', ...
            'MultiSelect', 'on');
        
        if ~isempty(name) & ~isa(name,'double')% only if choose one or more files
            filename = cellstr(name);
            
            S.list.String = filename;%display the opened files
            set(S.list,'callback', {@listCallback, S}) %set listbox
            
        end
    end


%unbatch all the flag

    function unbatch(varargin)
        %pphasebatch
        batchflag_pphase = false;
        ppbatch_loc = {};
        
        %SBPbatch
        batchflag_SBP = false;
        SBP_loc = {};
        
        %AICbatch
        batchflag_AIC = false;
        AICbatch_loc = {};
        
        %CWTbatch
        batchflag_CWT = false;
        CWTbatch_loc = {};
        
    end


%display the fiture when click the item in the listbox
    function listCallback(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        
       
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
      
        [Data_row, Data_col]=size(Data);
        
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt(i); %responding column name
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            
            %plot
    
           

            if batchflag_pphase
                tt= subplot(2,3,i,'Parent',S.fMain);
                loc = ppbatch_loc{S.list.Value};
                plot(tt, x_axis, DCH{i},[loc{i}, loc{i}],[max(DCH{i}), min(DCH{i})]);
                title(tt,['pP_batch', DCH_colname{i}])
                legend(num2str(loc{i}));
            elseif batchflag_SBP
                tt= subplot(2,3,i,'Parent',S.fMain);
                loc = SBP_loc{S.list.Value};
                plot(tt, x_axis, DCH{i},[loc{i}, loc{i}],[max(DCH{i}), min(DCH{i})]);
                title(tt,['SBP_batch', DCH_colname{i}])
                legend(num2str(loc{i}));
            elseif batchflag_AIC
                tt= subplot(2,3,i,'Parent',S.fMain);
                loc = AICbatch_loc{S.list.Value};
                plot(tt, x_axis, DCH{i},[loc{i}, loc{i}],[max(DCH{i}), min(DCH{i})]);
                title(tt,['AIC_batch', DCH_colname{i}])
                legend(num2str(loc{i}));
            elseif batchflag_CWT
                tt= subplot(2,3,i,'Parent',S.fMain);
                loc = CWTbatch_loc{S.list.Value};
                plot(tt, x_axis, DCH{i},[loc{i}, loc{i}],[max(DCH{i}), min(DCH{i})]);
                title(tt,['CWT_batch', DCH_colname{i}])
                legend(num2str(loc{i}));
            else
                tt= subplot(2,3,i,'Parent',S.fMain);
                plot(tt,x_axis, DCH{i})
                title(DCH_colname{i})
            end
            
            
        end
        
        
        
        
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate pPhase
    function getPphase(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt(i); %responding column name
            saveChannelTitle{i} = txt(i);
            
            loc = PphasePicker(DCH{i}, dt,  type, 'N', Tn, xi, nbins, 'to_peak');
            addrowTem{i} = loc;
            
            % plot result
            %   set(0,'CurrentFigure',S.fMain);
            
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            plot(tt, x_axis, DCH{i},[loc, loc],y1);
            title(tt,['p-phase', DCH_colname{i}])
            
            
        end
        %add to save date table
        addToRow = [{fname},addrowTem];
    end

%parameters of Pphase
%new figre for paraments (type, Tn, xi, nbins) configuration
    function getPphase_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForPphasePicker;
    end

%batch pPhase
    function getPphase_batch(varargin)
        batchflag_pphase = true;
        S = varargin{3};%get the whole handles
        pphasebatch_matrix = {' ', 'CH0 (ms)','CH1 (ms)','CH2 (ms)','CH3 (ms)','CH4 (ms)','CH5 (ms)'};
        h = msgbox('Please wait for batch of pPhase...'); % show the dialog box of waiting for batch calculation
        for listItem = 1: length(S.list.String)
            fname = S.list.String{listItem}; %get the highlight item in the listbox
            [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
            [Data_row, Data_col]=size(Data);
            
            addrowTem = {};% store the 6 x-axis data
            for i = 1: Data_col
                DCH{i}=Data(:,i); %one column data
                DCH_colname{i} = txt(i); %responding column name
                saveChannelTitle{i} = txt(i);
                
                loc = PphasePicker(DCH{i}, dt,  type, 'N', Tn, xi, nbins, 'to_peak');
                addrowTem{i} = loc;
                
            end
            %add to save date table
            addToRow_batch = [{fname},addrowTem];
            pphasebatch_matrix = [pphasebatch_matrix;addToRow_batch]; %for data saving
            
            ppbatch_loc{end + 1} =  addrowTem;%for drawing
            
        end
        delete(h);
        [file,path] = uiputfile('file.xls','Save table of Pphase batch');
        ff = fullfile(path, file);
        xlswrite(ff,pphasebatch_matrix)
        msgbox('done!')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate SBP
    function getSBP(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt(i); %responding column name
            saveChannelTitle{i} = txt(i);
            
            % loc = PphasePicker(DCH{i}, dt,  type, 'N', Tn, xi, nbins, 'to_peak');
            % Call picker
            
            ppxIdx = SBPx(DCH{i},dt,0,pxThreshold,sWindow,nWindow,wmax,wmin, ...
                sWtFct,nWtFct,ntap,false,false);
            %get x-axis
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            
            %no value
            if isempty(ppxIdx)
                ppxIdx = 1;
            end
            loc = x_axis(ppxIdx);
            
            addrowTem{i} = loc;
            
            % plot result
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            
            plot(tt, x_axis, DCH{i},[loc, loc],y1);
            title(tt,['SBP-', DCH_colname{i}])
            
            
        end
        %add to save date table
        addToRow = [{fname},addrowTem];
    end

%parameters of SBP
%new figre for paraments (type, Tn, xi, nbins) configuration
    function getSBP_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForSBP;
    end

%batch of SBP
    function getSBP_batch(varargin)
        batchflag_SBP = true;
        S = varargin{3};%get the whole handles
        SBPbatch_matrix = {' ', 'CH0 (ms)','CH1 (ms)','CH2 (ms)','CH3 (ms)','CH4 (ms)','CH5 (ms)'};
        h = msgbox('Please wait for batch of SBP...'); % show the dialog box of waiting for batch calculation
        for listItem = 1: length(S.list.String)
            fname = S.list.String{listItem}; %get the highlight item in the listbox
            [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
            [Data_row, Data_col]=size(Data);
            
            addrowTem = {};% store the 6 x-axis data
            for i = 1: Data_col
                DCH{i}=Data(:,i); %one column data
                DCH_colname{i} = txt(i); %responding column name
                saveChannelTitle{i} = txt(i);
                
                ppxIdx = SBPx(DCH{i},dt,0,pxThreshold,sWindow,nWindow,wmax,wmin, ...
                    sWtFct,nWtFct,ntap,false,false);
                %get x-axis
                x_max = 0 + (Data_row - 1)*dt;
                x_axis = 0:dt:x_max;% x-axis for drawing the picture
                %no value
                if isempty(ppxIdx)
                    ppxIdx = 1;
                end
                loc = x_axis(ppxIdx);
                
                addrowTem{i} = loc;
                
            end
            %add to save date table
            addToRow_batch = [{fname},addrowTem];
            SBPbatch_matrix = [SBPbatch_matrix;addToRow_batch]; %for data saving
            
            SBP_loc{end + 1} =  addrowTem;%for drawing
            
        end
        delete(h);
        [file,path] = uiputfile('file.xls','Save table of SBP batch');
        ff = fullfile(path, file);
        xlswrite(ff,SBPbatch_matrix)
        msgbox('done!')
    end


%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate AIC picker
    function getAIC(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt(i); %responding column name
            saveChannelTitle{i} = txt(i);
            
            loc = AicPicker(DCH{i}, isDenoised);
            addrowTem{i} = loc;
            
            % plot result
            %   set(0,'CurrentFigure',S.fMain);
            
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            plot(tt, x_axis, DCH{i},[loc, loc],y1);
            title(tt,['AIC', DCH_colname{i}])
            
            
        end
        %add to save date table
        addToRow = [{fname},addrowTem];
    end

%parameters of Pphase
%new figre for paraments (type, Tn, xi, nbins) configuration
    function getAIC_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForAICPicker2;
    end


%batch of AIC
    function getAIC_batch(varargin)
        batchflag_AIC = true;
        S = varargin{3};%get the whole handles
        AICbatch_matrix = {' ', 'CH0 (ms)','CH1 (ms)','CH2 (ms)','CH3 (ms)','CH4 (ms)','CH5 (ms)'};
        %AICbatch_matrix = {' ', 'CH0 (ms)','CH1 (ms)','CH2 (ms)'};
        h = msgbox('Please wait for batch of AIC...'); % show the dialog box of waiting for batch calculation
        for listItem = 1: length(S.list.String)
            fname = S.list.String{listItem}; %get the highlight item in the listbox
            [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
            [Data_row, Data_col]=size(Data);
            
            addrowTem = {};% store the 6 x-axis data
            for i = 1: Data_col
                DCH{i}=Data(:,i); %one column data
                DCH_colname{i} = txt(i); %responding column name
                saveChannelTitle{i} = txt(i);              
                
                loc = AicPicker(DCH{i}, isDenoised);
                addrowTem{i} = loc;
                
            end
            %add to save date table
            addToRow_batch = [{fname},addrowTem];
            AICbatch_matrix = [AICbatch_matrix;addToRow_batch]; %for data saving
            
            AICbatch_loc{end + 1} =  addrowTem;%for drawing
            
        end
        delete(h);
        [file,path] = uiputfile('file.xls','Save table of AIC batch');
        ff = fullfile(path, file);
        xlswrite(ff,AICbatch_matrix)
        msgbox('done!')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%


%calculate hitsearch picker
    function gethitsearch(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        
        addToRow_Classic_row = {}; % store
        addToRow_Classic_matrix = {};
        
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt{i}; %responding column name
            saveChannelTitle{i} = txt(i);
            
            %[AmpMax,Duration,RiseTime,Energy,OnsetT,th,hit_loc,d1,up] = hitsearch(data,pref,hit_width,hit_dis )
            
            [AmpMax,Duration1,RiseTime1,Energy,OnsetT1,th,hit_loc1,d1,up] = hitsearch(DCH{i},pref,hit_width,hit_dis );
            Duration = Duration1*dt; RiseTime = RiseTime1*dt;  OnsetT = OnsetT1*dt;  hit_loc = hit_loc1*dt;
            
            addToRow_Classic_row = [{fname},{DCH_colname{i}},{AmpMax},{Duration},{RiseTime},{Energy},{OnsetT},{th}];
            addToRow_Classic_matrix = [addToRow_Classic_matrix; addToRow_Classic_row];
            %  loc = AicPicker(DCH{i}, wset, fold);
            %
            
            %             addrowTem{i} = loc;
            %
            % plot result
            %   set(0,'CurrentFigure',S.fMain);
            
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            plot(tt, x_axis, d1, x_axis, up);
            line(tt,[x_axis(1), x_axis(end)],[th, th], 'Color','r') % threshold line
            line(tt,[hit_loc(1),hit_loc(1)],y1, 'Color','r') % first hit start point
            line(tt,[hit_loc(2),hit_loc(2)],y1, 'Color','r') % first hit end point
            %              line(tt,[hit_loc(2),hit_loc(2)],[min(d1(:)), max(d1(:))], 'Color','r') % first hit end point
            title(tt,['hitsearch', DCH_colname{i}])
            
            
        end
        addToRow_Classic = addToRow_Classic_matrix;
        
        %add to save date table
        %addToRow = [{fname},addrowTem];
    end

%parameters of hitsearch
%new figre for paraments (type, Tn, xi, nbins) configuration
    function gethitsearch_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForhitsearch;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate frequency
    function getAmpFre(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        
        addToRow_Freq_row = {}; % store
        addToRow_Freq_matrix = {};
        
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt{i}; %responding column name
            saveChannelTitle{i} = txt(i);
            
            
            
            % [fre,Amp ,fre_peak,fre_centroid,fre_wpeak] = AmpFre(data,Fs)
            
            
            
            [fre_peak,fre_centroid,fre_wpeak,fre,Amp] = AmpFre(DCH{i},Fs);
            
            addToRow_Freq_row = [{fname},{DCH_colname{i}},{fre_peak},{fre_centroid},{fre_wpeak}];
            addToRow_Freq_matrix = [addToRow_Freq_matrix; addToRow_Freq_row];
            %  loc = AicPicker(DCH{i}, wset, fold);
            %
            
            %             addrowTem{i} = loc;
            %
            % plot result
            %   set(0,'CurrentFigure',S.fMain);
            %
            %             x_max = 0 + (Data_row - 1)*dt;
            %             x_axis = 0:dt:x_max;% x-axis for drawing the picture
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            plot(tt, fre, Amp);
            %             line(tt,[fre_peak,fre_peak],y1, 'Color','r' ) % fre_peak
            %             line(tt,[fre_centroid,fre_centroid],y1, 'Color','r') % fre_centroid
            %             line(tt,[fre_wpeak,fre_wpeak],y1, 'Color','r') % fre_wpeak
            title(tt,['AmpFre', DCH_colname{i}])
            
            
        end
        addToRow_Freq = addToRow_Freq_matrix;
        
        %add to save date table
        %addToRow = [{fname},addrowTem];
    end

%parameters of hitsearch
%new figre for paraments (type, Tn, xi, nbins) configuration
    function getAmpFre_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForAmpFre;
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%calculate CWT picker
    function getCWT(varargin)
        S = varargin{3};%get the whole handles
        fname = S.list.String{S.list.Value}; %get the highlight item in the listbox
        [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
        [Data_row, Data_col]=size(Data);
        
        addrowTem = {};% store the 6 x-axis data
        for i = 1: Data_col
            DCH{i}=Data(:,i); %one column data
            DCH_colname{i} = txt(i); %responding column name
            saveChannelTitle{i} = txt(i);
            
            loc = cwttest(DCH{i}, wname);
            addrowTem{i} = loc;
            
            % plot result
            %   set(0,'CurrentFigure',S.fMain);
            
            x_max = 0 + (Data_row - 1)*dt;
            x_axis = 0:dt:x_max;% x-axis for drawing the picture
            tt = subplot(2,3,i,'Parent',S.fMain);
            y1=get(tt,'ylim'); %draw a line
            
            plot(tt, x_axis, DCH{i},[loc, loc],y1);
            title(tt,['CWT', DCH_colname{i}])
            
            
        end
        %add to save date table
        addToRow = [{fname},addrowTem];
    end

%parameters of Pphase
%new figre for paraments (type, Tn, xi, nbins) configuration
    function getCWT_pare(varargin)
        S = varargin{3};%get the whole handles
        paramaterForCWT;
    end


%batch of AIC
    function getCWT_batch(varargin)
        batchflag_CWT = true;
        S = varargin{3};%get the whole handles
        CWTbatch_matrix = {' ', 'CH0 (ms)','CH1 (ms)','CH2 (ms)','CH3 (ms)','CH4 (ms)','CH5 (ms)'};
        h = msgbox('Please wait for batch of CWT...'); % show the dialog box of waiting for batch calculation
        for listItem = 1: length(S.list.String)
            fname = S.list.String{listItem}; %get the highlight item in the listbox
            [Data,txt,raw] = xlsread(fullfile(curvePath, fname));%read .xls order .cvs data
            [Data_row, Data_col]=size(Data);
            
            addrowTem = {};% store the 6 x-axis data
            for i = 1: Data_col
                DCH{i}=Data(:,i); %one column data
                DCH_colname{i} = txt(i); %responding column name
                saveChannelTitle{i} = txt(i);              
                
                loc = cwttest(DCH{i}, wname);
                addrowTem{i} = loc;
                
            end
            %add to save date table
            addToRow_batch = [{fname},addrowTem];
            CWTbatch_matrix = [CWTbatch_matrix;addToRow_batch]; %for data saving
            
            CWTbatch_loc{end + 1} =  addrowTem;%for drawing
            
        end
        delete(h);
        [file,path] = uiputfile('file.xls','Save table of CWT batch');
        ff = fullfile(path, file);
        xlswrite(ff,CWTbatch_matrix)
        msgbox('done!')
    end

%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

%save data of onsets to .csv
    function forDataSave(varargin)
        MakeTableGUI
    end

%save data of Classic to .csv
    function forClassicDataSave(varargin)
        MakeTableGUI_Classic
    end

%save data of Frequency to .csv
    function forFreqDataSave(varargin)
        MakeTableGUI_Freq
    end

end