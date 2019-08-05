%twoD_grid_read.m
%open subfolder of grid data and load all data

added_path = [pwd,'/Grid_analysis_2']; %change to: added_path = '/path' for your required path
addpath(added_path);

directory=added_path;

f=dir(added_path);
%f=dir([added_path,'\*.3ds']);
Grid= struct;
for i=4:length(f)
 p = fullfile(directory,f(i).name);
 fileroot = ['wv',f(i).name(end-11:end-4)];
     for j=0:23;
         number = sprintf('nr%02d',j);[Grid.(fileroot).header, Grid.(fileroot).data.(number), par]  = load3ds(p, j);
     end
end

%starting at 3 because i couldnt get the .3ds thing to work and the frist
%two things in the subfolder are for some reason a "." then a ".."

%saved as mat file light_experiment_2dgrids.mat

%%
%get data into nicer form

low_bias=Grid_raw.par(1);
high_bias=par(2);
points=Grid.(fileroot).header.points;
bias_step=(high_bias-low_bias)./(points-1);

Bias=(low_bias:bias_step:high_bias);

%% get maximum of bias for all curves

directory=added_path;

bias = [-3:6/399:3]';
i = 3;
for i=4:length(f)
 p = fullfile(directory,f(i).name);
 fileroot = ['wv',f(i).name(end-11:end-4)];
     for j=0:23;
         number = sprintf('nr%02d',j);
            [Grid.(fileroot).p,S] = polyfit(bias,Grid.(fileroot).data.(number)(:,4),2);
            y1 = polyval(Grid.(fileroot).p,bias);
            [a,b] = max(y1);
            ii = j+1;
            Grid.(fileroot).max(ii)= bias(b);
     end
end

%%
figure;
n = 1;
for i=4:length(f)
 fileroot = ['wv',f(i).name(end-11:end-4)];
            plot(Grid.(fileroot).max(:),'-','MarkerSize',5);
            hold all;
             l{n} = fileroot;
             n = n+1;
end
legend(l);