%afm_bias_spec_grid_read.m

%Katherine Cochrane
%March 4, 2015

%reads in three dimentional grid bias spectroscopy .3ds nanonis files using the nanonis
%written load3ds.m script. If you dont have this it can be found in the
%nanonis help files

%here I asusme you have taken a forward and backward bias sweep. also that
%you have saved 5 different channels. in this case: Z, phase, amplitude,
%freq shift and excitation. for analysis I really only care about Z and
%frequency shift. The data loads in a 10 column matrix representing forward
%and backwards scans of all these channels. So I care about columns 1 (Z
%fwd),4 (Freq fwd),6 (Z back) and 9 (freq back). These numbers 1,4,6 and 9
%can be adjusted for different scans. 

%another assumption. for your data collection you have started in the
%bottom left corner and gone left to right then bottom up in bias sweep
%collection so if you had a 3x3 matrix the order would look like this:
%[6 7 8]
%[3 4 5]
%[0 1 2]
% your Z,x,y, and df values will all be correlated in the matrix, but this
% is so you can make it match/overlay with previous topography scans

%I try to keep the parameters as general as possible so this can be applied
%to all grids regardless of grid size, bias starting and ending values,
%number of points taken within a bias range, etc. when assumptions are made
%for a specific grid I will try to make note. 

filename='Grid Spectroscopy_dark009.3ds';
%insert file name here

fileroot='pent_grid';
%you can change the name of the data to something else if it is long and
%unmanageable

%%
pt_index=0;
[Grid.(fileroot).header, Grid.(fileroot).data, par]=load3ds(filename, pt_index);
%first I load the data corresponding to the very first point in the grid
%for the purpose of extracting the grid parameters in order to set up the
%matricies for the data.

low_bias=par(1);
high_bias=par(2);
points=Grid.(fileroot).header.points;
bias_step=(high_bias-low_bias)./(points-1);

Bias=(low_bias:bias_step:high_bias);
%vector corresponding to the bias sweep, min to max in the correct
%increments

grid_dim_x=Grid.(fileroot).header.grid_dim(1);
grid_dim_y=Grid.(fileroot).header.grid_dim(2);
%get dimenstions of grid

%create matricies corresponding to the data you extract:
Z_fwd=zeros(grid_dim_x,grid_dim_y,points);
Z_bkwd=zeros(grid_dim_x,grid_dim_y,points);
freq_fwd=zeros(grid_dim_x,grid_dim_y,points);
freq_bkwd=zeros(grid_dim_x,grid_dim_y,points);
location_x=zeros(grid_dim_x,grid_dim_y);
location_y=zeros(grid_dim_x,grid_dim_y);

for ii=1:grid_dim_y

for jj=1:grid_dim_x
    
    pt_index_start=(ii-1).*grid_dim_x;
    pt_index_end=ii.*grid_dim_x-1;
    pt_index_vector=pt_index_start:1:pt_index_end;
    pt_index=pt_index_vector(jj);
    [Grid.(fileroot).header, Grid.(fileroot).data, par]=load3ds(filename, pt_index);
    Z_fwd(ii,jj,:)=Grid.(fileroot).data(:,1);
    Z_bkwd(ii,jj,:)=Grid.(fileroot).data(:,6);
    freq_fwd(ii,jj,:)=Grid.(fileroot).data(:,4);
    freq_bkwd(ii,jj,:)=Grid.(fileroot).data(:,9);
    location_x(ii,jj)=par(3);
    location_y(ii,jj)=par(4);
    
end

end
length_x=Grid.(fileroot).header.grid_settings(3);
length_y=Grid.(fileroot).header.grid_settings(4);
points_x=grid_dim_x;
points_y=grid_dim_y;
x_step=length_x./(points_x-1);
y_step=length_y./(points_y-1);
xx=0:x_step:length_x;
yy=0:x_step:length_y;
%to generate corresponding x and y vectors

%%
%%generate a map of the frequency shift at a given bias
V_input=-2;

Bias_V=Bias;
n_points=length(Bias_V);
delta_Bias_V=(Bias_V(n_points)-Bias_V(1))/(n_points-1);
V_index=round((V_input-Bias_V(1))/delta_Bias_V)+1;

figname=strcat('Frequency shift at bias=',...
    num2str(Bias_V(1)+delta_Bias_V*(V_index-1)),' V');
figure ('Name', figname);
imagesc(xx, yy, freq_fwd(:,:,V_index));
colormap(gray)
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
colorbar;

%%
%make movie of bias spectroscopy as a function of frequency shift
for k=1:3

    V_index=k;
    V_input=Bias_V(k);
    
figname=strcat('Frequency shift at bias=',...
    num2str(Bias_V(1)+delta_Bias_V*(V_index-1)),' V');
h=figure ('Name', figname);
subplot(12,10,[2:1:9]);

hold on
   xlabel('Bias [V]');
   yL = ylim;
     line([V_input V_input], yL, 'LineWidth',3);  %x-axis
     axis([low_bias high_bias 0 1])
     set(gca,'XTick',[low_bias:0.5:high_bias])
     set(gca,'YTick',[2])
% 
% 
 subplot(12,10,[21:1:120])
imagesc(xx, yy, freq_fwd(:,:,V_index));
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
colorbar;
colormap(gray);

bias_sign=sign(Bias_V(k));
if bias_sign == 1;
filename=strcat(num2str(abs(Bias_V(1)+delta_Bias_V*(V_index-1))),' V.tiff');
print(h,'-dtiff',filename);
else if bias_sign == -1;
        filename=strcat('neg ',num2str(abs(Bias_V(1)+delta_Bias_V*(V_index-1))),' V.tiff');
print(h,'-dtiff',filename);
    end
close

end
end

%%

%average forward and backward data
freq_ave_index=zeros(points,1);
freq_ave=zeros(grid_dim_x,grid_dim_y,points);
for ii=1:grid_dim_x
    for jj=1:grid_dim_y
        
       freq_fwd_index=freq_fwd(ii,jj,:);
       freq_fwd_index=permute(freq_fwd_index, [3 1 2]);
       freq_bkwd_index=freq_bkwd(ii,jj,:);
       freq_bkwd_index=permute(freq_bkwd_index, [3 1 2]);
       for kk=1:points
           freq_ave_index(kk)=(freq_fwd(ii,jj,kk)+freq_bkwd(ii,jj,kk))./2;
       end
       
       freq_ave(ii,jj,:)=freq_ave_index;
      
    end
end


%% plot plane subtracted data (need PlaneSubtraction.m)

%Plane subtraction
%enter points below (x1,y1), (x2,y2), (x3,y3)

x1=2.45e-7;
y1=0.35e-7;
x2=2.45e-7;
y2=1.35e-7;
x3=0.5e-7;
y3=2.3e-7;

[Z_plane]=PlaneSubstraction (Z_fwd(:,:,1), xx, yy, x1, y1, x2, y2, x3, y3);



clims=[-7e-9 9e-9];
figname='Plane corrected Topography';
figure ('Name', figname);
imagesc(xx, yy, Z_plane, clims);
colormap(gray)
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
colorbar;

