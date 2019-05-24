function [fre_peak,fre_centroid,fre_wpeak,Amp_max,Power,PP,pppc,fre,Amp] = AmpFre2(data,Fs)
% function [fre_peak,fre_centroid,fre_wpeak,fre,Amp] = AmpFre(data,Fs)
%AmpFre fft function
%   data: signal
%   Fs: sample rate
% for example
% Fs=200;
% Ts=1/Fs;
% t=0:Ts:2-Ts;
% N=length(t);
% f1=20;
% f2=60;
% y=4*sin(2*pi*f1*t)+5*cos(2*pi*f2*t);
% initial value
fre_peak=0;
fre_centroid=0;
fre_wpeak=0;
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% FFT 
N=length(data);
Y=abs(fft(data));
% amplitude
Amp=Y/(N/2);
Amp=Amp(1:N/2);
Amp=Amp';
 Amp(1)=0;
% frequency
k=0:N-1;
T=N/Fs;
fre=k/T;
fre=fre(1:N/2);
%figure
%plot(fre,Amp);

% calculate fre_peak, fre_centroid; fre_wpeak
[Amp_max,indfre]=max(Amp(2:end));
fre_peak_0=fre(indfre+1); %unit: Hz
fre_peak=fre_peak_0/1000; %unit: kHz
inte1=Amp.*fre;
fre_centroid_0=trapz(inte1)/trapz(Amp); %unit: Hz
fre_centroid=fre_centroid_0/1000; %unit: kHz
fre_wpeak_0=sqrt(fre_peak_0*fre_centroid_0); %unit: Hz
fre_wpeak=fre_wpeak_0/1000; %unit: kHz

% calculate the partial power in the frequency range
% (0,4k),(4,8k),(8,12k),(12,16k),(16,20k),(20,125k) corresponding to
% [1:132],[133:263],[264:394],[395:525],[526:656],[657:4096]
% (0,5k),(5,10k),(10,15k),(15,20k),(20,125k) corresponding to
% [1:164],[165:328],[329:492],[493:656],[657:4096]

PartialPower1 = trapz(Amp(1:164).^2);
PartialPower2 = trapz(Amp(165:328).^2);
PartialPower3 = trapz(Amp(329:492).^2);
PartialPower4 = trapz(Amp(493:656).^2);
%PartialPower5 = trapz(Amp(526:656).^2);
PartialPower5 = trapz(Amp(657:4096).^2);
Power = trapz(Amp(1:end).^2);
PP = [PartialPower1,PartialPower2,PartialPower3,PartialPower4,PartialPower5];
pppc = PP*100/Power;


end

