function cid2graph(cid,maxc,display,subj)
% cid:  cluter id for each point
% maxc: number of cluster in this image
% display: show the graph or not
% subj: subject index (only for printing)
nowcid = cid;
idx = sub2ind([maxc,maxc],nowcid(1:end-1), nowcid(2:end));
h = hist(idx,1:maxc^2);
result = reshape(h,[maxc,maxc]);
if display
    dg = digraph(result);
    figure(20); plot(dg, 'Layout', 'force')
    title(['subj[' num2str(subj) ']: ' num2str(length(nowcid)) ' points']);
end

