function c = getcutflag(X)

% Author Johan L�fberg

c = [];
for i = 1:length(X.clauses)
    c = [c;X.clauses{i}.cut];
end