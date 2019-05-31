function MakeTableGUI


global addToRow;

%// Create figure and uielements
handles.fig = figure('Position',[10000 10000 850 630], 'Name', 'save table of onset time','NumberTitle','off');
movegui(handles.fig,'center');
handles.DispButton = uicontrol('Style','Pushbutton','Position',[20 120 80 40],'String','addToTable','Callback',@DispTableCallback);
handles.SaveButton = uicontrol('Style','Pushbutton','Position',[20 80 60 40],'String','export','Callback',@saveCallback);


%// Place table in GUI
t = uitable(handles.fig,'Data',addToRow,'ColumnWidth',{200,70,70,70,70,70,70},'ColumnName',{'','CH0 (ms)','CH1 (ms)','CH3 (ms)','CH5 (ms)','CH6 (ms)'},...
    'Position',[110 20 700 560]);
set(t,'ColumnEditable',[logical(0), logical(1:5)])


    function saveCallback(varargin)
        Data=get(t,'Data');
        ColumnName=get(t,'ColumnName');
        
        A = [ColumnName' ; Data];
        
        [file,path] = uiputfile('file.xls','Save table');
        
        ff = fullfile(path, file);
        xlswrite(ff,A)
        msgbox('done!')
    end


end