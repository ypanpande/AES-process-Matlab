function  paramaterForCWT
%function paramaterForCWT [wname] 

 global wname;

 
  
 figg=figure;


% default value
%   wname = 'morse';

 

% Main window
set(figg,'Position',[10000 10000 250 340],'NumberTitle','off','Name','parameter for CWT',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');
%%
%         wname are 'morse', 'amor', and 'bump'


hfctlbl = uicontrol('Parent',figg,'Style','text','String','wname:','Position',[0 270 250 30],'BackgroundColor',bgclr);
hfct = uicontrol('Parent',figg,'Style','popupmenu','Value',1,'BackgroundColor','white','Position',[0 250 250 30],'Callback',{@wnameFcn},...
    'String',{'morse', 'amor', 'bump'});






    function wnameFcn(source,eventdata)
        wname = source.String{source.Value}
        
       % loc = PphasePicker(x, dt, type, 'N', Tn, xi, nbins, 'to_peak');
    end

   



end