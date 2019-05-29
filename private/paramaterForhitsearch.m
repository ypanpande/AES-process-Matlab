function  paramaterForhitsearch
%function paramaterForhitsearch [set, fold] 

global pref  ; 
global hit_width  ; 
global hit_dis  ; 

   
 figg=figure;
% dt=0.004;
% default value
%  pref = 1;
%  hit_width = 50;
%  hit_dis = 100;


% Main window
set(figg,'Position',[10000 10000 250 340],'NumberTitle','off','Name','parameter for Classic',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');
%%

% threshold calculation using the rms of the first n point data
%%%  %th=pref*rms(d2(1:AmpMax_loc));

%         1.pref = the factor for threshold amplitude determination
%         2.hit_width = mindest hit width
%         3.hit_dis = mindest distance between two nearby hits

% %  1.pref = the factor for threshold amplitude determination
 uicontrol('Parent',figg,'Style','text','String','1.prefactor for threshold amplitude determination','Position',[0 210 250 30],'BackgroundColor',bgclr);
prefb = uicontrol('Parent',figg,'Style','edit','String',num2str(pref),'BackgroundColor','white','Position',[0 200 250 20],'Callback',{@prefFcn});

% % 2.hit_width = mindest hit width
%                
 uicontrol('Parent',figg,'Style','text','String','2.mindest hit width','Position',[0 160 250 20],'BackgroundColor',bgclr);
widthb = uicontrol('Parent',figg,'Style','edit','String',num2str(hit_width),'BackgroundColor','white','Position',[0 140 250 20],'Callback',{@widthFcn});

% % 3.hit_dis = mindest distance between two nearby hits
%                
 uicontrol('Parent',figg,'Style','text','String','2.mindest distance between two nearby hits','Position',[0 100 250 20],'BackgroundColor',bgclr);
disb = uicontrol('Parent',figg,'Style','edit','String',num2str(hit_dis),'BackgroundColor','white','Position',[0 80 250 20],'Callback',{@distanceFcn});

% %%


    function prefFcn(source,eventdata)
        pref = str2double(source.String);
    end

    function widthFcn(source,eventdata)
        hit_width = str2double(source.String);
    end

    function distanceFcn(source,eventdata)
        hit_dis = str2double(source.String);
    end


end