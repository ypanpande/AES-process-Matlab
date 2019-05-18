function t = cwttest(data,wname)
% wname wname are 'morse', 'amor', and 'bump'
%data = CH5;
t=0:1/250:8191/250;
[wt,f] = cwt(data,wname,250000);
S=abs(wt.*wt);
max1=max(max(S));
min1=min(min(S));
y = (S-min1) ./(max1-min1);
y2=medfilt1(y);
y3 = imbinarize(y2);
[~,col] = find(y3);
t=(col(1)-1)/250;

% 
% figure(1)
% cwt(data,wname,250000)
% figure(2)
% subplot(3,1,1)
% imagesc(t,f,y)
% set(gca,'YDir','normal')
% subplot(3,1,2)
% imagesc(t,f,y2)
% set(gca,'YDir','normal')
% subplot(3,1,3)
% imagesc(t,f,y3)
% set(gca,'YDir','normal')

end