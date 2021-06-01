# A bunch of dots

[Main webpage](http://castux.github.io/trees/)

A collection of all free trees up to size 15 (all 13188 of them), as SVG images, as well as an explanation of how they were generated.

Trees are represented in memory as ordered rooted trees (the "standard" recursive tree representation: a tree is a list of children trees). They are also "named" by labeling each subtree with its size and writing down these labels in prefix depth-first traversal order. We define a total order on these trees as the lexicographic order of their names.

Ordered rooted trees are "canonized" into rooted trees by sorting the children trees in decreasing order.

A free tree is represented as the biggest equivalent rooted tree.
