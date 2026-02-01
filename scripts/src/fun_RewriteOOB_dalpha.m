function fun_RewriteOOB_dalpha(file_path, dalpha)
% 修改OOB的二分精度
% 读取文件内容
    fid = fopen(file_path, 'r');
    if fid == -1
        error('无法打开文件');
    end

    % 使用 textscan 一次性读取所有行
    lines = textscan(fid, '%s', 'Delimiter', '\n');
    lines = lines{1}; % 提取为元胞数组
    fclose(fid);

    % 查找目标行
    found = false;
    for i = 1:length(lines)
        if contains(lines{i}, '! Run Type')
            % 使用 sprintf 插入 dalpha 的值
            lines{i} = sprintf('%s %s ! Run Type', '''3''', num2str(dalpha));
            found = true;
            break;
        end
    end

    % 将修改后的内容写回文件
    fid = fopen(file_path, 'w');
    if fid == -1
        error('无法写入文件');
    end

    % 写入每一行
    for i = 1:length(lines)
        fprintf(fid, '%s\n', lines{i});
    end
    fclose(fid);

    disp('文件修改完成。');
end