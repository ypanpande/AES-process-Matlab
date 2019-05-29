function  paramaterForAmpFre
%function paramaterForAmpFre [Fs] 

 global Fs;
 

   
 figg=figure;
% dt=0.004;
% default value
%  Fs = 250000;


% Main window
set(figg,'Position',[10000 10000 250 340],'NumberTitle','off','Name','parameter for AIC Picker',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');
%%
% %   Fs: sample rate

%         1.Fs = sample rate (for exmaple how many points are measured in one second)


% % Fs = sample rate
 uicontrol('Parent',figg,'Style','text','String','1.sample rate','Position',[0 210 250 30],'BackgroundColor',bgclr);
Fsb = uicontrol('Parent',figg,'Style','edit','String',num2str(Fs),'BackgroundColor','white','Position',[0 200 250 20],'Callback',{@FsFcn});





% %%


    function FsFcn(source,eventdata)
        Fs = str2double(source.String);
    end

   

 


end