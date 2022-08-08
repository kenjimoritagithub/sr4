function Out = dist(twoSs)

% distance (minimum required time steps) between two states in the 5x5 grid space

for k = 1:2
    xy{k} = [mod(twoSs(k)-1,5)+1, ceil(twoSs(k)/5)];
end
Out = sum(abs(xy{1} - xy{2}));
