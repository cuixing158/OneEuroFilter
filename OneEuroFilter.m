classdef OneEuroFilter < matlab.mixin.SetGet
    % Brief: A 1D real-time signal filter that balances jitter reduction and lag.
    % Details:
    %    This is a MATLAB implementation of the One-Euro Filter algorithm. It uses
    %    two low-pass filters: one for the signal and one for its derivative. The
    %    cutoff frequency of the signal filter is adapted based on the signal's
    %    speed, reducing lag during fast movements and increasing smoothing during
    %    slow movements or pauses. This makes it ideal for filtering noisy
    %    real-time data from sensors or user input without introducing noticeable delay.
    %
    % Syntax:
    %    obj = OneEuroFilter(freq)
    %    obj = OneEuroFilter(freq, 'mincutoff', mc, 'beta_', b, 'dcutoff', dc)
    %    value_hat = obj.filter(value)
    %    value_hat = obj.filter(value, timestamp)
    %
    % Inputs:
    %    freq      - (1,1) double, Sampling frequency of the signal in Hz (>0).
    %    mincutoff - (1,1) double, Name-Value. Minimum cutoff frequency in Hz (>0). Lower values increase smoothing.
    %    beta_     - (1,1) double, Name-Value. Speed coefficient (>=0). Higher values reduce lag.
    %    dcutoff   - (1,1) double, Name-Value. Cutoff frequency for the derivative filter in Hz (>0).
    %    value     - (1,1) double, The raw input value to be filtered.
    %    timestamp - (1,1) double, Optional. The timestamp of the value in seconds, used to dynamically update the frequency.
    %
    % Outputs:
    %    obj       - The constructed OneEuroFilter object.
    %    value_hat - (1,1) double, The filtered output value.
    %
    % Example:
    %    % Setup filter for a 120Hz signal
    %    one_euro = OneEuroFilter(120, 'mincutoff', 1.0, 'beta_', 0.1);
    %    t = 0:1/120:2;
    %    noisy_signal = sin(2*pi*t) + 0.2*randn(size(t));
    %    filtered_signal = arrayfun(@(v, ts) one_euro.filter(v, ts), noisy_signal, t);
    %    plot(t, noisy_signal, 'r-', t, filtered_signal, 'b-');
    %    legend('Noisy', 'Filtered');
    %
    % See also: LowPassFilter

    % Author:                          cuixingxing
    % Email:                           cuixingxing150@gmail.com
    % Created:                         13-Jan-2026 17:27:23
    % Version history revision notes:
    %                                  None
    % Implementation In Matlab R2026a
    % Copyright © 2026 xingxingcui.All Rights Reserved.
    %
    properties (Constant)
        UndefinedTime = -1.0
    end

    properties (SetAccess = protected)
        Freq double
        MinCutOff double
        Beta double
        DCutOff double

        X LowPassFilter
        dX LowPassFilter

        LastTime double
    end

    methods
        function obj = OneEuroFilter(freq, options)
            arguments
                freq (1,1) double
                options.mincutoff (1,1) double = 1.0
                options.beta_ (1,1) double = 0.0
                options.dcutoff (1,1) double = 1.0
            end

            obj.Freq = freq;
            obj.MinCutOff = options.mincutoff;
            obj.Beta = options.beta_;
            obj.DCutOff = options.dcutoff;

            obj.X  = LowPassFilter(obj.alpha(obj.MinCutOff));
            obj.dX = LowPassFilter(obj.alpha(obj.DCutOff));

            obj.LastTime = obj.UndefinedTime;
        end

        function value_hat = filter(obj, value, timestamp)
            arguments
                obj
                value (1,1) double
                timestamp (1,1) double = obj.UndefinedTime
            end

            % update frequency from timestamps
            if obj.LastTime ~= obj.UndefinedTime && ...
                    timestamp ~= obj.UndefinedTime && ...
                    timestamp > obj.LastTime
                obj.Freq = 1.0 / (timestamp - obj.LastTime);
            end
            obj.LastTime = timestamp;

            % estimate derivative
            if obj.X.hasLastRawValue()
                dvalue = (value - obj.X.lastFilteredValue()) * obj.Freq;
            else
                dvalue = 0.0;
            end

            edvalue = obj.dX.filterWithAlpha(dvalue, obj.alpha(obj.DCutOff));

            % adaptive cutoff
            cutoff = obj.MinCutOff + obj.Beta * abs(edvalue);

            % filter signal
            value_hat = obj.X.filterWithAlpha(value, obj.alpha(cutoff));
        end

        function set.Freq(obj, f)
            arguments
                obj
                f (1,1) double
            end
            if f <= 0
                error('freq should be > 0');
            end
            obj.Freq = f;
        end

        function set.MinCutOff(obj, mc)
            arguments
                obj
                mc (1,1) double
            end
            if mc <= 0
                error('mincutoff should be > 0');
            end
            obj.MinCutOff = mc;
        end

        function set.Beta(obj, b)
            arguments
                obj
                b (1,1) double
            end
            obj.Beta = b;
        end

        function set.DCutOff(obj, dc)
            arguments
                obj
                dc (1,1) double
            end
            if dc <= 0
                error('dcutoff should be > 0');
            end
            obj.DCutOff = dc;
        end
    end

    methods (Access = private)
        function a = alpha(obj, cutoff)
            te = 1.0 / obj.Freq;
            tau = 1.0 / (2 * pi * cutoff);
            a = 1.0 / (1.0 + tau / te);
        end
    end
end
