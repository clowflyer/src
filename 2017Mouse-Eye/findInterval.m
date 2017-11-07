function interVec = findInterval(dur, c_in, c_out)

% dur:  ?x4 matrix (subj,begin,end,duration) -> back to centeridx
% c_in: desired start center index
% c_out:desired finished center index

interVec = [];

if c_in==c_out
    interVec = [interVec ; 0];
end

for subj = 1:max(dur(:,1))
    idx = find(dur(:,1)==subj);
    nowdur = dur(idx,2:4);
    
end
