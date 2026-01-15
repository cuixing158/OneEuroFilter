classdef LowPassFilter < matlab.mixin.SetGet
    % Brief: Implements a simple first-order low-pass filter.
    % Details:
    %    This class provides a discrete-time low-pass filter based on the
    %    formula: y[n] = alpha * x[n] + (1 - alpha) * y[n-1]. It is a core
    %    component for more complex filters like the OneEuroFilter.
    %
    % Syntax:
    %    obj = LowPassFilter(alpha)
    %    obj = LowPassFilter(alpha, initval)
    %    result = obj.filter(value)
    %
    % Inputs:
    %    alpha   - (1,1) double, Smoothing factor, must be in (0, 1].
    %    initval - (1,1) double, Optional initial value for the filter's state. Defaults to 0.0.
    %    value   - (1,1) double, The raw input value to be filtered.
    %
    % Outputs:
    %    obj     - The constructed LowPassFilter object.
    %    result  - (1,1) double, The filtered output value.
    %
    % Example:
    %    lpf = LowPassFilter(0.5, 1.0);
    %    filtered_val = lpf.filter(2.0); 
    %
    % See also: OneEuroFilter

    % Author:                          cuixingxing
    % Email:                           cuixingxing150@gmail.com
    % Created:                         13-Jan-2026 17:27:23
    % Version history revision notes:
    %                                  None
    % Implementation In Matlab R2026a
    % Copyright © 2026 xingxingcui.All Rights Reserved.
    %
    properties (SetAccess = protected)
        LastRawValue double   % last raw value
        State double          % last filtered value
        Alpha double          % alpha
        Initialized logical = false
    end

    methods
        function obj = LowPassFilter(alpha, initval)
            arguments
                alpha (1,1) double
                initval (1,1) double = 0.0
            end
            obj.LastRawValue = initval;
            obj.State = initval;
            obj.Alpha = alpha;
        end

        function result = filter(obj, value)
            arguments
                obj
                value (1,1) double
            end

            if obj.Initialized
                result = obj.Alpha * value + (1.0 - obj.Alpha) * obj.State;
            else
                result = value;
                obj.Initialized = true;
            end
            obj.LastRawValue = value;
            obj.State = result;
        end

        function result = filterWithAlpha(obj, value, alpha)
            arguments
                obj
                value (1,1) double
                alpha (1,1) double
            end
            obj.Alpha = alpha;
            result = obj.filter(value);
        end

        function tf = hasLastRawValue(obj)
            tf = obj.Initialized;
        end

        function v = lastRawValue(obj)
            v = obj.LastRawValue;
        end

        function v = lastFilteredValue(obj)
            v = obj.State;
        end

        function set.Alpha(obj, alpha)
            if alpha <= 0.0 || alpha > 1.0
                error('alpha should be in (0, 1]');
            end
            obj.Alpha = alpha;
        end

    end
end
