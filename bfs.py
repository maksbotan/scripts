#!/usr/bin/env python
# -*- coding: utf8 -*-

import sys, math

print "Введите координаты начала в виде (x,y)"
x1, y1 = input()

print "Введите координаты конца в виде (x,y)"
x2, y2 = input()

def neigh_gen(point):
    for i in [1,-1]:
        yield (point[0]+5*i, point[1])
    for i in [1,-1]:
        yield (point[0], point[1]+5*i)
    for i in [1,-1]:
        for j in [1,-1]:
            yield (point[0]+3*i, point[1]+4*j)
    for i in [1,-1]:
        for j in [1,-1]:
           yield (point[0]+4*i, point[1]+3*j)

Q = []
Q.append(((x1,y1),2))

visited = {(x1,y1):2}
points = []

end = (x2,y2)

while Q != []:
    point, rang = Q.pop(0)
    if point == end:
        print 'RESULT FOUND'
        way = []
        for i in range(rang-1,1,-1):
            way.append(point)
            for p in neigh_gen(point):
                try:
                    if visited[p] == i:
                        point = p
                        break
                except KeyError:
                    continue
        print way
        sys.exit(0)


    for i in neigh_gen(point):
        if i not in visited:
            Q.append((i,rang+1))
            visited[i] = rang + 1
#BFS((x1,x2),(x2,y2))
#print ways
