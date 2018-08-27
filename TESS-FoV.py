######################################
#....................................#
#..............TESS-FoV..............#
#...------------------------------...#
#...Determines if object is within...# 
#...TESS FoV from RA, DEC and TIME...#
#....................................#
#...Created by: Harrison J. Abbot....#
#......Started: 23/08/2018...........#
#....Last Edit: 27/08/2018...........#
#....................................#
######################################

# TO DO:
# 	- Constrain RA,DEC to within correct limits, taking into account the poles

#Allows parsing in command line variables
import sys

# Allows python to work with readable date formats
from datetime import datetime

#Standard Python Astronomy coordinate system
from astropy.coordinates import SkyCoord


######################################
#....................................#
#...........Global Variables.........#
#....................................#
######################################

#Setting range for RA and DEC
RAMIN = 0
RAMAX = 360
DECMIN = -90
DECMAX = 90

#File that holds all the RA,DEC and time info for each camera in TESS for each sector
camera_stats_file = 'TESS_Sectors_Camera_Stats.csv'

######################################
#....................................#
#.............Sub-Programs...........#
#....................................#
######################################

#Checks if everything input correctly when launching program
def errorCheck(argv):
	#Checks if inputs are valid:
	#Correct number of inputs
	assert len(argv) == 4, 'Incorrect number of arguments parsed'
	
	#RA in range
	ra = float(argv[1])
	assert ra >= RAMIN and ra < RAMAX, 'RA not in range 0 -> 360 (deg)'
	
	#DEC in range
	dec = float(argv[2])
	assert dec >= DECMIN and dec < DECMAX, 'DEC not in range -90 -> 90 (deg)'
	
	#Time is in correct format DD/MM/YYYY
	try:
		discovery_time = datetime.strptime(argv[3], '%d/%m/%Y')
	except:
		print('Time is not in valid format DD/MM/YYYY')
		quit()

	#If passed everything, return valid inputs
	return ra, dec, discovery_time

#Extracts TESS sector camera data from CSV file
def extractData(line):
	#Line format
	#Camera 1 RA, Camera 1 DEC, Camera 2 RA, Camera 2 DEC, ... , Camera 4 DEC, Time started run, Time finished run
	
	#Split into list of values
	line = line.replace('\n','')
	line_data = line.split(',')
	#Extract values into proper arrays, converting them from string to float
	ra_array = [float(i) for i in [line_data[0],line_data[2],line_data[4],line_data[6]]]
	dec_array = [float(i) for i in [line_data[1],line_data[3],line_data[5],line_data[7]]]

	#Store time_initial and time_final (i.e. the extent of the sector obs. period)
	t_i = datetime.strptime(line_data[8], '%d/%m/%Y')
	t_f = datetime.strptime(line_data[9], '%d/%m/%Y')

	#Creates an object for sector 1
	# sector1 = Sector(ra_array,dec_array,roll_array,t_i,t_f)
	sector = Sector(ra_array,dec_array,t_i,t_f)

	return sector

######################################
#....................................#
#...............Classes..............#
#....................................#
######################################

#Defines the visible locations within one of TESS's sectors
class Sector:

	# def __init__(self, ra_array, dec_array,roll_array, t_i,t_f):
	def __init__(self, ra_array, dec_array, t_i,t_f):
		#Camera pointings (centre of each frame)
		#Each camera has 24x24 FoV, so frame will fit +- 12 deg from ra,dec values
		#sector.camera = [RA, DEC, ROLL]
		self.c1 = SkyCoord(ra_array[0], dec_array[0], frame='icrs', unit='deg')
		self.c2 = SkyCoord(ra_array[1], dec_array[1], frame='icrs', unit='deg')
		self.c3 = SkyCoord(ra_array[2], dec_array[2], frame='icrs', unit='deg')
		self.c4 = SkyCoord(ra_array[3], dec_array[3], frame='icrs', unit='deg')

		#Initial and final time for sector observation
		self.t_i = t_i
		self.t_f = t_f


	# Checks if input coordinates are within FoV for current object's sector
	def checkCoords(self, ra, dec):
		#List to iterate through each camera on TESS
		camera_list = [self.c1,self.c2,self.c3,self.c4]

		#Keeps track of camera that object can be found in
		camera_counter = 1

		#For each camera
		for camera in camera_list:
			#Setting limits of FoV		
			c_min_ra = camera.ra.degree - 12
			c_max_ra = camera.ra.degree + 12

			c_min_dec = camera.dec.degree - 12
			c_max_dec = camera.dec.degree + 12

			#If RA is within valid range
			if ra > c_min_ra and ra < c_max_ra:
				#If DEC is within valid range
				if dec > c_min_dec and dec < c_max_dec:
					return camera_counter

			#Else if haven't found a valid camera yet, try next camera
			camera_counter += 1


		#If coordinate was not found in camera FoV
		else:
			return False

	#Checks if discovery time is within time range of sector
	def checkTime(self,t):
		#If within range, return true
		if self.t_i <= t and t <= self.t_f:
			return True
		else:
			return False

#Stores information about the discovered object
class Supernova:
	def __init__(self, ra, dec, time):
		#RA, DEC and time of discovery
		self.ra = ra
		self.dec = dec
		self.time = time

######################################
#....................................#
#............Main Program............#
#....................................#
######################################

def main():

	#Program should be called like so:
	# python TESS-FoV 'RA' 'DEC' 'TIME'
	# ------ argv[0]   [1]  [2]   [3]

	#Checks for errors in launching program
	ra, dec, discovery_time = errorCheck(sys.argv)

	#If everything passed, create object
	SN = Supernova(ra, dec, discovery_time)
	
	#Read in each sector camera stats
	with open(camera_stats_file,'r') as cam_stats:
		#Void the first line as it's just titles
		cam_stats.readline()

		#Keeps track of which sector object will be found in
		sector_count = 1

		#Read in data from now on
		for line in cam_stats:
			sector = extractData(line)
			#Check if input coordinates are in sector being checked
			#obj_found = camera number that obj will be in
			obj_found = sector.checkCoords(SN.ra, SN.dec)
			t_valid = sector.checkTime(SN.time)

			#If object in TESS FoV and time is valid
			if obj_found and t_valid:
				print('Object at RA: {}, DEC: {} will be found with TESS camera {} in sector {}'.format(ra,dec,obj_found, sector_count))
				return sector_count
			#Else if not found in this sector, look in next
			sector_count += 1

		#If object not in TESS field, exit on 0
		else:
			print('Object not in TESS field')
			return False

main()