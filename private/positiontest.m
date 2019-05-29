function [loc_x, loc_y] = positiontest(delta_t,num_sensor, vel_sq)
% calculate the position with the least square method
% the formular is x = (transpose(A)*A)\(transpose(A)*b)
% read the position of sensor
switch num_sensor 
    case 6
        SensorPosition = [0, 505,    550, -1650,   -1650, 5; ...
                          0, 1482.5, 82.5, 1552.5, -2.5,  1555];

    case 4
        SensorPosition = [0, -1650,  -1650, 5; ...
                          0,  1552.5,-2.5,  1555];
end

% prepare for calculation
Coef_a = SensorPosition(1,1) - SensorPosition(1,:); % coefficient a, calculate from a_i =x_1 -x_i
Coef_b = SensorPosition(2,1) - SensorPosition(2,:); % coefficient a, calculate from b_i =y_1 -y_i
Coef_e = SensorPosition(1,1).^2 + SensorPosition(2,1).^2 - (SensorPosition(1,:).^2 + SensorPosition(2,:).^2);


loc_x=[];
loc_y=[];


switch num_sensor
    case 6
        deltaT = [delta_t(2),delta_t(3),delta_t(4),delta_t(5),delta_t(6),delta_t(1)];
    case 4
        deltaT = [delta_t(2),delta_t(5),delta_t(6),delta_t(1)];
end

 
Matr_A1 = 2*(Coef_a(2)/deltaT(2)-Coef_a(3:end)./deltaT(3:end));
Matr_A2 = 2*(Coef_b(2)/deltaT(2)-Coef_b(3:end)./deltaT(3:end));
Matr_b = Coef_e(2)/deltaT(2)-Coef_e(3:end)./deltaT(3:end) + (deltaT(2)-deltaT(3:end))*vel_sq; 
A = horzcat(Matr_A1',Matr_A2'); 
b = Matr_b';
A_transpose = A.';
A_least = A_transpose*A;
b_least = A_transpose*b;
loc_xy= A_least\b_least;
loc_x = loc_xy(1,1);
loc_y = loc_xy(2,1);

figure
scatter(SensorPosition(1,:),SensorPosition(2,:))
hold on
scatter(loc_x,loc_y)
end


