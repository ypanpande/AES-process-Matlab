function  paramaterForSBP

global pxThreshold   ;
global sWindow       ;              % Window lenght for measuring signal amps after p-pick [sec]
global nWindow       ;              % Window lenght for measuring noise before p-pick [sec]
global wmax          ;
global wmin          ;
global sWtFct        ;      % 'lin' or 'exp' or '1-exp'
global nWtFct        ;      % 'lin' or 'exp' or '1-exp'
global ntap          ;        %  No. of tapered samples

figg=figure;
 

set(figg,'Position',[10000 10000 400 540],'NumberTitle','off','Name','parameter for SBP picker',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');

% ppxIdx0      = approximate pick index; pick is only searched at k>ppxIdx0
% 1.threshold    = amplitude threshold for STA/LTA pick declaration; a pick is
%                declared when signal-amplitudes >= threshold*noise-amplitudes
% 2.signalWindow = window length for measuring signal amplitudes [sec]
% 3.noiseWindow  = window length for measuring noise  amplitudes [sec]
% 4.wmin & 5.wmax  = minimum and maximum values of weighting function
%  6.sWtFct        ;      % 'lin' or 'exp' or '1-exp'
%  7.nWtFct        ;      % 'lin' or 'exp' or '1-exp'
% 8.ntap         = number of tapered samples in input waveform. Estimating pre-
%                event signal-amplitudes starts after ntap; use ntap=0 if
%                no tapering has been applied
% o_plot       = if o_plot    ='true', rough as well as optimised picks are plotted 
% o_animate    = if o_animate ='true', the optimisation is graphically
%                animated; try it, it's fun and it helps to understand what
%                is going on...
% 1.threshold 
 uicontrol('Parent',figg,'Style','text','String','1.threshold: amplitude threshold for STA/LTA pick declaration; a pick is declared when signal-amplitudes >= threshold*noise-amplitudes','Position',[0 495 400 35],'BackgroundColor',bgclr);
pb1 = uicontrol('Parent',figg,'Style','edit','String',num2str(pxThreshold),'BackgroundColor','white','Position',[ 175 480 80 20],'Callback',{@ButtFcn});
% 2.signalWindow
 uicontrol('Parent',figg,'Style','text','String','2.signalWindow: window length for measuring signal amplitudes [sec]','Position',[0 450 400 15],'BackgroundColor',bgclr);
pb2 = uicontrol('Parent',figg,'Style','edit','String',num2str(sWindow),'BackgroundColor','white','Position',[175 430 80 20],'Callback',{@ButtFcn});
%3.noiseWindow
 uicontrol('Parent',figg,'Style','text','String','3.noiseWindow: window length for measuring noise  amplitudes [sec]','Position',[0 400 400 15],'BackgroundColor',bgclr);
pb3 = uicontrol('Parent',figg,'Style','edit','String',num2str(nWindow),'BackgroundColor','white','Position',[175 380 80 20],'Callback',{@ButtFcn});
% 4.wmin
 uicontrol('Parent',figg,'Style','text','String','4.wmin: minimum value of weighting function','Position',[0 350 400 15],'BackgroundColor',bgclr);
pb4 = uicontrol('Parent',figg,'Style','edit','String',num2str(wmax),'BackgroundColor','white','Position',[175 330 80 20],'Callback',{@ButtFcn});
% 5.wmax
 uicontrol('Parent',figg,'Style','text','String','5.wmax: maximum value of weighting function','Position',[0 290 400 15],'BackgroundColor',bgclr);
pb5 = uicontrol('Parent',figg,'Style','edit','String',num2str(wmin),'BackgroundColor','white','Position',[175 270 80 20],'Callback',{@ButtFcn});
%  6.sWtFct
 uicontrol('Parent',figg,'Style','text','String','6.sWtFct: lin or exp or 1-exp','Position',[0 240 400 15],'BackgroundColor',bgclr);
plist6 = uicontrol('Parent',figg,'Style','popupmenu','Value',1,'BackgroundColor','white','Position',[175 220 80 20],'Callback',{@listFcn},...
    'String',{'exp','lin','1-exp'});
%  7.nWtFct
 uicontrol('Parent',figg,'Style','text','String','7.nWtFct: lin or exp or 1-exp','Position',[0 170 400 15],'BackgroundColor',bgclr);
plist7 = uicontrol('Parent',figg,'Style','popupmenu','Value',1,'BackgroundColor','white','Position',[175 150 80 20],'Callback',{@listFcn},...
    'String',{'exp','lin','1-exp'});
% 8.ntap  
ss = '8.ntap: number of tapered samples in input waveform. Estimating pre-event signal-amplitudes starts after ntap; use ntap=0 if no tapering has been applied';
 uicontrol('Parent',figg,'Style','text','String',ss,'Position',[0 90 400 30],'BackgroundColor',bgclr);
pb8 = uicontrol('Parent',figg,'Style','edit','String',num2str(ntap),'BackgroundColor','white','Position',[175 60 80 20],'Callback',{@ButtFcn});

%return to default
pbDefault = uicontrol('Parent',figg,'Style','pushbutton','String','Todefault','BackgroundColor','white','Position',[175 30 80 20],'Callback',{@ButtFcn});

    function ButtFcn(source,eventdata)
        switch source
            case pb1
                pxThreshold = str2num(source.String);
            case pb2
                sWindow = str2num(source.String);
            case pb3
                nWindow = str2num(source.String);
            case pb4
                wmin = str2num(source.String);
            case pb5
                wmax = str2num(source.String);
            case pb8
                ntap = str2num(source.String);
            case pbDefault
                pxThreshold = 5; pb1.String = num2str(pxThreshold);
                sWindow     = 1;pb2.String = num2str(sWindow);
                nWindow     = 1;pb3.String = num2str(nWindow);
                wmax        = 1e1;pb5.String = num2str(wmax);
                wmin        = .1;pb4.String = num2str(wmin);
                ntap        = 100;  pb8.String = num2str(ntap);
        end
    end

    function listFcn(source,eventdata)
        
        if source == plist6
            sWtFct = source.String{source.Value}; 
        elseif source == plist7
            nWtFct = source.String{source.Value};                 
        end
    end


end