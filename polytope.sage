from itertools import product, permutations
import numpy as np
import argparse, sys, re

# Polytope that only contains 0 or 1 in vertices
# eg [[0,1], [1, 0]]
# matrix = set of vertices. a 2d array of [0, 1, .....]
class ZeroOnePolytope:
    def __init__(self, matrix):
        self.dimension = len(matrix[0])
        # compress 01 matrix into a single array of decimals
        # store the sorted array
        self.decimalArray = [None] * len(matrix)
        for i in range(len(matrix)):
            binaryString = ''.join(str(n) for n in matrix[i])
            self.decimalArray[i] = int(binaryString, 2)

    # define the polytope's key
    def __key(self):
        self.decimalArray.sort()
        key = ''.join(str(n) for n in self.decimalArray)
        return key

    # hash function for 0,1 polytope
    def __hash__(self):
        return hash(self.__key())

    # equivlenece relation of 0,1 polytopes
    def __eq__(self, other):
        if isinstance(other, ZeroOnePolytope):
            return self.__key() == other.__key() or self.transpose().__key() == other.transpose().__key()
        return NotImplemented

    # decompress decimal array to 01 polytope matrix
    def getDecompressedMatrix(self):
        matrix = []
        for decimal in self.decimalArray:
            length = '{0:0' + str(self.dimension) + 'b}'
            matrix.append(list(map(int, length.format(decimal))))
        return matrix

    # transpose the matrix
    def transpose(self):
        transposedMatrix = np.matrix(self.getDecompressedMatrix()).transpose().tolist()
        self.__init__(transposedMatrix)
        return self

    # Flipped polytope is represented by a line of string
    def setFlippedPolytopeSet(self, verticesList):
        self.flippedPolytopeSet = set()
        for i in range(len(verticesList)):
            temp = self.decimalArray
            for j in range(len(verticesList[i])):
                if verticesList[i][j] == 1:
                    temp[j] = pow(2, self.dimension + 1) - temp[j]
            temp.sort()
            self.flippedPolytopeSet.add(''.join(str(n) for n in temp))
        return self

    # Iterate through vertices matrices and build a polyhedron on each vertices matrix
    # Store unique f vector of each built polyhedron
    def getFaceNumSet(self):
        faceNumSetNoIdx = []
        polyhedron = Polyhedron(vertices = self.getDecompressedMatrix())
        fVector = polyhedron.f_vector()
        if fVector not in faceNumSetNoIdx:
            faceNumSetNoIdx.append(polyhedron.f_vector())
        return faceNumSetNoIdx

    def isDisjoint(self, other):
        if isinstance(other, ZeroOnePolytope):
            return self.flippedPolytopeSet.isdisjoint(other.flippedPolytopeSet)
        return NotImplemented

    def get2DArray(self):
        return self.getDecompressedMatrix()

    def print(self):
        print (np.matrix(self.getDecompressedMatrix()))

# Python program to get all
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
# result ---> a set stores all unique results
minSet = []
def combinationUtil(arr, n, r,  
                    index, data, i): 
    # Current combination is  
    # ready to be printed, 
    # print it 
    if(index == r): 
        combList = []
        for j in range(r): 
            combList.append(data[j])
        polytope = ZeroOnePolytope(combList)
        faceNumSet = polytope.getFaceNumSet()
        global minSet
        if not minSet:
            minSet = faceNumSet
            return
        isMin = True
        for index in range(len(minSet)):
            isMin = isMin and (faceNumSet[index] < minSet[index])
            if isMin:
                minSet = faceNumSet
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
                    index + 1, data, i + 1) 
      
    # current is excluded,  
    # replace it with 
    # next (Note that i+1  
    # is passed, but index  
    # is not changed) 
    combinationUtil(arr, n, r, index,  
                    data, i + 1) 
  
  
# The main function that 
# prints all combinations 
# of size r in arr[] of  
# size n. This function  
# mainly uses combinationUtil() 
def getUniquePolytopesFromCombination(arr, n, r): 
  
    # A temporary array to 
    # store all combination 
    # one by one 
    data = list(range(r)) 
      
    # Store all combinations to result
    combinationUtil(arr, n, r,  
                    0, data, 0)

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

# @deprecated
# Helper function for getting all permutated matrices from a matrices
# TODO: dedup while adding each permutated set
def getAllPermutatedMatrices(matrices):
    allPermutatedMatrices = []
    for i in range(len(matrices)):
        allPermutatedMatrices.extend(getPermutatedMatricesFromMatrix(matrices[i]))
    return allPermutatedMatrices


# @deprecated
# This function removes the intersected elements of matrices1 and matrices2 from matrices1
def getDeduplicatedMatrices(m1, m2):
    for i in range(len(m1)):
        for j in range(len(m2)):
            if m1[i] == m2[j]:
                m1[i] = None
    
    return list(filter(None, m1))

# This function dedups matrices and returns a list of unique polytopes
def getUniquePolytopesFromMatrices(m1):
    polytopeSet = set()
    transposedPolytopeSet = set()
    for i in range(len(m1)):
        polytope = ZeroOnePolytope(m1[i])
        polytopeSet.add(polytope)

    # deduplicate based on transposed matrix
    for p in polytopeSet:
        transposedPolytope = p.transpose()
        transposedPolytopeSet.add(transposedPolytope)

    # transpose back
    for p in transposedPolytopeSet:
        p.transpose()

    return transposedPolytopeSet


def getUniqueTransposedPolytopesFromPolytopeSet(polytopeSet):
    result = set()
    # deduplicate based on transposed matrix
    for p in polytopeSet:
        transposedPolytope = p.transpose()
        result.add(transposedPolytope)

    # transpose back
    for p in result:
        p.transpose()

    return result


def getUniquePolytopesFromFlippedPolytopeComparison(polytopeSet):
    polytopeList = list(polytopeSet)
    for i in range(len(polytopeList)):
        for j in range(i + 1, len(polytopeList)):
            if not polytopeList[i].isDisjoint(polytopeList[j]):
                polytopeSet.remove(polytopeList[j])

    return polytopeSet

# helper function for printing matrices nicely
def printMatrices(matrices):
    for i in range(len(matrices)):
        print(np.matrix(matrices[i]))


# parse arguments from command line
parser = argparse.ArgumentParser()

parser.add_argument('-d', '--dimension', help = "Dimension of polytope")
parser.add_argument('-n', '--nvertices', help = "Number of vertices we want to inspect")
parser.add_argument('-f', '--file', help = "File name to write the results to")

args = parser.parse_args()

dimension = int(args.dimension)
numOfVertices = int(args.nvertices)
file = open(args.file, "w") if args.file else open("result", "w")

verticesList = list(product(range(2), repeat = dimension))
verticesList = [list(elem) for elem in verticesList]
print("Initialize a list of vertices of [0,1]  based on dimension d. Size = 2^d \n")
print(verticesList)
print("\n")
file.write("Initialize a list of vertices of [0,1]  based on dimension d. Size = 2^d \n\n")
np.savetxt(file, np.matrix(verticesList), fmt='%d', newline='\n', delimiter=',')
file.write("\n")


# verticesMatrices = getCombination(verticesList, len(verticesList), numOfVertices)
# print("Get matrices of combination of vertices based on n vertices we want in a matrix. 2^d choose n \n")
# printMatrices(verticesMatrices)
# print("\n")

# permutatedMatrices = getAllPermutatedMatrices(verticesMatrices)
# print("Get permutated matrices of each vertices matrix (vertices set derived from equivlence relation ii) \n")
# printMatrices(permutatedMatrices)
# print("\n")

getUniquePolytopesFromCombination(verticesList, len(verticesList), numOfVertices)
print(minSet)
# polytopeList = getUniquePolytopesFromCombination(verticesList, len(verticesList), numOfVertices)
# minSet = polytopeList[0].getFaceNumSet()
# print("Set of " + str(len(polytopeList)) + " unique vertices based on first combinations \n")
# for i in range(1, len(polytopeList)):
#     # polytope.print()
#     # polytope.setFlippedPolytopeSet(verticesList)
#     faceNumSet = polytopeList[i].getFaceNumSet()
#     isMin = True
#     for index in range(len(minSet)):
#         isMin = isMin and (faceNumSet[index] < minSet[index])
#     if isMin:
#         minSet = faceNumSet

# print(faceNumSet)




# uniqueFlippedPolytopes = getUniquePolytopesFromFlippedPolytopeComparison(uniquePolytopes)
# print("Set of " + str(len(uniqueFlippedPolytopes)) + "unique vertices based on second flippedPolytopes \n")
# for polytope in uniqueFlippedPolytopes:
#     polytope.print()

# uniqueTransposedPolytopes = getUniqueTransposedPolytopesFromPolytopeSet(uniqueFlippedPolytopes)
# print("Set of " + str(len(uniqueTransposedPolytopes)) + "unique vertices based on third transposation \n")
# for polytope in uniqueTransposedPolytopes:
#     polytope.print()

# print("Set of unique vertices based on equivlence relation \n")
# file.write("Set of unique vertices based on equivlence relation \n")
# for polytope in uniqueTransposedPolytopes:
#     polytope.print()
#     file.write('\n')
#     np.savetxt(file, polytope.getMatrix(), fmt='%d', newline='\n', delimiter=',')

# print(len(uniqueTransposedPolytopes))

file.close()