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

