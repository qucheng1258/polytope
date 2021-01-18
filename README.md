# polytope

A python program uses [SageMath](https://www.sagemath.org/) to play with 0,1 polytopes

To run the program
1. Download and install [SageMath](https://doc.sagemath.org/html/en/installation/)
2. Then `sage polytope.sage -d <dimension> -n <number of vertices>`


## Example
```
sage polytope.sage -d 2 -n 3
Initialize a list of vertices of [0,1]  based on dimension d. Size = 2^d 

[(0, 0), (0, 1), (1, 0), (1, 1)]


Get matrices of combination of vertices based on n vertices we want in a matrix. 2^d choose n 

[[0 0]
 [0 1]
 [1 0]]
[[0 0]
 [0 1]
 [1 1]]
[[0 0]
 [1 0]
 [1 1]]
[[0 1]
 [1 0]
 [1 1]]


Get permutated matrices of each vertices matrix (vertices set derived from equivlence relation ii) 

[[0 0]
 [1 0]
 [0 1]]
[[0 0]
 [1 0]
 [1 1]]
[[0 0]
 [0 1]
 [1 1]]
[[1 0]
 [0 1]
 [1 1]]


Set of unique vertices based on equivlence relation 

[[0 0]
 [0 1]
 [1 1]]
[[0 1]
 [1 0]
 [1 1]]
[[0 0]
 [0 1]
 [1 0]]

```
