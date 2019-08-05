%load all dat data


added_path = [pwd,'/Z_Spectroscopy_KBr_Si_tip']; %change to: added_path = '/path' for your required path
addpath(added_path);

directory=added_path;
start_row=139;
end_row=394;

f=dir([directory,'/*.dat']);
ZSpec = struct;
for i=1:length(f)
 p = fullfile(directory,f(i).name);
 fileroot = [f(i).name(end-7:end-4)];
 [ZSpec.(fileroot).Z, ZSpec.(fileroot).df]  = importfile1(p,start_row,end_row);
end

%%

f=[0:5];

figure;
for i=1:length(f);
 fileroot = ['y01',num2str(f(i))];
 plot(ZSpec.(fileroot).Z, ZSpec.(fileroot).df,'DisplayName',fileroot)
 hold all
end
xlabel('Z');
ylabel('Frequency Shift')
%%
Z_dark_1=ZSpec.y010.Z;
df_dark_1=ZSpec.y010.df;

Z_dark_2=ZSpec.y011.Z;
df_dark_2=ZSpec.y011.df;

Z_light_1=ZSpec.y012.Z;
df_light_1=ZSpec.y012.df;

Z_light_2=ZSpec.y013.Z;
df_light_2=ZSpec.y013.df;

Z_light_3=ZSpec.y014.Z;
df_light_3=ZSpec.y014.df;

Z_dark_3=ZSpec.y015.Z;
df_dark_3=ZSpec.y015.df;




