
function yq = myinterp1(x, y, xq)
    index = find(x<xq, 1, 'first');
    if ~isempty(index)
        if index == 1
            yq = y(index);
        else
            yq = y(index-1) + (y(index) - y(index-1)) * (xq - x(index-1)) / (x(index) - x(index-1));
        end
    else
        yq = nan;
    end
end