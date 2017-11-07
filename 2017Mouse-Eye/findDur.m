function out = findDur(sig)
% 2017.04.21 Finding duration
% sig = idx;
% using diff function
mydiff = diff(sig);
didx = find(mydiff~=0);

% set start and end index except the last one
idx_start = [0; didx(1:end-1)];
idx_end = didx;

% this cluster, next cluster, duration
out = [sig(idx_end) , sig(idx_end+1) , idx_end-idx_start];

% pending the last one with -1 indicate no transfer
if isempty(out) % if the signal doesn't change at all
    out = [sig(1), -1, length(sig)];
else
    out = [out ; [sig(end), -1, length(sig)-didx(end)] ];
end