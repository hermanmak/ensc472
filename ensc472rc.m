%%
% Mobilit-E
%%

%connect to phone and get accel data
clc
clear
pause(0.5);

%% Global Variables
help_email = 'megan_bruschetta@hotmail.ca';
help_email3 = 'leandrar@sfu.ca';
help_email2 = 'stever@sfu.ca';

mins_to_run = 5;
graph_size = 200; %10 per second
data = zeros(graph_size,1);
gravity_constant = 9.89;
average_step_time = 0;
gait_threshold = 0;
gait_on = 0;
fall_detect = 0;

%% SETUP
m = mobiledev;
m.AccelerationSensorEnabled = 1;
%m.OrientationSensorEnabled = 1;
m.Logging = 1;

%% Initialize data for rolling plot
figure(1)
p = plot(data);
axis([0 graph_size -40 40]);
title('Step Force vs Time');

%% Wait for 3 Seconds
pause(3)
disp('Start Now'); %Start Walking
tic

%%
while (toc < 60*mins_to_run && fall_detect == 0)%run for X mins
    %get new z coordinates
    [acceldata,time] = accellog(m);
    if length(acceldata) > graph_size
        mag = sqrt(acceldata(end-graph_size-1:end,1).^2 + acceldata(end-graph_size-1:end,2).^2 + acceldata(end-graph_size-1:end,3).^2)-gravity_constant;
        data = mag(end-graph_size-1:end);
        curtimes = time(end-graph_size-1:end);
        
        new_data = mag(end-80-1:end);
        new_times = time(end-80-1:end);
        
        minPeakHeight = std(data);
        [pks, locs] = findpeaks(new_data, 'MINPEAKHEIGHT', minPeakHeight);
        numSteps = numel(pks);
        
        %% Detect Falls   
        for j = 1:length(pks)
            if pks(j) > 23
                fall_detect = 1;
                disp('FALL DETECTED');
                mailer(help_email);
                mailer(help_email2);
                mailer(help_email3);
            end
        end
        %%END DETECT FALLS
        
        step_time = length(pks)-1;
        for i = 1:length(pks)-1
            step_time(i) = time(locs(i+1))-time(locs(i));
        end
        current_average_step_time = mean(step_time);
        
        if abs(current_average_step_time - average_step_time) > 0.40*average_step_time
            gait_threshold = gait_threshold + 1;
            if gait_threshold > 40
                current_average_step_time
                gait_on = 1;
                gait_threshold = 0;
                disp('GAIT DETECTED, PLEASE FIX, pausing 20 seconds!');
                pause(20);
            end
        else
            if gait_on ~= 0
                disp('FINE NOW');
            end
            gait_threshold = 0;
            gait_on = 0;
            average_step_time = (average_step_time*7 + current_average_step_time)/8;
        end
        
    elseif length(acceldata) == 190
        mag = sqrt(acceldata(:,1).^2 + acceldata(:,2).^2 + acceldata(:,3).^2)-gravity_constant;
        data(1:length(acceldata)) = mag;
        
        minPeakHeight = std(data);
        [pks, locs] = findpeaks(data, 'MINPEAKHEIGHT', minPeakHeight);
        numSteps = numel(pks);
        
        step_time = length(pks)-1;
        if average_step_time == 0
            for i = 1:length(pks)-1
                step_time(i) = time(locs(i+1))-time(locs(i));
            end
            average_step_time = mean(step_time);
        end
    else
        mag = sqrt(acceldata(:,1).^2 + acceldata(:,2).^2 + acceldata(:,3).^2)-gravity_constant;
        mean(mag)
        data(1:length(acceldata)) = mag;
    end
    
    % redraw plot
    p.YData = data;
    drawnow
end

disp('SESSION ENDED');
    
