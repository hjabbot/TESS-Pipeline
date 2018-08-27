
#TESS FoV checker package
# REFERENCE:	Mukai, K. & Barclay, T. 2017, tvguide: A tool for determining whether stars and galaxies are observable by TESS., v1.0.0, Zenodo, doi:10.5281/zenodo.823357
import tvguide
# USAGE:		
# tvguide.check_observable(ra,dec)
# tvguide.check_many(ra_array, dec_array)




#Plotting package
import matplotlib.pyplot as plt


######################################
#....................................#
#...........Global Variables.........#
#....................................#
######################################

#Declination range
DECMIN = -90
DECMAX = 90
#Right Ascension range
RAMIN = 0
RAMAX = 180

#Granularity of RA/DEC
ANGLESTEP = 1




######################################
#....................................#
#.............Sub-Programs...........#
#....................................#
######################################

#Generates an array between two values minx,maxx with increments of step 
def genArray(minx,maxx,step):
	#Set x to min value
	x = minx
	#Blank list to append to
	x_array = []

	#While within working range, append values
	while x < maxx-ANGLESTEP:
		x_array.append(x)
		x += step

	return x_array





######################################
#....................................#
#............Main Program............#
#....................................#
######################################

def main():

	#Generate full set of coordinates that can be seen
	ra_full_array = genArray(RAMIN,RAMAX,ANGLESTEP)
	dec_full_array = genArray(DECMIN,DECMAX,ANGLESTEP)
	

	#Different arrays to store coords, each with different colour coding
	ra_array_1 = []
	dec_array_1 = []

	ra_array_2 = []
	dec_array_2 = []

	ra_array_3 = []
	dec_array_3 = []

	ra_array_4 = []
	dec_array_4 = []

	ra_array_5plus = []
	dec_array_5plus = []

	#Creates a 2D array of 0's for each ra/dec combo
	# coords_visible = [[False]*int((DECMAX-DECMIN)/ANGLESTEP)]*int((RAMAX-RAMIN)/ANGLESTEP)


	#For all RA values
	for r in range(len(ra_full_array)):
		print(r)
		#For all DEC values
		for d in range(len(dec_full_array)):
			
			coords = tvguide.check_many([ra_full_array[r]],[dec_full_array[d]])
			#If coords are in TESS FoV one time
			if coords[0][2] == 1:
				ra_array_1.append(ra_full_array[r])
				dec_array_1.append(dec_full_array[d])
			#If coords are in TESS FoV two times
			elif coords[0][2] == 2:
				ra_array_2.append(ra_full_array[r])
				dec_array_2.append(dec_full_array[d])
			#If coords are in TESS FoV three times
			elif coords[0][2] == 3:
				ra_array_3.append(ra_full_array[r])
				dec_array_3.append(dec_full_array[d])
			#If coords are in TESS FoV four times
			elif coords[0][2] == 4:
				ra_array_4.append(ra_full_array[r])
				dec_array_4.append(dec_full_array[d])
			#If coords are in TESS FoV five or more times
			elif coords[0][2] >= 5:
				ra_array_5plus.append(ra_full_array[r])
				dec_array_5plus.append(dec_full_array[d])
						




	plt.title('TESS Track')
	plt.ylabel('Declination (deg)')
	plt.xlabel('Right Ascension (deg)')
	axes = plt.gca()
	axes.set_xlim([RAMIN,RAMAX])
	axes.set_ylim([DECMIN,DECMAX])

	plt.plot(ra_array_1,dec_array_1,'ro')
	plt.plot(ra_array_2,dec_array_2,'yo')
	plt.plot(ra_array_3,dec_array_3,'go')
	plt.plot(ra_array_4,dec_array_4,'co')
	plt.plot(ra_array_5plus,dec_array_5plus,'bo')

	plt.show()







	#Returns list of all coords with how many times they will be seen by TESS
	#[RA,DEC,MIN Sectors, MAX Sectors]
	all_coords = tvguide.check_many(ra_array, dec_array)

	#Stores all coords in all_coords that will get TESS time
	coords_visible = []

	#Generate new array with coordinates that will be in visible range for TESS
	for coords in all_coords:
		#If coords are part of a sector that gets TESS time
		if coords[2] != 0:
			coords_visible.append([coords[0],coords[1]])


	print(coords_visible)

