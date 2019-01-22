clear; close all; clc;
% Update the global plot properties
SetFigureDefaults(8,8);
% Plot-axis size and ticks
size_x = [-5 5];
size_y = [-5 5];
ticks_x = [-5 0 5];
ticks_y = [-5 0 5];

clear FlowElement;

% FlowElement(position, direction, strength, type, movable);
% position  = [x_coord, y_coord]
% direction = 
%         1 = counter-clockwise circulation (BLUE)  || Source (CYAN)
%        -1 = clockwise circulation (RED)           || Sink (MAGENTA)
% strength  = Circulation                           || Source
% type      = 'vortex'(RED/BLUE) || 'tracer'(GREEN) || 'source'(CYAN/MAGENTA)
% movable   = 
%      true = if the element is allowed to feel the flow
%     false = static element

FlowElement([-1 0], 1, 2, 'source', false);
FlowElement([1 0], 1, 2, 'source', false);
FlowElement([0 1], 1, 2, 'source', false);
FlowElement([0 -1], 1, 2, 'source', false);
FlowElement([0 0], -1, 2, 'source', false);
FlowElement([-2.5 0.1], 1, 1, 'vortex', true);
FlowElement([-2.5 -0.1], -1, 1, 'vortex', true);
FlowElement([-3 0.50], -1, 1, 'tracer', true);
FlowElement([-3 0.25], -1, 1, 'tracer', true);
FlowElement([-3 -0.25], -1, 1, 'tracer', true);
FlowElement([-3 -0.50], -1, 1, 'tracer', true);

% Add background directional flow: uniform_flow(x_dir, y_dir)
uniform_flow = [1 0];

element_list = FlowElement.elementList;

% Smaller the dt, better the approximations, slower the code
dt = 0.001; 
% Distance limit after which elements gets too close
epsilon = 0.01;

for t = 1:10000
    fprintf('t = %d\n',t);
    for v1 = 1:length(element_list)
        if (element_list(v1).movable)
            vel = [0 0];
            pos1 = element_list(v1).position;
            for v2 = 1:length(element_list)
                if (v1 == v2)
                    continue;
                end
                pos2 = element_list(v2).position;
                dist = norm(pos1 - pos2, 2);
                if (dist <= epsilon)
                    continue;
                end
                if (strcmp(element_list(v2).type,'vortex'))
                    v = -element_list(v2).direction * element_list(v2).strength / (2*pi*dist);
                    vel(1) = vel(1) + v*(pos1(2)-pos2(2))/dist;
                    vel(2) = vel(2) + v*(pos2(1)-pos1(1))/dist;
                elseif (strcmp(element_list(v2).type,'source'))
                    v = -element_list(v2).direction * element_list(v2).strength / (2*pi*dist);
                    vel(1) = vel(1) + v*(pos2(1)-pos1(1))/dist;
                    vel(2) = vel(2) + v*(pos2(2)-pos1(2))/dist;
                else
                    v = 0;
                end
            end
            element_list(v1).npos = pos1 + (vel + uniform_flow)*dt;
        else
            element_list(v1).npos = element_list(v1).position;
        end
    end
    
    for v1 = 1:length(element_list)
        element_list(v1).position = element_list(v1).npos;
        element_list(v1).tpos = [element_list(v1).tpos; element_list(v1).npos];
    end
end

for i = 1:100:t
    fprintf('t = %d\n',i);
    for v1 = 1:length(element_list)
        pos = element_list(v1).tpos(i,:);
        if (strcmp(element_list(v1).type,'vortex'))
            if (element_list(v1).direction == 1)
                plot(pos(1), pos(2), 'b.', 'markersize', 10*element_list(v1).strength+10); hold on;
            else
                plot(pos(1), pos(2), 'r.', 'markersize', 10*element_list(v1).strength+10); hold on;
            end
        elseif (strcmp(element_list(v1).type,'source'))
            if (element_list(v1).direction == 1)
                plot(pos(1), pos(2), 'c.', 'markersize', 10*element_list(v1).strength+10); hold on;
            else
                plot(pos(1), pos(2), 'm.', 'markersize', 10*element_list(v1).strength+10); hold on;
            end
        elseif (strcmp(element_list(v1).type,'tracer'))
            plot(pos(1), pos(2), 'g.', 'markersize', 10*element_list(v1).strength+10); hold on;
        end
        tpos = element_list(v1).tpos(1:i,:);
        plot(tpos(:,1),tpos(:,2),'k-','linewidth',1);
    end
    hold off;
    axis([size_x size_y]);
    yticks(ticks_x);
    xticks(ticks_y);
    drawnow;
end
