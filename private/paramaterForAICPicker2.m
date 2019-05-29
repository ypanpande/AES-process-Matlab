function  paramaterForAICPicker2
%function paramaterForAICPicker [set, fold] 

 global isDenoised;
%  global fold;

   
 figg=figure;
% dt=0.004;
% default value
%  set= 50;
%  fold = 5;


% Main window
set(figg,'Position',[10000 10000 250 340],'NumberTitle','off','Name','parameter for AIC Picker',...
    'MenuBar','none','Resize','off');
bgclr = get(figg,'Color');
% % Move the GUI to the center of the screen
movegui(figg,'center');
%%
%%% the onset time is first pre-determined using a threshold amplitude
%%% level: $$ sum_{k=i+1}^{k=wset}|x_k|/wset = fold*sum_{k=1}^{k=i}|x_k|/i $$

%         1.wset = time window for threshold amplitude determination
%         2.fold = the factor for the signal trigger  

% % 1.wset = time window for threshold amplitude determination
 uicontrol('Parent',figg,'Style','text','String','whether denoising the data, 1:Yes, 0:No','Position',[0 210 250 30],'BackgroundColor',bgclr);
wsetb = uicontrol('Parent',figg,'Style','edit','String',num2str(isDenoised),'BackgroundColor','white','Position',[0 200 250 20],'Callback',{@setFcn});

% % % 2.fold = the factor for the signal trigger 
% %                
%  uicontrol('Parent',figg,'Style','text','String','2.the factor for the signal trigger','Position',[0 160 250 20],'BackgroundColor',bgclr);
% foldb = uicontrol('Parent',figg,'Style','edit','String',num2str(fold),'BackgroundColor','white','Position',[0 140 250 20],'Callback',{@foldFcn});



% %%


    function setFcn(source,eventdata)
        isDenoised = str2double(source.String);
    end

%     function foldFcn(source,eventdata)
%         fold = str2double(source.String);
%     end

 


end