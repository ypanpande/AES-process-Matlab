function MakeTableGUI_Classic
%save data from [hit,hit_loc,AmpMax,Duration,RiseTime,Energy,OnsetT] = hitsearch(data,pref,hit_width,hit_dis )

global addToRow_Classic;

%// Create figure and uielements
handles.fig = figure('Position',[10000 10000 950 830], 'Name', 'save table of classic parameters','NumberTitle','off');
movegui(handles.fig,'center');
handles.DispButton = uicontrol('Style','Pushbutton','Position',[20 120 80 40],'String','addClassic','Callback',@DispTableCallback);
handles.SaveButton = uicontrol('Style','Pushbutton','Position',[20 80 70 40],'String','exportClassic','Callback',@saveCallback);

empty = [{' '},{' '},{' '},{' '},{' '},{' '},{' '},{' '}];% empty row

%// Place table in GUI
t = uitable(handles.fig,'Data',[addToRow_Classic; empty],    'ColumnWidth',{200,50,80,80,80,80,80,80},'ColumnName',{'','ch','AmpMax','Duration(ms)','RiseTime(ms)','Energy','OnsetT(ms)','Threshold'},...
    'Position',[110 20 800 800]);

set(t,'ColumnEditable',[logical(0), logical(0), logical(3:8)]);
%scroll

    function DispTableCallback(varargin)
        t.Data = [t.Data;addToRow_Classic; empty]; % appending 1 new data
        
        %scroll to bottom
        jScrollpane = findjobj(t);                % get the handle of the table
        scrollMax = jScrollpane.getVerticalScrollBar.getMaximum;  % get the end position of the scroll
        jScrollpane.getVerticalScrollBar.setValue(scrollMax);     % set scroll position to the end
    end

    function saveCallback(varargin)
        Data=get(t,'Data');
        ColumnName=get(t,'ColumnName');
        
        A = [ColumnName' ; Data];
        
        [file,path] = uiputfile('file.xls','Save Classic table');
        
        ff = fullfile(path, file);
        xlswrite(ff,A)
        msgbox('done!')
    end


end