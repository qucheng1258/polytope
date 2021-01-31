import numpy as np
import argparse, sys, re, time, itertools



def runProgram(dimension, numOfVertices, file):
	def calculateglobalMinSet(vertices):
		nonlocal globalMinSet
		nonlocal minOnEveryCol
		polyhedron = Polyhedron(vertices = vertices)
		fVector = polyhedron.f_vector().list(copy=False)

		if not globalMinSet:
			globalMinSet = fVector
			minOnEveryCol = fVector
			return
		isMin = True
		for index in range(len(globalMinSet)):
			isMin = isMin and (fVector[index] < globalMinSet[index])
			minOnEveryCol[index] = min(minOnEveryCol[index], fVector[index])
			if isMin:
				globalMinSet = fVector
	
	verticesList = list(itertools.product(range(2), repeat = dimension))
	verticesSet = itertools.combinations(verticesList, numOfVertices)
	
	globalMinSet = []
	minOnEveryCol = []

	for vertices in verticesSet:
		calculateglobalMinSet(vertices)

	print("d={} n={}".format(dimension, numOfVertices))
	file.write("d={} n={}".format(dimension, numOfVertices))
	file.write("\n")

	print("The global minimum set of face number is:")
	file.write("The global minimum set of face number is:\n")
	print(globalMinSet)
	file.write(' '.join(map(str, globalMinSet)))
	file.write('\n')

	print("The face number set with minimum on each column:")
	file.write("The face number set with minimum on each column:\n")
	print(minOnEveryCol)
	file.write(' '.join(map(str, minOnEveryCol)))
	file.write('\n')

	print("The global minimum set equals to the array with min on every column: {}".format(str(globalMinSet == minOnEveryCol)))
	file.write("The global minimum set equals to the array with min on every column: {}".format(str(globalMinSet == minOnEveryCol)))
	file.write('\n\n')


# parse arguments from command line
parser = argparse.ArgumentParser()

parser.add_argument('-d', '--dimension', help = "Dimension of polytope")
parser.add_argument('-n', '--nvertices', help = "Number of vertices we want to inspect")
parser.add_argument('-f', '--file', help = "File name to write the results to")
parser.add_argument('-r', '--reverse', help = "Run number of vertices in reverse order")

args = parser.parse_args()

dimension = int(args.dimension)
file = open(args.file, "w") if args.file else open("result", "w")

if args.nvertices:
	numOfVertices = int(args.nvertices)
	runProgram(dimension, numOfVertices, file)
	file.close()
	quit()

for i in range(2, pow(2, dimension) - 2):
	runProgram(dimension, pow(2, dimension) - i if args.reverse else i, file)


file.close()
