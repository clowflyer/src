function mygscatter(x,y,cid)
% 
maxgrp = length(unique(cid));
clr = hsv(maxgrp); % Colors
cls = unique(cid); % Class index
hold on;
allname = cell(length(cls),1); % saving for use of legend
flag=0;
for i=1:length(cls)
    if cls(i)==0
        allname=allname(2:end);
        flag=1;
        continue;
    end
    nowidx = find(cid==cls(i));
    h = plot(x(nowidx),y(nowidx),'Color', clr(i,:), 'LineStyle', 'none', 'Marker', '.', 'MarkerSize', 10);
    allname{i-flag} = ['class ' num2str(cls(i)) ':' num2str(length(nowidx))];
end
% legend(allname','Location','best');