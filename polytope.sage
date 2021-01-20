from itertools import product, permutations
import numpy as np
import argparse, sys, re

# Polytope that only contains 0 or 1 in vertices
# eg [[0,1], [1, 0]]
# matrix = set of vertices. a 2d array of [0, 1, .....]
class ZeroOnePolytope:
    def __init__(self, matrix):
        self.matrix = np.matrix(matrix)

    # define the polytope's key to be the hash value of sorted matrix in bytes
    def __key(self):
        temp = self.matrix.copy()
        temp.sort()
        return hash(temp.tobytes())

    # hash function for 0,1 polytope
    # since the key is already unique, just return the key as hash key
    def __hash__(self):
        return self.__key()

    # equivlenece relation of 0,1 polytopes
    def __eq__(self, other):
        if isinstance(other, ZeroOnePolytope):
            return self.__key() == other.__key() or self.transpose().__key() == other.transpose().__key()
        return NotImplemented

    # transpose the matrix
    # TODO: see if can use np.matrix()
    def transpose(self):
        self.matrix = self.matrix.transpose()
        return self

    def print(self):
        print (self.matrix)

# Python program to print all 
# subset combination of n  
# element in given set of r element . 
  
# arr[] ---> Input Array 
# data[] ---> Temporary array to  
#             store current combination 
# start & end ---> Staring and Ending  
#                  indexes in arr[] 
# index ---> Current index in data[] 
# r ---> Size of a combination  
#        to be printed 
def combinationUtil(arr, n, r,  
                    index, data, i, result): 
    # Current combination is  
    # ready to be printed, 
    # print it 
    if(index == r): 
        combList = []
        for j in range(r): 
            combList.append(data[j])
        result.append(combList)
        return
  
    # When no more elements  
    # are there to put in data[] 
    if(i >= n): 
        return
  
    # current is included,  
    # put next at next 
    # location  
    data[index] = arr[i] 
    combinationUtil(arr, n, r,  
                    index + 1, data, i + 1, result) 
      
    # current is excluded,  
    # replace it with 
    # next (Note that i+1  
    # is passed, but index  
    # is not changed) 
    combinationUtil(arr, n, r, index,  
                    data, i + 1, result) 
  
  
# The main function that 
# prints all combinations 
# of size r in arr[] of  
# size n. This function  
# mainly uses combinationUtil() 
def getCombination(arr, n, r): 
  
    # A temporary array to 
    # store all combination 
    # one by one 
    data = list(range(r)) 
      
    # Store all combinations to result
    result = []
    combinationUtil(arr, n, r,  
                    0, data, 0, result)
    return result

# this function permutes the whole matrix based on column index
# eg. if i and i+1 swapped in the first row, same for the rest of the rows
# returns a list of permutated matrices
def getPermutatedMatricesFromMatrix(matrix):
    permutatedRowList = []
    for i in range(len(matrix)):
        # get all results of each row's permutations
        # because each row uses itertools.permutations()
        # each row's permutations results should preserve the same order
        # eg the ith element of jth row should have the same column index swapped with ith element of j+1th row, same for the rest
        permutatedRow = list(permutations(matrix[i]))
        permutatedRowList.append(permutatedRow)
    # construct the permutated matrix by column index
    rowNum = len(permutatedRowList)
    colNum = len(permutatedRowList[0])
    permutatedMatrices = []
    # since the first permutation is always itself
    # we start from the second
    for col in range(1, colNum):
        tempMatrix = []
        for row in range(rowNum):
            tempMatrix.append(permutatedRowList[row][col])
        permutatedMatrices.append(tempMatrix)
    return permutatedMatrices

# Helper function for getting all permutated matrices from a matrices
# TODO: dedup while adding each permutated set
def getAllPermutatedMatrices(matrices):
    allPermutatedMatrices = []
    for i in range(len(matrices)):
        allPermutatedMatrices.extend(getPermutatedMatricesFromMatrix(matrices[i]))
    return allPermutatedMatrices


@deprecated
# This function removes the intersected elements of matrices1 and matrices2 from matrices1
def getDeduplicatedMatrices(m1, m2):
    for i in range(len(m1)):
        for j in range(len(m2)):
            if m1[i] == m2[j]:
                m1[i] = None
    
    return list(filter(None, m1))

# This function dedups two matrices and returns a list of unique polytopes
def getUniquePolytopesFromMatrices(m1, m2):
    polytopeSet = set()
    transposedPolytopeSet = set()
    for i in range(len(m1)):
        polytope = ZeroOnePolytope(m1[i])
        polytopeSet.add(polytope)
    for i in range(len(m2)):
        polytope = ZeroOnePolytope(m2[i])
        polytopeSet.add(polytope)

    # deduplicate based on transposed matrix
    for p in polytopeSet:
        transposedPolytope = p.transpose()
        transposedPolytopeSet.add(transposedPolytope)

    # transpose back
    for p in transposedPolytopeSet:
        p.transpose()

    return transposedPolytopeSet

def getFaceNumSet(verticesMatrices):
    # Iterate through vertices matrices and build a polyhedron on each vertices matrix
    # Store unique f vector of each built polyhedron
    faceNumSetNoIdx = []
    for i in range(len(verticesMatrices)):
        polyhedron = Polyhedron(vertices = verticesMatrices[i])
        fVector = polyhedron.f_vector()
        if fVector not in faceNumSetNoIdx:
            faceNumSetNoIdx.append(polyhedron.f_vector())
    return faceNumSetNoIdx

# helper function for printing matrices nicely
def printMatrices(matrices):
    for i in range(len(matrices)):
        print(np.matrix(matrices[i]))


# parse arguments from command line
parser = argparse.ArgumentParser()

parser.add_argument('-d', '--dimension', help = "Dimension of polytope")
parser.add_argument('-n', '--nvertices', help = "Number of vertices we want to inspect")

args = parser.parse_args()

dimension = int(args.dimension)
numOfVertices = int(args.nvertices)

verticesList = list(product(range(2), repeat = dimension))
print("Initialize a list of vertices of [0,1]  based on dimension d. Size = 2^d \n")
print(verticesList)
print("\n")

verticesMatrices = getCombination(verticesList, len(verticesList), numOfVertices)
print("Get matrices of combination of vertices based on n vertices we want in a matrix. 2^d choose n \n")
printMatrices(verticesMatrices)
print("\n")

permutatedMatrices = getAllPermutatedMatrices(verticesMatrices)
print("Get permutated matrices of each vertices matrix (vertices set derived from equivlence relation ii) \n")
printMatrices(permutatedMatrices)
print("\n")


uniquePolytopes = getUniquePolytopesFromMatrices(verticesMatrices, permutatedMatrices)
print("Set of unique vertices based on equivlence relation \n")
for polytope in uniquePolytopes:
    polytope.print()
