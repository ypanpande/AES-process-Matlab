function  paramaterForPphasePicker
%function paramaterForPphasePicker [type2, Tn2, xi2, nbins2] 

 global type;
  global Tn;
 global  nbins;
  global xi;
  
%   type1 = type;
%   Tn1 = Tn;
%   xi1 = xi;
%   nbins1 = nbins;
  
 figg=figure;
% dt=29;


% default value
%  type = 'sm';
%  Tn = 0.01;
%  nbins = round(2/dt);
%  xi = 0.6;
 
% loc = [];
% type = 'sm';
% Tn = 0.01;
% nbins = round(2/dt);
% xi = 0.6;
% Main window
set(figg,'Position',[10000 10000 250 340],'NumberTitle','off','Name','parameter for PphasePicker',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');
%%
%         1.type = 'sm' or 'SM' for acceleration waveform (default bandwidth
%                = 0.1-20 Hz)
%                'wm' or 'WM' for velocity waveform (default bandwidth 7-90
%                Hz)
%                'na' or 'NA' no bandpass filtering

hfctlbl = uicontrol('Parent',figg,'Style','text','String','1.type:','Position',[0 270 250 30],'BackgroundColor',bgclr);
hfct = uicontrol('Parent',figg,'Style','popupmenu','Value',1,'BackgroundColor','white','Position',[0 250 250 30],'Callback',{@typeFcn},...
    'String',{'sm','SM','wm','WM','na' , 'NA'});

%2.Tn = undamped natural period in second (default is 0.01 for
%           records sampled with 100 samples-per-second or larger; for
%           records with lower than 100 samples-per-second default
%           is 0.1 s)
hthresholdlbl = uicontrol('Parent',figg,'Style','text','String','2.undamped natural period in second(Tn)','Position',[0 210 250 30],'BackgroundColor',bgclr);
hthreshold = uicontrol('Parent',figg,'Style','edit','String',num2str(Tn),'BackgroundColor','white','Position',[0 200 250 20],'Callback',{@TnFcn});

%        3.nbins = histogram bin size (default is 2/dt for
%                strong-motion acceleration and broadband velocity
%                waveforms; regional or teleseismic records may need
%                different values of bin size for better picking results)
horderlbl = uicontrol('Parent',figg,'Style','text','String','3.histogram bin size, default is 2/dt (nbins)','Position',[0 160 250 20],'BackgroundColor',bgclr);
hthreshold = uicontrol('Parent',figg,'Style','edit','String',num2str(nbins),'BackgroundColor','white','Position',[0 140 250 20],'Callback',{@nbinsFcn});

%          4. xi = damping ratio (default is 0.6)
% slider
horderlbl = uicontrol('Parent',figg,'Style','text','String','4.damping ratio, default is 0.6(xi)','Position',[0 100 250 20],'BackgroundColor',bgclr);
horder = uicontrol('Parent',figg,'Style','slider','SliderStep',[0.1 0.1],'Min',0.1,'Max',1,'Value',xi,'SliderStep',[0.1 0.1],'Position',[0 80 250 20],'Callback',{@xiFcn});
horderval = uicontrol('Parent',figg,'Style','text','String',num2str(xi),'Position',[0 60 250 20],'BackgroundColor',bgclr);

%confirm button
%uicontrol('Parent',figg,'Style','PushButton','String', 'OK','Position',[25 40 100 30],'Callback',{@OK});

% %%



    function typeFcn(source,eventdata)
        type = source.String{source.Value}
        
       % loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
    end

    function TnFcn(source,eventdata)
        Tn = str2double(source.String);
     %   loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
    end

    function nbinsFcn(source,eventdata)
        nbins = str2double(source.String);
     %   loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
    end

    function xiFcn(source,eventdata)
        % Change order
        xi = source.Value;
        set(horderval,'String',num2str(xi));
    %    loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
    end

%     function OK(source,eventdata)
%         loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
%     end


end