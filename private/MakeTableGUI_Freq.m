function MakeTableGUI_Freq
%save data from [fre,Amp ,fre_peak,fre_centroid,fre_wpeak] = AmpFre(data,Fs)

global addToRow_Freq;

%// Create figure and uielements
handles.fig = figure('Position',[10000 10000 700 830], 'Name', 'save table of frequency','NumberTitle','off');
movegui(handles.fig,'center');
handles.DispButton = uicontrol('Style','Pushbutton','Position',[20 120 80 40],'String','addFreq','Callback',@DispTableCallback);
handles.SaveButton = uicontrol('Style','Pushbutton','Position',[20 80 70 40],'String','exportFreq','Callback',@saveCallback);

empty = [{' '},{' '},{' '},{' '},{' '}];% empty row

%// Place table in GUI
t = uitable(handles.fig,'Data',[addToRow_Freq; empty],    'ColumnWidth',{200,50,80,80,80},'ColumnName',{'','ch','fre_peak(kHz)','fre_centroid(kHz)','fre_wpeak(kHz)'},...
    'Position',[110 20 800 800]);

set(t,'ColumnEditable',[logical(0),logical(0), logical(3:5)]);
%scroll

    function DispTableCallback(varargin)
        t.Data = [t.Data;addToRow_Freq; empty]; % appending 1 new data
        
        %scroll to bottom
        jScrollpane = findjobj(t);                % get the handle of the table
        scrollMax = jScrollpane.getVerticalScrollBar.getMaximum;  % get the end position of the scroll
        jScrollpane.getVerticalScrollBar.setValue(scrollMax);     % set scroll position to the end
    end

    function saveCallback(varargin)
        Data=get(t,'Data');
        ColumnName=get(t,'ColumnName');
        
        A = [ColumnName' ; Data];
        
        [file,path] = uiputfile('file.xls','Save Frequency table');
        
        ff = fullfile(path, file);
        xlswrite(ff,A)
        msgbox('done!')
    end


end