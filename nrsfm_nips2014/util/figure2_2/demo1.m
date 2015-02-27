%demo1

addpath(genpath(pwd));
figure2;
for i=1:10
    for j=1:10
        subplot2(10,10,i,j);
        plot([1:100,rand(1,100)*100]);
    end
end
