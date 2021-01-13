from itertools import product, permutations
import numpy as np
import argparse, sys, re

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


# This function removes the intersected elements of matrices1 and matrices2 from matrices1
def getDeduplicatedMatrices(m1, m2):
    for i in range(len(m1)):
        for j in range(len(m2)):
            if m1[i] == m2[j]:
                m1[i] = None
    
    return list(filter(None, m1))

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

dedupedMatrices = getDeduplicatedMatrices(verticesMatrices, permutatedMatrices)
print("Remove intersected matrices (vertices sets) from the first combination of vertices matrices we got \n")
printMatrices(dedupedMatrices)
print("\n")
