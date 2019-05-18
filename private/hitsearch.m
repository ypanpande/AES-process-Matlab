function [AmpMax,Duration,RiseTime,Energy,OnsetT,th,hit_loc,d1,up] = hitsearch(data,pref,hit_width,hit_dis )
% hitsearch function count the number of hit that above the threshold

% % input parameters
%   data:  the signal
%   th: the value of threshold
%   hit_width: mindest hit width
%   hit_dis: mindest distance between two nearby hits

% % output parameters
%   hit: the number of hit that above the threshold
%   hit_loc: the start and end point of each hit

% for example
% th=228;  %set the value of threshold
% hit_width=20; % mindest hit width
% hit_dis=30; % mindest distance between two nearby hit width

%% input data and preprocess
d0=data;
dm=mean(d0); % estimate the offset
d1=d0-dm; % substract the offset
d2=d1;
np=length(d1);


% threshold calculation using the rms of the first n point data

[AmpMax,AmpMax_loc]=max(d1);

%th=pref*rms(d2(1:AmpMax_loc));

indm=find(d2<0);
d2(indm)=-d2(indm);  % flip the signal
[up,lo]=envelope(d2,50,'peak'); % find the envelope
%th=pref*rms(up(1:AmpMax_loc));
 th=pref*mean(abs(up(1:512)));
%up=envelope(d2);
% figure
% plot([d2,up])
% line([1,np],[th, th], 'Color','r')
%% search for the hits
% set the parameters
indnh3=[]; % start and end point of hits
hit=0; % number of hits

indnh=find(up>=th);
if (length(indnh)==0)||(length(indnh)==0)
    hit=0;
    disp('all below threshold');
    %break
else
    indnh1=diff(indnh);
    indnh2=find(indnh1~=1);
    if isempty(indnh2)          % only one hit
        %if (up(indnh(1))*up(indnh(1)-1)>th^2)||(up(indnh(end))*up(indnh(end)+1)>th^2)
        if (indnh(1)==1)||(indnh(end)==length(up))
            hit=0;
        else
            hit=1;
            indnh3=[indnh(1),indnh(end)];
        end
    else                      % more hits
        brPoint=length(indnh2);
        hit=brPoint+1;
        if indnh(1)==1      %up(indnh(indnh2(1))*up(indnh(indnh2(1)-1))>th^2  %first break point
            hit=hit-1;
            indnh3=indnh(indnh2(1)+1);
        else
            indnh3=[indnh(1),indnh(indnh2(1)),indnh(indnh2(1)+1)];
        end
        for i=2:brPoint % second till last break point
            indnh3=[indnh3,indnh(indnh2(i)),indnh(indnh2(i)+1)];
        end
        if indnh(end)==length(up)
            indnh3(end)=[];
            hit=hit-1;
        else
            indnh3=[indnh3,indnh(end)];
        end
    end
end
if mod(length(indnh3),2)
    disp('something is wrong');
end
% check whether the width of the hits is larger than the mindest width
indnh3_odd=indnh3(1:2:end);
indnh3_even=indnh3(2:2:end);
indnh4=find((indnh3_even-indnh3_odd)<hit_width);
hit=hit-length(indnh4);
indnh3_odd(indnh4)=[];
indnh3_even(indnh4)=[];
indnh5=[];
for j=1:length(indnh3_odd)
    indnh5=[indnh5,indnh3_odd(j),indnh3_even(j)];
end
% check whether the distance between two nearby hits is larger than the mindest distance
if hit>=2
    le_nh5=length(indnh5);
    for m=2:2:le_nh5-2
        if ((indnh5(m+1)-indnh5(m)) < hit_dis)
            indnh5(m:m+1)=[0,0];
            hit=hit-1;
        end
    end
    hit_loc=indnh5(find(indnh5));
else
    hit_loc=indnh5;
end


%% find amplitude, duration, count, rise time, onset time

if hit==0
    Duration=-1;
    RiseTime=-1;
    Energy=-1;
    OnsetT=-1;
    hit_loc=[-1,-1];
else
    [AmpMax_1,AmpMax_loc_1]=max(d1(hit_loc(1):hit_loc(2)));
    if AmpMax==AmpMax_1
        Duration=hit_loc(2)-hit_loc(1);
        RiseTime=AmpMax_loc-hit_loc(1);
        Energy=trapz(up(hit_loc(1):hit_loc(2)).^2);
        %Energy2=sum(up(hit_loc(1):hit_loc(2)).^2);
        A=[hit_loc(1),1; AmpMax_loc_1+hit_loc(1)-1,1];
        B=[up(hit_loc(1));AmpMax_1];
        X=A\B;
        OnsetT=-X(2)/X(1);
        %OnsetT=(hit_loc(1)*AmpMax_1-(AmpMax_loc_1+hit_loc(1)-1)*up(hit_loc(1)))/(AmpMax_1-up(hit_loc(1)));   % cross point (x2y1-x1y2)/(y1-y2).  slope=(y1-y2)/(x1-x2), inter=(x1y2-x2y1)/(x1-x2)
        %sm_hit1=smooth(d1(hit_loc(1):hit_loc(2)),20,'sgolay',2);
        %Count=length(findpeaks(sm_hit1,'MinPeakHeight',th,'MinPeakProminence',40));
    else
        Duration=0;
        RiseTime=0;
        Energy=0;
        OnsetT=0;
        hit_loc=[0,0];
        %disp('the maximum amplitude locates not in the first hit')
end
%Count=length(find(diff(sign(diff(d1(hit_loc(1):hit_loc(2)))))<0));

%% plot the figure

% figure
% plot([d1,up])
% line([1,np],[th, th], 'Color','r') % threshold line
% line([hit_loc(1), AmpMax_loc_1+hit_loc(1)-1],[up(hit_loc(1)), AmpMax_1], 'Color','g') % determine onset time 
% line([hit_loc(1),hit_loc(1)],[min(d1(:)), max(d1(:))], 'Color','r') % first hit start point
% line([hit_loc(2),hit_loc(2)],[min(d1(:)), max(d1(:))], 'Color','r') % first hit end point
% figure
% findpeaks(sm_hit1,'MinPeakHeight',th,'MinPeakProminence',40)
end

