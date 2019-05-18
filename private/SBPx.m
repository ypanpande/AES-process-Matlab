function [k,snr,ha,ax] = SBPx(s,dt,ppxIdx0,threshold,signalWindow,noiseWindow,wmax,wmin,signalWtFct,noiseWtFct,ntap,o_plot,o_animate)

% Picking algorithm that computes simple STA/LTA pick as rough initial
% estimate and then evaluates candidate picks around the initial estimate
% by optimising a ratio of integrated weighted amplitudes from before and 
% after the candidate pick. It is called Suspension Bridge Picker (SBPx) 
% because the weighting function resembles a pillar of a suspension bridge.
%
% menandrin@gmail.com, last update: 150320, version 1.0
%
%                                            ^^
%       ^^      ..                                       ..
%               []                                       []
%             .:[]:_          ^^                       ,:[]:.
%           .: :[]: :-.                             ,-: :[]: :.
%         .: : :[]: : :`._                       ,.': : :[]: : :.
%       .: : : :[]: : : : :-._               _,-: : : : :[]: : : :.
%   _..: : : : :[]: : : : : : :-._________.-: : : : : : :[]: : : : :-._
%   _:_:_:_:_:_:[]:_:_:_:_:_:_:_:_:_:_:_:_:_:_:_:_:_:_:_:[]:_:_:_:_:_:_
%   !!!!!!!!!!!![]!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!![]!!!!!!!!!!!!!
%   ^^^^^^^^^^^^[]^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^[]^^^^^^^^^^^^^
%               []                                       []
%               []                                       []
%               []                                       []
%    ~~^-~^_~^~/  \~^-~^~_~^-~_^~-^~_^~~-^~_~^~-~_~-^~_^/  \~^-~_~^-~~- 
%   ~ _~~- ~^-^~-^~~- ^~_^-^~~_ -~^_ -~_-~~^- _~~_~-^_ ~^-^~~-_^-~ ~^
%  jgs  ^- _~~_-  ~~ _ ~  ^~  - ~~^ _ -  ^~-  ~ _  ~~^  - ~_   - ~^_~
%
%   (this piece of ascii-art is copied from http://www.chris.com/ascii/)
%
%
%
% OVERVIEW    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% 0. Preparations
% 1. Compute approximate pick from STA/LTA picker
% 2. Optimise pick
%    2a. Compute optimised pick
%    2b. Animate pick optimisation
% 3. Plot final pick
%
%
% INPUT       -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% s            = signal
% dt           = inverse sampling rate
% ppxIdx0      = approximate pick index; pick is only searched at k>ppxIdx0
% threshold    = amplitude threshold for STA/LTA pick declaration; a pick is
%                declared when signal-amplitudes >= threshold*noise-amplitudes
% signalWindow = window length for measuring signal amplitudes [sec]
% noiseWindow  = window length for measuring noise  amplitudes [sec]
% wmin & wmax  = minimum and maximum values of weighting function
% ntap         = number of tapered samples in input waveform. Estimating pre-
%                event signal-amplitudes starts after ntap; use ntap=0 if
%                no tapering has been applied
% o_plot       = if o_plot    ='true', rough as well as optimised picks are plotted 
% o_animate    = if o_animate ='true', the optimisation is graphically
%                animated; try it, it's fun and it helps to understand what
%                is going on...
%
%
% OUTPUT      -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% k            = index of pick (returned empty if no pick was found)
% snr          = ratio of average signal power to average noise power
% ha           = figure handle
% ax           = axes handle
%
%
% HOW TO RUN IT / EXAMPLE    -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
% pxThreshold = 5;
% sWindow     = 1;        % Window lenght for measuring signal amps after p-pick [sec]
% nWindow     = 1;        % Window lenght for measuring noise before p-pick [sec]
% wmax        = 1e1;
% wmin        = .1;
% sWtFct      = 'lin';    % 'lin' or 'exp' or '1-exp'
% nWtFct      = 'lin';    % 'lin' or 'exp' or '1-exp'
% ntap        = 100;      % No. of tapered samples
% o.plotPx    = true;
% o.animatePx = true;
% [ppxIdx,snr,ha,ax] = SBPx(signal,1/sr,0,pxThreshold,sWindow,nWindow,wmax, ...
%                            wmin,sWtFct,nWtFct,ntap,o.plotPx,o.animatePx);
% .........................................................................




%% 0. PREPARATIONS

ns = numel(s);
sr = 1/dt;

% Parameters
tw1 = int32(1/dt);   % length of long/fixed   time window [no. of samples]
tw2 = int32(0.1/dt); % length of short/moving time window [no. of samples]

% Search for optimal pick around STA/LTA pick. Start search at <preShift>
% seconds before STA/LTA pick and stop search at <postShift> seconds after
% STA/LTA pick
preShift    = 2;     
postShift   = 1;     
nshift      = 3; % Shift increment, No. of samples by which pick is shifted per iteration


%-------------------------------------------------------------------------%
%                                                                         % 
%         k0 .. k1 .. k2 .. .. .. ki        -->                           %
%                                           -->                           %
%                                   tw2     -->                           %
%                                 |------|  -->                           %
%                                amps_short                               %
% | ntap  |                                          /\                /\ %
%                                                   /  \        /\    /   %
% ---------/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/\/    \  /\  /  \  /    %
%               tw1                                |     \/  \/    \/     % 
%         |--------------|                     p-onset                    %
%            amps_long                                                    %
%-------------------------------------------------------------------------%


% Prepare figure
ftSize      = 12;
if nargin<13; o_animate = 0; end
if nargin<12; o_plot    = 0; end
if o_plot;    figure(311); clf; kk= []; ratio = []; whitebg('w'); end
if o_animate
    ha=figure(312); whitebg('w'); clf;
    ax=subplot(6,1,1:2); hold on; grid on; plot(s,'k')
    s2=subplot(6,1,3);   hold on; grid on;
    s3=subplot(6,1,4);   hold on; grid on;
    s4=subplot(6,1,5);   hold on; grid on;
    s5=subplot(6,1,6);   hold on; grid on;
    l1=[];l2=[];p1=[];pw1=[];pw2=[];pw3=[];pw4=[];pw5=[];pw6=[];pw7=[];pw8=[];

    % If you have subtightplot.m, you may use this instead
    %     ax=subtightplot(6,1,1:2,[dh,dw]);   hold on; grid on;
    %     plot(s,'k')
    %     s2=subtightplot(6,1,3  ,[.02,dw]);   hold on; grid on;
    %     s3=subtightplot(6,1,4  ,[.02,dw]);   hold on; grid on;
    %     s4=subtightplot(6,1,5  ,[.02,dw]);   hold on; grid on;
    %     s5=subtightplot(6,1,6  ,[.02,dw]);   hold on; grid on;
    %     l1=[];l2=[];p1=[];pw1=[];pw2=[];pw3=[];pw4=[];pw5=[];pw6=[];pw7=[];pw8=[];
else
    ha=[];ax=[];
end






%% 1. COMPUTE APPROXIMATE PICK FROM STA/LTA PICKER
% Start estimations at <ppxIdx0>, but never before <ntap>
if ppxIdx0<ntap; k0 = int32(ntap);
else             k0 = int32(ppxIdx0);
end

amps_long  = max(abs(s(k0+1 : k0+tw1))) - abs(mean(s(k0+1 : k0+tw1)));
amps_short  = max(abs(s(k0+1 : k0+tw2))) - abs(mean(s(k0+1 : k0+tw1)));

k    = k0;
kmax = ns-2*tw2-1;
while ( (amps_short <amps_long *threshold) & (k<kmax) )
    
    k           = k+tw2;
    amps_short  = max(abs(s(k+1 : k+tw2))) - abs(mean(s(k0+1 : k0+tw1)));
    
    % Save values for plotting
    if (o_plot); kk    = [kk; k]; 
                 ratio = [ratio; amps_short /amps_long ];
    end
end




%% 2. OPTIMISE PICK
%  For each candidate pick, convolve noise- and signal-amplitudes with
%  weighting function and compute ratio between integrated weighted signal
%  amplitudes and integrated weighted noise amplitudes.

if ( (ns-k>sr) && (k>2*ntap) )   % If pick is not too late or too early

    
    % 2a. COPMUTE OPTIMISED PICK  . . . . . . . . . . . . . . . . . . . . . 
    
    % ------------------------------------------------
    % Noise and signal windows around candidate pick k
    %
    % sIdx                k               eIdx
    %          noise            signal
    %   | . . . . . . . . | . . . . . . . . |
    % ------------------------------------------------

    % Save trigger pick
    k1 = k;
    
    % Define initial window edges
    eIdx = k+signalWindow/dt-1;              % End   index of signal window
    sIdx = k-noiseWindow/dt;                 % Start index of noise  window
    
    % Define window edges for shifted picks
    nk_pre  = round(preShift /dt/nshift)+1;  % No. of candidates before pick
    nk_post = round(postShift/dt/nshift)+1;  % No. of candidates after pick
    
    kstart = k - nk_pre *nshift;
    kend   = k + nk_post*nshift;
    K      = kstart:nshift:kend;
    SIdx   = K-noiseWindow/dt;
    EIdx   = K+signalWindow/dt-1;

    %K    = K   (SIdx>ntap);         % Cr1. Only keep candidates for which noise 
    %EIdx = EIdx(SIdx>ntap);         % window starts after ntap samples
    %SIdx = SIdx(SIdx>ntap);
    K    = K   (SIdx>0);            % Cr2. Only keep candidates for which noise 
    EIdx = EIdx(SIdx>0);            % window starts after 0. With Cr1. the initial
    SIdx = SIdx(SIdx>0);            % pick can be as soon as <ntap>, but optimised
                                    % pick can only occur after
                                    % <ntap>+<noiseWindow> (?) ==> problem
                                    % if p-onset is short after signal start
    
    K    = K   (EIdx<ns);           % Throw out candidate picks for which 
    EIdx = EIdx(EIdx<ns);           % window ends after signal end
    SIdx = SIdx(EIdx<ns);
    
    
    % Choose and define weight funcitons 
    % Convolve signal with a weighting function that decays on either
    % side of the pick, e.g. a two-sided exponential
    %
    %                 ppx
    %
    %                 ..
    %                 []
    %               .:[]:_
    %             .: :[]: :-.
    %           .: : :[]: : :`._
    %         .: : : :[]: : : : :-._
    %  ____..: : : : :[]: : : : : : :-.____
    %  ____________________________________    
    
    
    % a. Noise   -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -
    nsNoise  = noiseWindow*sr+1;
    xn       = 0:nsNoise-1;
    
    if strcmp(noiseWtFct,'exp')
        lambda_n = log(wmax/wmin)*1/nsNoise;       % Exponential weight decay
        WNoise   = wmin*exp(lambda_n*xn)';
    elseif strcmp(noiseWtFct,'lin')
        WNoise = linspace(wmin,wmax,numel(xn))';   % Linear weight decay
    elseif strcmp(noiseWtFct,'1-exp')
        lambda_n = log(wmax-wmin)*1/nsNoise;       % 1-exp weight decay   
        WNoise   = fliplr(wmax - exp(lambda_n*xn))';
    end
    
    
    % b. Signal     -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  -  
    nsSignal = signalWindow*sr+1;
    xs       = 1:nsSignal;
    
    if strcmp(signalWtFct,'exp')
        lambda_s = log(wmin/wmax)*1/nsSignal;
        WSignal  = wmax*exp(lambda_s*xs)';
    elseif strcmp(signalWtFct,'lin')
        WSignal = linspace(wmax,wmin,numel(xs))';
    end
    % - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - - 
    
    
    % Loop over all pick candidates
    nk = numel(SIdx); 
    R  = zeros(nk,1);
    
    for ik = 1:nk;
        
        % Read window edges
        k    = K   (ik);
        eIdx = EIdx(ik);
        sIdx = SIdx(ik);
        
        % Compute noise amlitudes
        if (sIdx<ntap)
            sIdx = ntap;
            if (ik==1)
                fprintf(1,' note: pre-amplitudes window truncated for at least 1 candidate window, '); 
            end
        end
        sNoise   = s(sIdx:k);
        n        = numel(sNoise);
        wNoise   = WNoise(end-n+1:end);
        wtdNoise = wNoise.*abs(sNoise);
        fNoise   = cumsum(wtdNoise)*dt;
        
        % Compute signal amlitudes
        if (eIdx>ns)
            eIdx = numel(s);
            fprintf(1,' note: post-amplitudes window truncated,')
        end
        
        sSignal   = s(k+1:eIdx);
        n         = numel(sSignal);
        wSignal   = WSignal(1:n);
        wtdSignal = wSignal.*abs(sSignal);
        fSignal   = cumsum(wtdSignal)*dt;
        
        % Compute ratio / characteristic function
        R(ik) = fSignal(end)/fNoise(end);
        
        
        
        
        % 2b. ANIMATE PICK OPTIMISATION . . . . . . . . . . . . . . . . . .
        if o_animate
            
            % x-Vectors for plotting
            xn_plot= (sIdx:k)';
            xs_plot= (k+1:eIdx)';
            
            % boarders of plot
            sIdx_plot = SIdx(1) - 300;
            if (sIdx_plot<1); sIdx_plot=1; end
            eIdx_plot = EIdx(end) + 300;
            ymax = 1.1*max(abs(s(sIdx_plot:eIdx_plot)));
            
            % Plot window edges and candidate pick location over waveform
            subplot(ax)
            delete([l1,l2,p1])
            set(gca,'xlim',[sIdx_plot eIdx_plot],'fontSize',ftSize)
            l1 = line([sIdx sIdx],[-ymax ymax],'lineStyle','--','lineWidth',2,'color',[0 .4 0]);
            l2 = line([eIdx eIdx],[-ymax ymax],'lineStyle','--','lineWidth',2,'color',[0 .4 0]);
            p1 = plot(k,0,'xr','lineWidth',2,'markerSize',10);
            if (ik==nk); delete([l1,l2,p1]); end
            ylabel('Signal amplitude','fontSize',ftSize)
            %xlabel('Sample Number','fontSize',ftSize)
            
            % Plot weighting function
            subplot(s2)
            delete([pw1,pw2])
            set(gca,'xlim',[sIdx_plot eIdx_plot],'fontSize',ftSize)
            pw1 = plot(xn_plot,wNoise ,'.k');
            pw2 = plot(xs_plot,wSignal,'.r');
            ylabel('Weight','fontSize',ftSize)
            %xlabel('Sample Number','fontSize',ftSize)
            pause(.005)
            1+1;
            
            % Weighted samples
            subplot(s3)
            delete([pw3,pw4])
            set(gca,'xlim',[sIdx_plot eIdx_plot],'fontSize',ftSize)
            pw3 = plot(xn_plot,wtdNoise ,'.k');
            pw4 = plot(xs_plot,wtdSignal,'.r');
            ylabel('Weithed abs. amplitudes','fontSize',ftSize)
            %xlabel('Sample Number','fontSize',ftSize)
            
            % Integrals
            subplot(s4)
            delete([pw5,pw6,pw7,pw8])
            set(gca,'xlim',[sIdx_plot eIdx_plot],'fontSize',ftSize)
            pw5 = plot(xn_plot,fNoise ,'-k');
            pw6 = plot(xs_plot,fSignal,'-r');
            pw7 = plot(xn_plot(end),fNoise (end) ,'ok','markerFaceColor','y');
            pw8 = plot(xs_plot(end),fSignal(end) ,'ok','markerFaceColor','y');
            ylabel('Integrated weithed amplitudes','fontSize',ftSize)
            %xlabel('Sample Number','fontSize',ftSize)
            
            % Plot ratio
            subplot(s5)
            set(gca,'xlim',[sIdx_plot eIdx_plot],'ylim',[0 1.1*(max(R))],'fontSize',ftSize)
            plot(k,R(ik),'xr')
            ylabel('Ratio','fontSize',ftSize)
            xlabel('Sample Number','fontSize',ftSize)
            
            1+1;            
        end
    end
    
    if (nk>0)
        % Identify pick-index (k) with maximum SNR
        [R,idxMax] = max(R);
        k          = K   (idxMax);
        eIdx       = EIdx(idxMax);
        sIdx       = SIdx(idxMax);
        
        if o_animate
            
            subplot(ax)
            line([k k],[-ymax ymax],'color','r','lineWidth',2)
            
            subplot(s5)
            plot(k,R,'ok','markerFaceColor','y')
            
        end
        
        signalAmps  = s(k:eIdx);
        signalPower = 1/signalWindow*sum(signalAmps.^2);
        noiseAmps   = s(sIdx:k-1);
        noisePower  = 1/noiseWindow *sum(noiseAmps .^2);
        snr         = signalPower/noisePower;
    else
        fprintf(1,'No optimisation possible, keeping STA/LTA pick index\n')
    end
    
else
    % No pick found.
    k   = [];
    snr = [];
end




%% 3. PLOT FINAL PICK
if ( (o_plot) && (~isempty(k)) )
    
    figure(311);
    whitebg('w')
    
    t  = dt:dt:ns*dt;
    
    sIdxPlot = sIdx-1/dt; if sIdxPlot<1;  sIdxPlot=1;  end
    eIdxPlot = eIdx+2/dt; if eIdxPlot>ns; eIdxPlot=ns; end
    
    
    % Waveform with pick, zoomed in on pick
    subplot(5,1,1:2); hold on
    h1=plot(t,s);

    ymax = 1.5*amps_short ;
    set(gca,'xlim',[t(sIdxPlot) t(eIdxPlot)],'ylim',[-ymax ymax],'fontSize',ftSize)
    
    noise = prctile(noiseAmps,84.1);
    
    h4 = plot(t(k1),amps_short ,'pk','markerFaceColor','y','markerSize',14);
    h5 = line([t(k)  t(k)] ,[-ymax   ymax ]                             ,'color','r','lineWidth',2);
    h2 = line([t(k0) t(ns)],[ noise  noise]                             ,'color',[0.8 0.8 0.8]);
         line([t(k0) t(ns)],[-noise -noise]                             ,'color',[0.8 0.8 0.8])
    h3 = line([t(k0) t(ns)],[ amps_long *threshold  amps_long*threshold],'color','k');
         line([t(k0) t(ns)],[-amps_long *threshold -amps_long*threshold],'color','k')
    l1 = legend([h1 h2 h3 h4 h5], 'filtered signal','noise amplitudes (1\sigma)', ...
        'pick threshold','STA/LTA pick','optimised pick');
         line([t(sIdx+1) t(sIdx+1)],[-ymax ymax],'color',[0 0.4 0],'linestyle','--')
         line([t(eIdx)   t(eIdx)]  ,[-ymax ymax],'color',[0 0.4 0],'linestyle','--')
    set(l1,'fontSize',ftSize-3,'location','northEast')
    title(['SNR = ',num2str(snr,'%5.0f')],'fontSize',ftSize)
    ylabel('Signal amplitudes','fontSize',ftSize)
    
    % STA/LTA ratio
    subplot(5,1,3); hold on
    plot(t(kk)     ,ratio     ,'ok','markerFaceColor','y')
    plot(t(kk(end)),ratio(end),'ok','markerFaceColor','y')
    line([t(1) t(ns)],[threshold threshold],'color','k')
    set(gca,'xlim',[t(sIdxPlot) t(eIdxPlot)],'fontSize',ftSize)
    ylabel('STA/LTA','fontSize',ftSize)
    
    
    % Waveform with pick, entire waveform
    subplot(5,1,4:5); hold on
    plot(t,s)
    l6 = line([t(k) t(k)],[-max(abs(s)) max(abs(s))],'color','r','lineWidth',2);
    l7 = line([t(kk(1)) t(kk(1))],[-max(abs(s)) max(abs(s))],'lineStyle',':','color','r','lineWidth',2);
    xlabel('Time since waveform start [sec]','fontSize',ftSize);
    ylabel('Signal amplitudes','fontSize',ftSize);
    set(gca,'fontSize',ftSize)
    hlgd = legend([l6,l7],'optimised pick','earliest pick candidate');
    set(hlgd,'fontSize',ftSize)
    
elseif ( (o_plot) && (isempty(k)) )

    subplot(5,1,2:4); hold on
    plot(s)
    title('SBPx: No pick found','fontSize',ftSize)
end