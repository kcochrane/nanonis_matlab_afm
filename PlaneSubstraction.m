function [map_output]=PlaneSubstraction (map_input, x_var, y_var, x1, y1, x2,y2,x3,y3)
%Given the points (x1, y1), (x2, y2) and (x3, y3) defining a plane,
%extracts the plane-corrected map map_output.

map_output=map_input;

nx=length(x_var);
ny=length(y_var);

delta_x=(x_var(nx)-x_var(1))/(nx-1);
delta_y=(y_var(ny)-y_var(1))/(ny-1);

i1=round(((x1-x_var(1))/delta_x)+1);
i2=round(((x2-x_var(1))/delta_x)+1);
i3=round(((x3-x_var(1))/delta_x)+1);

j1=round(((y1-y_var(1))/delta_y)+1);
j2=round(((y2-y_var(1))/delta_y)+1);
j3=round(((y3-y_var(1))/delta_y)+1);

z1=map_input(i1, j1);
z2=map_input(i2, j2);
z3=map_input(i3, j3);

A=[x2-x1;y2-y1;z2-z1];
B=[x3-x1;y3-y1;z3-z1];
normal=cross(A,B);

for i=1:nx
    for j=1:ny
        z_plane=((-normal(1)*(x_var(i)-x1)-normal(2)*(y_var(j)-y1))/normal(3))+z1;
        map_output(i,j)=map_input(i,j)-z_plane;
    end
end

figname='Plane correction';
figure ('Name', figname);
subplot(1,2,1);
imagesc(x_var, y_var, map_input');
title('Original (non-corrected)');
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
%zlim([min(min(I_A_map)) max(max(I_A_map))]);
colorbar;

subplot(1,2,2);
imagesc(x_var, y_var, map_output');
title('Plane corrected');
axis xy;
axis image;
ylabel('y [m]');
xlabel('x [m]');
%zlim([0,0.2]);
colorbar;

end