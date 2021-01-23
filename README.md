# polytope

A python program uses [SageMath](https://www.sagemath.org/) to play with 0,1 polytopes

To run the program
1. Download and install [SageMath](https://doc.sagemath.org/html/en/installation/)
2. Then `sage polytope.sage -d <dimension> -n <number of vertices> -f <filename output to>`


## Example
```
sage polytope.sage -d 2 -n 3 -f results2
Initialize a list of vertices of [0,1]  based on dimension d. Size = 2^d 

[(0, 0), (0, 1), (1, 0), (1, 1)]


Set of unique vertices based on equivlence relation 

[[0 1]
 [1 0]
 [1 1]]
[[0 0]
 [0 1]
 [1 0]]
[[0 0]
 [0 1]
 [1 1]]
```
