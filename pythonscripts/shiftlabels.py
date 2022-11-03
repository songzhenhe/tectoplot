# Placing labels so that they do not interfere
# Inspired by https://meta.wikimedia.org/wiki/Map_generator
# Modifications by Kyle Bradley, NTU

# genes are position codes for each label
# There are eight possible alignment codes, corresponding to the
# corners and side mid-points of the rectangle
# Codes are 0..7
# Code 6 is the most preferred
#            0    1    2    3    4    5   6    7
# gmtcodes=('TR','CR','BR','TM','BM','TL','CL','BL')
# toward =   BL   CL   TL  BM    TM   BR   CR   TR

import math, random, matplotlib, sys, csv
# import matplotlib.pyplot as plt
from matplotlib.patches import Rectangle

# labelmy.py [file] [image_width] [image_height] [label_offset] [font_size]

label_width = 40
label_height = 15
label_offset=5
n_labels = 40
# image_width = 400
# image_height = 400

if len(sys.argv) == 6:
    label_file=sys.argv[1]
    image_width=float(sys.argv[2])
    image_height=float(sys.argv[3])
    label_offset=float(sys.argv[4])
    font_size=float(sys.argv[5])
else:
    print(len(sys.argv))
    print("Usage: shiftlabels.py filename image_width image_height label_offset font_size")
    quit()

with open(label_file) as f:
    reader = csv.reader(f, delimiter="\t")
    d = list(reader)

n_labels=len(d)


n_startgenes = 4000     # size of starting gene pool
n_bestgenes = 30       # genes selected for cross-breeding
eps = 10
prob = 0.2


# Plot a rectangle in lbtr format
def addpatch_Rectangle_lbtr(rect, ax, color):
    l, b, r, t = rect
    x=(l+r)/2
    y=(b+t)/2
    w=r-l
    h=t-b
    ax.scatter(x, y, color=color)
    ax.add_patch(Rectangle((x-w/2, y-h/2), w, h, facecolor='none', edgecolor=color))

# Plot a rectangle in lbtr format but offset using a position code
def addpatch_Rectangle_lbtr_code(rect, code, ax, color):
    newrect=gen_rect(rect, code)
    l, b, r, t = newrect
    l1, b1, r1, t1 = rect
    x1=(l1+r1)/2
    y1=(b1+t1)/2
    x=(l+r)/2
    y=(b+t)/2
    w=r-l
    h=t-b
    ax.scatter(x1, y1, color=color)
    ax.add_patch(Rectangle((x-w/2, y-h/2), w, h, facecolor='none', edgecolor=color))


# Return a displaced rectangle in l,b,r,t format
def rect_displace(rect, xdisp, ydisp):
    l, b, r, t = rect
    return (l+xdisp, b+ydisp, r+xdisp, t+ydisp)


def gen_rect(rect, code):
    # Take a rectangle in l,b,r,t format
    l, b, r, t = rect
    width = r - l
    height = t - b
    xdisp = [-1, -1, -1,  0,  0,  1,  1,  1, -1.5, -1.5, -1.5, 0, 0, 1.5, 1.5, 1.5][code]*(width/2.0+label_offset)
    ydisp = [-1,  0,  1, -1,  1, -1,  0,  1, -1.5, 0, 1.5, -1.5, 1.5, -1.5, 0, 1.5][code]*(height/2.0+label_offset)
    return rect_displace(rect, xdisp, ydisp)

# Finds intersection area of two rectangles
def rect_intersect(rect1, rect2):
    l1, b1, r1, t1 = rect1
    l2, b2, r2, t2 = rect2
    w = min(r1, r2) - max(l1, l2)
    h = min(t1, t2) - max(b1, b2)
    if w <= 0: return 0
    if h <= 0: return 0
    return w*h

def biased_random():
    # allowedlist=(0,0,1,1,2,2,3,3,4,4,5,5,5,6,6,7,7,7,8,9,10,11,12,13,14,15,15)
    allowedlist=(0,2,3,4,5,6,7)

    val = random.randrange(len(allowedlist))
    # val = random.randrange(8)
    return allowedlist[val]
    # return val


def point_intersect(rect, point, slop):
    l, b, r, t = rect
    x, y = point
    if x+slop >= l and x-slop <= r and y+slop >= b and y-slop <= t:
        return 1
    return 0


def nudge_rectlist(rectlist):
    # # Nudge the labels slightly if they overlap:
    # # this makes things hugely easier for the optimiser
    # for i in range(len(rectlist)):
    #     for j in range(i):
    #         if rect_intersect(rectlist[i], rectlist[j]):
    #             l1, b1, r1, t1 = rectlist[i]
    #             l2, b2, r2, t2 = rectlist[j]
    #             xdisp = (l1 + r1)/2.0 - (l2 + r2)/2.0
    #             ydisp = (b1 + t1)/2.0 - (b2 + t2)/2.0
    #             nudge = 5.0
    #             pyth = math.sqrt(xdisp**2 + ydisp**2)/nudge
    #             if pyth > eps:
    #                 rectlist[i] = rect_displace(rectlist[i],
    #                                             -xdisp/pyth, -ydisp/pyth)
    #                 rectlist[j] = rect_displace(rectlist[j],
    #                                             xdisp/pyth, ydisp/pyth)
    return rectlist

# Objective function: O(n^2) time
def objective(rects, gene, pointslist):
    rectlist = [gen_rect(rect, code) for rect, code in zip(rects, gene)]
    # Allow for "bending" the labels a bit
    rectlist = nudge_rectlist(rectlist)
    area = 0
    for i in range(len(rectlist)):
    	for j in range(i):
    	    area += rect_intersect(rectlist[i], rectlist[j])

    image_rect = [0, 0, image_width, image_height]

    # Penalize labels which go completely outside the image area
    # for i in range(len(rectlist)):
    #     l, b, r, t = rectlist[i]
    #     if abs(rect_intersect(rectlist[i], image_rect) - (r - l)*(t - b)) < eps:
    #         area += image_width * image_height
    # Penalize labels which go partially outside the image area or cover a point
    for i in range(len(rectlist)):
        if abs(rect_intersect(rectlist[i], image_rect) < rect_intersect(rectlist[i], rectlist[i])):
            area += rect_intersect(rectlist[i], rectlist[i]) - abs(rect_intersect(rectlist[i], image_rect))
        for j in range(len(pointslist)):
            if point_intersect(rectlist[i], pointslist[j], label_offset/2) == 1:
                area += image_width * image_height

    return area

# Mutation function: O(n^2) time
def mutate(rects, gene, prob):
    newgene = gene
    rectlist = [gen_rect(rect, code) for rect, code in zip(rects, gene)]
    # Directed mutation where two rectangles intersect
    for i in range(len(rectlist)):
        for j in range(i):
            if rect_intersect(rectlist[i], rectlist[j]):
                newgene[i] = biased_random()
    # And a bit of random mutation, too
    for i in range(len(gene)):
        if random.random() <= prob:
            newgene[i] = biased_random()
    return newgene

# Crossbreed a base pair
def xbreed(p1, p2):
    # Selection
    if random.randint(0,1):
        return p1
    else:
        return p2

# Crossbreed two genes, then mutate at "hot spots" where intersections remain
def crossbreed(g1, g2):
    return [xbreed(x, y) for x, y in zip(g1, g2)]

random.seed()

# Make a list of label rectangles in their reference positions,
# centered over the map feature; the real labels are displaced
# from these positions so as not to overlap
# Note that some labels are bigger than others

# rects is an array of [xmin,ymin,xmax,ymax] elements in Cartesian space


# Read in a tab delimited file of the labels.
# Note that the X and Y need to be in page coordinates (preferably points)
# 0 1 2   3   4    5        6             7
# X Y lon lat font rotation justification text comprising label text
# X Y 154.034	-8.42	10p,Helvetica,black	0	BL	usp00008hm(7.2)


# Code positions and GMT justification equivalents:

#  2  4  7       BR BC BL
#  1     6       MR MC ML
#  0  3  5       TR TC TL

# 10 12 15
#  9    14
#  8 11 13


# Note that GMT codes indicate the position of the point relative to the box
# and not the box relative to the point!

gmtcodes=('TR','MR','BR','TC','BC','TL','ML','BL','TR','MR','BR','TC','BC','TL','ML','BL')
#
# # (L, C, R) and a vertical (T, M, B)
#
# fig, ax = plt.subplots()
#
# ax.add_patch(Rectangle((0, 0), image_width, image_height, facecolor='none'))
#
rects=[]
points=[]

for i in range(n_labels):
    x=float(d[i][0])
    y=float(d[i][1])
    text=d[i][7]
    gmtcode=gmtcodes.index(d[i][6])
    width=0.5*font_size*len(text)
    height=1*font_size
#     ax.scatter(x,y)
    newrect=(x-width/2.0, y-height/2.0, x+width/2.0, y+height/2.0)
#     addpatch_Rectangle_lbtr_code(newrect, gmtcode, ax, 'black')
    points.append((x,y))
    rects.append(newrect)

# size = random.choice([0.7, 1, 1, 1.5])
# plt.show()
# quit()
#
# rects = []
# points = []
# for i in range(n_labels):
#     x = random.uniform(image_width*0.01, image_width*0.99)
#     y = random.uniform(image_height*0.01, image_height*0.99)
#     ax.scatter(x,y)
#     size = random.choice([0.7, 1, 1, 1.5])
#     width = label_width * size
#     height = label_height * size
#     newrect=(x-width/2.0, y-height/2.0, x+width/2.0, y+height/2.0)
#     addpatch_Rectangle_lbtr_code(newrect, 7, ax, 'black')
#     points.append((x,y))
#     rects.append(newrect)

# print "Label placement. Inital overlap=", sum([rect_intersect(r,r) for r in rects])

# Make some starting genes
# These shouldn't be random - they should be 2 if in SE quad, 0 if in NE quad
# 7 if in SW quad and 5 if in NW quad

genes = [
    [biased_random() for i in range(n_labels)]
    for j in range(n_startgenes)]


for i in range(15):
    rankings = [(objective(rects, gene, points), gene) for gene in genes]
    rankings.sort()
    genes = [r[1] for r in rankings]
    bestgenes = genes[:n_bestgenes]
    bestgene=genes[0]
    # print bestgene
    bestscore = rankings[0][0]
    # print bestscore, prob

    if bestscore == 0:
        break

    # At each stage, we breed the best genes with one another
    genes = bestgenes + [mutate(rects, crossbreed(g1, g2), prob) for g1 in bestgenes for g2 in bestgenes]

# for thisrect in rects:
#     addpatch_Rectangle_lbtr(thisrect, ax, 'blue')

newrectlist = [gen_rect(rect, code) for rect, code in zip(rects, bestgene)]
# for thisrect in newrectlist:
#     addpatch_Rectangle_lbtr(thisrect, ax, 'red')

# We now have the best fitting gene codes but we do have a preference for code 7
# So test each point and if code 7 doesn't have any overlap, change to 7

for i in range(n_labels):
    area=[]
    before=objective(rects, bestgene, points)
    beforegene=bestgene[i]
    for j in range(len(gmtcodes)):
        # Calculate the overlap area
        bestgene[i]=j
        after=objective(rects, bestgene, points)
        area.append(after)
        if (j==7):
            upperright=after
            # print "upperright={}".format(upperright)

    val, idx = min((val, idx) for (idx, val) in enumerate(area))
    valm, idxm = max((val, idx) for (idx, val) in enumerate(area))
    # print "{} before {} val {}".format(d[i][7], before, val)

    if (val < bestscore):
        # print "modify {}".format(d[i][7])
        bestgene[i]=idx
        bestscore=val
    elif (abs(val-upperright)<eps):
        # print "upperright {}".format(d[i][7])
        bestgene[i]=7
    else:
        bestgene[i]=beforegene

fixedrectlist = [gen_rect(rect, code) for rect, code in zip(rects, bestgene)]
# print("bestgene")
# print(bestgene)
# print("end")


with open('newlabels.txt', 'w') as f:
    index=0
    original_stdout = sys.stdout
    sys.stdout=f
    for thisrect in fixedrectlist:
        # addpatch_Rectangle_lbtr(thisrect, ax, 'green')
        if bestgene[index] > 7:
            fileind=2
        else:
            fileind=1
        # print("Label {} has new justification code {}".format(index, gmtcodes[bestgenecopy[index]]))
        print("{}\t{}\t{}\t{}\t{}\t{}\t{}".format(fileind, d[index][2], d[index][3], d[index][4], d[index][5], gmtcodes[bestgene[index]], d[index][7]))
        index=index+1
    sys.stdout=original_stdout

# 0 1 2   3   4    5        6             7
# X Y lon lat font rotation justification text comprising label text
# X Y 154.034	-8.42	10p,Helvetica,black	0	BL	usp00008hm(7.2)



#create simple line plot
# ax.plot([0, image_width],[0, image_height])
# ax.add_patch(Rectangle((0, 0), image_width, image_height, facecolor='none'))
#add rectangle to plot
# ax.add_patch(Rectangle((1, 1), 2, 6))
# for thisrect in rects:
    # addpatch_Rectangle_lbtr(thisrect, ax, 'red')



#display plot
# plt.show()
