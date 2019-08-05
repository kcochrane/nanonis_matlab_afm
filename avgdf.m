%--average dark curves and light on curves in tedious, non-generalizable way
darkz=Z_Spec.y010.Z-min(Z_Spec.y010.Z);
darkavdf=(Z_Spec.y010.df+Z_Spec.y011.df)/2;

lightz=Z_Spec.y012.Z-min(Z_Spec.y010.Z);
lightavdf=(Z_Spec.y012.df+Z_Spec.y013.df+Z_Spec.y014.df)/3;

%--plot averages
figure;
plot(darkz,darkavdf);
hold on;
plot(lightz,lightavdf);

%--take difference between dark and light on
lightdarkdiff=lightavdf-darkavdf;
figure;
plot(darkz,lightdarkdiff);
hold on;

%--fit setup: failed due to precision

% fitind=find(darkz>1.32e-8);
% astart=0.6e-8;
% bstart=6;
% cstart=1e-8;
% startfit=-(astart./(darkz(fitind)-cstart)).^(bstart);
% plot(darkz(fitind),startfit,'r');
% hold on;
% limits=fitoptions('Method','NonlinearLeastSquares',...
%                'Lower',[0,1,0.1e-8],...
%                'Upper',[1e-6,9,1.32e-8],...
%                'Startpoint',[astart bstart cstart]);
% fitinvpower=fittype(@(a,b,c,x) -(a./(x-c)).^(b),'options',limits);
% difffit=fit(darkz(fitind),lightdarkdiff(fitind),fitinvpower)
% plot(darkz(fitind),difffit);

%--fit setup: try converting to nm
darkz=darkz*1e9;
fitind=find(darkz>13.2);
astart=6.;
bstart=6;
cstart=9.;
dstart=.65;
startfit=dstart-(astart./(darkz(fitind)-cstart)).^(bstart); %to plot starting condition
figure;
plot(darkz(fitind),lightdarkdiff(fitind));
hold on;
plot(darkz(fitind),startfit,'k');

%--set up function and fit options including lower/upper bounds
limits=fitoptions('Method','NonlinearLeastSquares',...
               'Lower',[0.1,1,2,.001],...
               'Upper',[10.,12,13,10.],...
               'Startpoint',[astart bstart cstart dstart]);
fitinvpower=fittype(@(a,b,c,d,x) d-(a./(x-c)).^(b),'options',limits); %defines fit func
difffit=fit(darkz(fitind),lightdarkdiff(fitind),fitinvpower)
plot(difffit);
%%
figure;
plot(darkz,lightdarkdiff);
hold on;
plot(difffit);
figure
plot(difffit)

%%

z_attractive=10^9*Z_dark_1(fitind);
df_attractive_diff=lightdarkdiff(fitind);
