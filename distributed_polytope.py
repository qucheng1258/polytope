import time, itertools, concurrent.futures, argparse, sys, re
from sage.all import *

def getCombination(index, items, k):
    '''Returns (combination, characteristicVector)
    combination - The single combination, of k elements of items, that would be at
    the provided index if all possible combinations had each been sorted in
    descending order (as defined by the order of items) and then placed in a
    sorted list.
    characteristicVector - an integer with chosen item's bits set.
    '''
    combination = []
    characteristicVector = 0
    n = len(items)
    nCk = 1
    for nMinusI, iPlus1 in zip(range(n, n - k, -1), range(1, k + 1)):
        nCk *= nMinusI
        nCk //= iPlus1
    curIndex = nCk
    for k in range(k, 0, -1):
        nCk *= k
        nCk //= n
        while curIndex - nCk > index:
            curIndex -= nCk
            nCk *= (n - k)
            nCk -= nCk % k
            n -= 1
            nCk //= n
        n -= 1
        combination .append(items[n])
        characteristicVector += 1 << n
    return combination, characteristicVector 


def nextCombination(items, characteristicVector):
    '''Returns the next (combination, characteristicVector).
    combination - The next combination of items that would appear after the
    combination defined by the provided characteristic vector if all possible
    combinations had each been sorted in descending order (as defined by the order
    of items) and then placed in a sorted list.
    characteristicVector - an integer with chosen item's bits set.
    '''
    u = characteristicVector & -characteristicVector
    v = u + characteristicVector
    if v <= 0:
        raise OverflowError("Ran out of integers") # <- ready for C++
    characteristicVector =  v + (((v ^ characteristicVector) // u) >> 2)
    combination = []
    copiedVector = characteristicVector
    index = len(items) - 1
    while copiedVector > 0:
        present, copiedVector = divmod(copiedVector, 1 << index)
        if present:
            combination.append(items[index])
        index -= 1
    return combination, characteristicVector

def doWork(dimension, vertices):
    polyhedron = Polyhedron(vertices = vertices)
    fVector = polyhedron.f_vector().list(copy=False)


    def calculateglobalMinSet(vertices):
        nonlocal globalMinSet
        nonlocal minOnEveryCol
        polyhedron = Polyhedron(vertices = vertices)
        fVector = polyhedron.f_vector().list(copy=False)
        
        # Dimension d should have d+2 length f vector
        if len(fVector) != dimension + 2:
            return
        
        # We set the first valid f vector as both the global min and min on every column
        if not globalMinSet:
            globalMinSet = fVector
            minOnEveryCol = fVector
            return

        # Use isMin to track if the f1 vector is smaller than f2 vector on every column
        # To avoid the edge case that the first f vector isn't the smallest
        # We also record the min on every column    
        isMin = True
        for index in range(len(globalMinSet)):
            isMin = isMin and (fVector[index] < globalMinSet[index])
            minOnEveryCol[index] = min(minOnEveryCol[index], fVector[index])
            if isMin:
                globalMinSet = fVector

    
    globalMinSet = []
    minOnEveryCol = []

    calculateglobalMinSet(vertices)

    return globalMinSet, minOnEveryCol

    # print("Calculating d={} n={}".format(dimension, numOfVertices))

    # #for vertices in verticesSet:
    # calculateglobalMinSet(vertices)

    # print("d={} n={}".format(dimension, numOfVertices))
    # file.write("d={} n={}".format(dimension, numOfVertices))
    # file.write("\n")

    # print("The global minimum set of face number is:")
    # file.write("The global minimum set of face number is:\n")
    # print(globalMinSet)
    # file.write(' '.join(map(str, globalMinSet)))
    # file.write('\n')

    # print("The face number set with minimum on each column:")
    # file.write("The face number set with minimum on each column:\n")
    # print(minOnEveryCol)
    # file.write(' '.join(map(str, minOnEveryCol)))
    # file.write('\n')

    # print("The global minimum set equals to the array with min on every column: {}".format(str(globalMinSet == minOnEveryCol)))
    # file.write("The global minimum set equals to the array with min on every column: {}".format(str(globalMinSet == minOnEveryCol)))
    # file.write('\n\n')

def runProgram(start, items, length, k, dimension, node):
    def calculateglobalMinSet(vertices):
        nonlocal globalMinSet
        nonlocal minOnEveryCol
        polyhedron = Polyhedron(vertices = vertices)
        fVector = polyhedron.f_vector().list(copy=False)
        
        # Dimension d should have d+2 length f vector
        if len(fVector) != dimension + 2:
            return
        
        # We set the first valid f vector as both the global min and min on every column
        if not globalMinSet:
            globalMinSet = fVector
            minOnEveryCol = fVector
            return

        # Use isMin to track if the f1 vector is smaller than f2 vector on every column
        # To avoid the edge case that the first f vector isn't the smallest
        # We also record the min on every column    
        isMin = True
        for index in range(len(globalMinSet)):
            isMin = isMin and (fVector[index] < globalMinSet[index])
            minOnEveryCol[index] = min(minOnEveryCol[index], fVector[index])
            if isMin:
                globalMinSet = fVector

    globalMinSet = []
    minOnEveryCol = []

    combination, cv = getCombination(start, items, k)
    calculateglobalMinSet(combination)
    for i in range(length - 1):
        combination, cv = nextCombination(items, cv)
        calculateglobalMinSet(combination)

    return globalMinSet, minOnEveryCol


# parse arguments from command line
parser = argparse.ArgumentParser()

parser.add_argument('-d', '--dimension', help = "Dimension of polytope")
parser.add_argument('-n', '--nvertices', help = "Number of vertices we want to inspect")
parser.add_argument('-f', '--file', help = "File name to write the results to")
parser.add_argument('-r', '--reverse', help = "Run number of vertices in reverse order")
parser.add_argument('-i', '--index', help = "Starting index of number of vertices")
parser.add_argument('-t', '--threads', help = "Number of threads")

args = parser.parse_args()

dimension = int(args.dimension)
k = int(args.nvertices)
file = open(args.file, "w") if args.file else open("result", "w")
nodes = int(args.threads)

items = list(itertools.product(range(2), repeat = dimension))


n = len(items)
for nmip1, i in zip(range(n - 1, n - k, -1), range(2, k + 1)):
    n = n * nmip1 // i


executor = concurrent.futures.ProcessPoolExecutor(max_workers = nodes)
futures = []
start_time = time.time()
for node in range(nodes):
    length = n // nodes
    start = node * length
    future = executor.submit(runProgram, start, items, length, k, dimension, node)
    print("Node {0} initialised".format(node))
    futures.append(future)

global_minOnEveryCol = []
global_minSet = []
for f in concurrent.futures.as_completed(futures):
    threadMinSet, minOnEveryCol = f.result()
    if not global_minSet:
        global_minSet = threadMinSet
        global_minOnEveryCol = minOnEveryCol
     # Use isMin to track if the f1 vector is smaller than f2 vector on every column
    # To avoid the edge case that the first f vector isn't the smallest
    # We also record the min on every column    
    isMin = True
    for index in range(len(global_minSet)):
        isMin = isMin and (threadMinSet[index] < global_minSet[index])
        global_minOnEveryCol[index] = min(minOnEveryCol[index], threadMinSet[index])
        if isMin:
            global_minSet = threadMinSet


print("Calculating d={} n={}".format(dimension, k))


file.write("d={} n={}".format(dimension, k))
file.write("\n")

print("The global minimum set of face number is:")
file.write("The global minimum set of face number is:\n")
print(global_minSet)
file.write(' '.join(map(str, global_minSet)))
file.write('\n')

print("The face number set with minimum on each column:")
file.write("The face number set with minimum on each column:\n")
print(global_minOnEveryCol)
file.write(' '.join(map(str, global_minOnEveryCol)))
file.write('\n')

print("The global minimum set equals to the array with min on every column: {}".format(str(global_minOnEveryCol == global_minSet)))
file.write("The global minimum set equals to the array with min on every column: {}".format(str(global_minOnEveryCol == global_minSet)))
file.write('\n\n')
print("--- %s seconds ---" % (time.time() - start_time))
