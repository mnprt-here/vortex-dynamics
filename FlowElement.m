classdef FlowElement
    properties
        position
        direction
        strength
        npos
        tpos
        type
        movable
    end
    
    methods
        function obj = FlowElement(position, direction, strength, type, movable)
            if nargin < 5
                error('Not enough arguments to the FlowElement');
            end
            obj.position = position;
            obj.direction = direction;
            obj.strength = strength;
            obj.type = type;
            obj.movable = movable;
            
            obj.elementList(obj);
        end
    end
    methods (Static)
        function list = elementList(obj)
            persistent element_list;
            if nargin
                element_list = [element_list; obj];
            end
            list = element_list;
        end
    end
end
