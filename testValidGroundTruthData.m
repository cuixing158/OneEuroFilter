classdef testValidGroundTruthData < matlab.unittest.TestCase
    % testValidGroundTruthData 验证 OneEuroFilter 是否符合标准 Ground Truth 数据
    % 数据来源: https://github.com/casiez/OneEuroFilter

    methods (Test)
        function testGroundTruthValues(testCase)
            % 1. 读取 Ground Truth 数据
            url = "https://raw.githubusercontent.com/casiez/OneEuroFilter/main/groundTruth.csv";
            try
                data = readtable(url);
            catch ME
                testCase.verifyFail("Can't read from URL: " + ME.message);
                return;
            end

            % 2. 设置滤波器参数
            % 这些是生成 Ground Truth 数据时使用的标准参数
            freq = 120;
            mincutoff = 1.0;
            beta = 0.1;
            dcutoff = 1.0;

            one_euro = OneEuroFilter(freq, ...
                'mincutoff', mincutoff, ...
                'beta_', beta, ...
                'dcutoff', dcutoff);

            % 3. 逐点滤波并验证
            % 注意：Ground Truth 数据包含 timestamp, signal, noisy, filtered
            for i = 1:height(data)
                t = data.timestamp(i);
                noisy_val = data.noisy(i);
                expected_val = data.filtered(i);

                % 执行滤波
                actual_val = one_euro.filter(noisy_val, t);

                % 验证结果 (使用 1e-4 的绝对误差容限，因为 CSV 精度有限)
                testCase.verifyEqual(actual_val, expected_val, 'AbsTol', 1e-4, ...
                    sprintf('Mismatch at index %d (t=%.4f)', i, t));
            end
        end
    end
end