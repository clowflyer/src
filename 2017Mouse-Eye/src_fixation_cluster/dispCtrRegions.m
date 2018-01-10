function ctr_range = dispCtrRegions(x,y,cid,cx,cy,I,shapeType)
% x,y:      fixation coordinates
% cid:      center index of each fixation points
% cx,cy:    coordinates of cluster centers
% I:        current image
% shapeType:display shape'triangle' or 'circle' or 'none'

ctr_range = zeros(length(cx),7);
% cx,cy,r | (bbox) x,y,w,h
% Display the image first
if strcmp(shapeType,'rectangle') || strcmp(shapeType,'circle')
    figure(10); imshow(I); hold on;
end
for i=1:length(cx)
    % Find all the points of this cluster
    idx = find(cid==i);
    if isempty(idx)
        ctr_range(i,:) = [cx(i),cy(i),0,1,1,0,0];
        continue
    end
    now_x = x(idx);
    now_y = y(idx);
    now_w = max(now_x)-min(now_x);
    now_h = max(now_y)-min(now_y);
    % Save the cluster information
    ctr_range(i,:) = [cx(i),cy(i),floor((now_w+now_h)/4),... % bounding circle params
        min(now_x), min(now_y), now_w, now_h]; % bounding box params
    % Display
    if strcmp(shapeType, 'rectangle')
        rectangle('Position', ctr_range(i,4:end), 'EdgeColor', 'b', 'LineWidth', 1);
%         a=annotation('rectangle', [.5,.5,.2,.2], 'EdgeColor', 'r');
        text(max(now_x)+2,max(now_y),num2str(i),'Color', 'r', 'FontSize', 20);
        title( ['cluster[' num2str(i) ']: ' num2str(length(idx)) '/' num2str(length(cid))] );
    end
    if strcmp(shapeType, 'circle')
        viscircles(ctr_range(i,1:2),ctr_range(i,3),'Color','b');
        text(ctr_range(i,1)+4,ctr_range(i,2)-2,num2str(i),'Color', 'r', 'FontSize', 15);
        plot(cx(i),cy(i),'bx');
        title( ['cluster[' num2str(i) ']: ' num2str(length(idx)) '/' num2str(length(cid))] );
    end
    
%     pause
end
% title(['#fixations: ' num2str(length(x)) ', #clusters:' num2str(length(cid))]);
fprintf('\tcx\tcy\tradius bbox_x\ty\tbbox_w\th\n');
disp(ctr_range)
