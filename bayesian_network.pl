node(meliane).
node(felipe).
node(thiago).
node(allison).
node(gabriel).

parent(meliane, thiago).
parent(meliane, felipe).
parent(thiago, felipe).
parent(felipe,allison).

p(meliane, 0.123).

p(thiago, [meliane], 0.358).
p(thiago, [\+ meliane], 0.011).

p(felipe, [meliane, thiago], 0.788).
p(felipe, [meliane, \+ thiago], 0.38).
p(felipe, [\+ meliane, thiago], 0.43).
p(felipe, [\+ meliane, \+ thiago], 0.08).

p(allison, [felipe], 0.912).
p(allison, [\+ felipe], 0.032).

edge(meliane, felipe).
edge(meliane, thiago).
edge(felipe, allison).
