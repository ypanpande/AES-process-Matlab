function [loc,ind,k0,aicP1] = AicPicker(data_orignal,isDenoised)
%UNTITLED5 Summary of this function goes here
%   Detailed explanation goes here

%% data preprocess
data0 = data_orignal - mean(data_orignal); % substract the offset

switch isDenoised
    case  0
        data1 = data0;
    case  1
        data1 = wdenoise(data0,10, ...
            'Wavelet', 'bior4.4', ...
            'DenoisingMethod', 'SURE', ...
            'ThresholdRule', 'Hard', ...
            'NoiseEstimate', 'LevelDependent');
end
data=data1;
ind_peak = find(abs(data) == max(abs(data)));

% switch o          % choose picker range
%     case {0,'1','to_peak'}
%         ind_peak = find(abs(data) == max(abs(data)));
%         xnew = data(1:ind_peak);
%     otherwise
%         xnew = data;
% end


% %% set the threshold amplitude level and get the first time window for AIC picking [1,k0]
% n=length(data);
% sum1=0;
% sum2=0;
% k_0=n;
% for i=1:n
%     for j=1:i
%         sum1=sum1+abs(data(j));
%     end
%     for m=i+1:i+wset
%         if m>n
%             break
%         end
%         sum2=sum2+abs(data(m));
%     end
%     
%     if (sum2/wset) >= (fold*sum1/i)
%         k_0=i;
%         break
%     end
% end
% 
% if k_0==n || k_0==1
%     k0=ind_peak;
% else
%     k0=k_0;
% end
k0=ind_peak;
%% calculating onset time using the AIC Algorithm with function equation in the window[1,k0]

% AIC(k) = k*log(var(x[1,k])) + (n-k-1)*log(var(x[k+1,n])) where k
%          goes from 1 to length(x)

x=data(1:k0);

if ~isempty(x)
    num = length(x);
    if num > 1
        for k=1:num-1
            %calculate variance in first part
            xLogVar1 = var(x(1:k));
            if xLogVar1 <= 0
                xLogVar1 = 0;
            else
                xLogVar1=log(xLogVar1);
            end
            %compute variance in second part
            xLogVar2 = var(x(k+1:num));
            if xLogVar2 <= 0
                xLogVar2 = 0;
            else
                xLogVar2=log(xLogVar2);
            end
            aicP1(k) = k*(xLogVar1) + (num-k-1)*(xLogVar2);
        end
    else
        aicP1 = 0;
    end
else
    aicP1 = 0;
end
% % find the position of the mininum
if aicP1 ~= 0
    ind = find(aicP1 == min(aicP1)) + 1;  % pick is one more than divide point
else
    ind = 0;
end

% %% calculating onset time using the AIC Algorithm with function equation in the window[2*ind1-k0,k0]
% winlen=2*k0-2*ind1;
% if ind1~=0
%     if winlen > 1
%         if 2*ind1-k0>1
%             y=data(2*ind1-k0:k0);
%             if ~isempty(y)
%                 num2 = length(y);
%                 for k2=1:num2-1
%                     %calculate variance in first part
%                     yLogVar1 = var(y(1:k2));
%                     if yLogVar1 <= 0
%                         yLogVar1 = 0;
%                     else
%                         yLogVar1=log(yLogVar1);
%                     end
%                     %compute variance in second part
%                     yLogVar2 = var(y(k2+1:num2));
%                     if yLogVar2 <= 0
%                         yLogVar2 = 0;
%                     else
%                         yLogVar2=log(yLogVar2);
%                     end
%                     aicP2(k2) = k2*(yLogVar1) + (num2-k2-1)*(yLogVar2);
%                 end
%             else
%                 aicP2 = 0;
%             end
%             
%             % % find the position of the mininum
%             if aicP2 ~= 0
%                 ind2 = find(aicP2 == min(aicP2)) + 1;  % pick is one more than divide point
%                 ind = 2*ind1-k0+ind2-1;
%             else
%                 ind = ind1;
%             end
%             
%         else
%             ind = ind1;
%         end
%         
%     else
%         ind=ind1;
%     end
%     
% else
%     ind =ind1;
% end

dt=0.004; % time step (unit: ms)

if ind~=0
    loc=(ind-1)*dt;
else
    loc=0;
%% plot
%
% subplot(4,1,1);
% %yt1=get(s0,'ylim');
% plot(data);
% % hold on
% % plot([ind,ind],[-Inf, Inf],'r')
% % hold off
% subplot(4,1,2);
% plot([1:k0],data(1:k0));
% axis([1,length(data),-Inf,Inf]);
% subplot(4,1,3);
% plot(aicP1);
% %text(ind1,aicP1(ind1),'s','Color','r')
% axis([1,length(data),-Inf,Inf]);
% subplot(4,1,4);
% plot([2*ind1-k0:k0-1],aicP2);
% %text(ind,aicP2(ind2),'s','Color','r')
% axis([1,length(data),-Inf,Inf]);



end

