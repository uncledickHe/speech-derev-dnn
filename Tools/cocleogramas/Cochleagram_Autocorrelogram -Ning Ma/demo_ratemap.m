function demo_ratemap

% Load the waveform "Seven One Zero"
[x, fs] = wavread('t29_lwwj2n_m17_lgwe7s.wav');
xticks = [0.3:0.3:2];
xticklabels = cell(1,length(xticks));
for i=1:length(xticks); xticklabels{i} = num2str(xticks(i)); end;


% Plot the waveform
figure(1)
subplot(3,1,1);
plot(x);
title('Waveform', 'FontSize', 11);
nsamples = length(x);
set(gca,'XLim',[1 nsamples]);
set(gca,'XTick',xticks*fs);
set(gca,'XTickLabel', {}, 'FontSize', 11);
set(gca,'YTick',[0]);
set(gca,'YTickLabel',{'0'}, 'FontSize', 11);


% Generate ratemap representation of the waveform
% type "help makeRatemap_c" for detailed help
lowcf = 50; % Hz
highcf = 8000; % Hz
nchans = 64;
ratemap = makeRateMap_c(x,fs,lowcf,highcf,nchans,10,8,'log');


% Plot the ratemap
subplot(3,1,2:3);
imagesc(ratemap);
axis xy;
title('Ratemap', 'FontSize', 11);
set(gca,'XTick',xticks*100+0.5);
set(gca,'XTickLabel', xticklabels, 'FontSize', 11);
xlabel('Time (ms)', 'FontSize', 11);
set(gca,'YTick',[1,floor(nchans/3),floor(nchans*2/3),nchans]);
set(gca,'YTickLabel',{'50', '588', '2295','8000'}, 'FontSize', 11);
ylabel('Centre Frequency (Hz)', 'FontSize', 11);

%print -depsc2 ratemap.eps