#Delousing efficiency project data analysis
#Adam Brooker
#29th August 2016

# LIST OF FUNCTIONS ------------------------------------------------------------------------------------------------

# 1. locations() = returns a summary matrix of pen locations for all fish
# 2. batch.locations() = returns a summary matrix of locations for all dayfiles in working directory and saves to an Excel spreadsheet
# 3a. depact() = returns depth and activity summary for all fish with standard deviations
# 3b. depact.se() = returns depth and activity summary for all fish with standard errors
# 4. depth.sum() = returns depth summary for each fish
# 5. batch.depth() = creates spreadsheet of mean depths +/- st dev for individual fish over multiple days
# 6. batch.totdepth() = batch function to return matrix of mean and standard error depths for all fish combined over multiple days
# 7. batch.activity() = creates spreadsheet of mean activity +/- st dev for each dayfile in working dir
# 8. batch.totactivity() = batch function to return matrix of mean and standard error activity for all fish combined over multiple days
# 9a. prop.coverage() = calculates fish coverage of pens 7 and 8
# 9b. hmean.prop.coverage() = calculates hourly mean fish coverage of pens 7 and 8
# 10a. batch.coverage() = calculates fish coverage of pens 7 and 8 over multiple days
# 10b. hmean.batch.coverage() = caculates hourly mean fish coverage of pens 7 and 8 over multiple days
# 10c. hmean.perfish.coverage - daily hourly coverage per fish for all days loaded as one file using load.all()
# 11a. fish.depth(period) = draws a plot of fish depth for the fish id specified
# 11b. fish.act(period) = draws a plot of fish activity for the fish id specified
# 12. fish.3depth(period1, period2, period3) = draws a plot of depths of 3 fish
# 13. fish.plot(period) = draws a plot of fish location for the fish id specified
# 14. fish.3plot(period1, period2, period3) = draws a plot of locations of 3 fish
# 15. add.fish(period, fishcol) = add a fish to the current plot (period = fish id, fishcol = number from 1-20)
# 16a. fish.hexplot(period) = draws a plot of fish location density for the fish id specified 
# 16b. hexplot.all(pen) = draws a plot of fish location density for all fish in the pen specified 
# 16c. draws plots of fish location density for all fish in pens 7 and 8 and plots side by side
# 17. fish.3dplot(period) = draws a 3d plot of fish location and depth
# 18. fish.3dmove(period) = draws a 3d interactive plot of fish location and depth
# 19a. plot.bydepth(period) = draws a plot of fish locations coloured by depth (blue = >15m, red = <15m)
# 19b. plot.byactivity(period, static, burst) = draws a plot of fish locations coloured by activity
# 19c. plot.bylight(period) = draws a plot of fish locations coloured by time of day (dawn, day, dusk, night)
# 20. add.depthfish(period) = add a fish to the current plot coloured by depth
# 21. fractal() = calculate fractal dimensions for pens 7 & 8 using the box counting method. Returns plot of box counts with fractal dimension and R2
# 22. batch.fractals() = calculate fractal dimensions for each fish over several day files in a folder. Returns an Excel spreadsheet of fractal dimension and R2 for all fish each day
# 23. id.fractals() = calculate fractal dimensions for each fish on one day file. Returns table of fractal dimesions and R2 values and saves to Excel spreadsheet
# 24. plot.bytime(period) = draws a plot of fish locations colour coded according number of time divisions (bins)
# 25. batch.remove(period, start.day, no.days) = Removes single fish id from specified day files
# 26. prop.coverage.3d() = proportion coverage 3D (not sure this is working properly!)
# 27. ma.filter(period, smooth, thresh) = moving average filter function. Period = fish id, smooth = size of smoothing filter, thresh = data removal threshold in metres
# 28. add(period)  = add a single fish to a dayfile after cleaning data using ma.filter function
# 29. recode() = function to recode fish speeds and save to dayfile after cleaning data
# 30. batch.subset(variable, factors) = batch function to subset and save data according to specified variable and factors, variable = column to subset by, factors = list of variables in column
# 31a. heatplot.anim(pen, frames) = Create series of plots for animation (pen = pen number 7 or 8, frames = No. of frames, set to No. of hours in dataset)
# 31b. fishplot.anim <- function(pen, frames, framedur, animdur) = Create series of individual fish plots for animation. pen = pen to plot, frames = No. of frames to create, framedur = portion of time to plot for each frame in secs, animdur = length of fish trails in No. of frames (0 = cumulative frames)
# 32. fish.hist(pt) = draw histogram of fish depth or activity from fish files (pt = 'activity' or 'depth')
# 33. load.all() = Load all data files (.csv) in folder into single data frame
# 34. crop(xmin, xmax, ymin, ymax) = Crop edges of dataset to remove multipath
# 35. save() = Save loaded dayfile to .csv file of original name
# 36. distance() = calculate distance travelled for all individual fish in day file
# 37. batch.dist() = calculate distance travelled for all fish files in a folder
# 38. Load.dayfile() = load specified dayfile
# 39. multiplot() = off-the-shelf function to draw multiple ggplots
# 40. head() = draws two polar plots of headings for pens 7 and 8
# 45. bsf(static, cruise, save) = calculate behaviour state frequencies (static, cruise, burst) for pens 7 and 8. static = upper limit of static state, cruise = upper limit of cruise state, save = save plot and data file(T/F)


# NOTES -------------------------------------------------------------------------------------------------------------

# coverage grid size:
# mean swimming speed = 0.03m/s, max ping rate = 10 sec. Mean distance covered between pings = 0.03*10 = 0.3m
# Therefore: grid size = 0.3m

# ------------------------------------------------------------------------------------------------------------------

library(hexbin)
library(scatterplot3d)
library(rgl)
library(rJava)
library(XLConnectJars)
library(XLConnect) 
library(RColorBrewer)
library(colorspace)
library(colorRamps)
library(stats)
library(ggplot2)
library(animation)
detach("package:dplyr")
library(openxlsx)
library(xlsx)
library(chron)
library(lubridate)
library(magick)
library(gridExtra)
library(cowplot)
library(data.table)

#ENTER YOUR VARIABLES HERE
workingdir <- ifelse(Sys.info()['user'] == 'Laptop', "H:/Acoustic tag - Preconditioning A/Data processing/Filtered Data/Recoded Day CSV", '/Volumes/My Book/Acoustic datasets/Precon A') # change to location of data
#workingdir = "H:/Acoustic tag - Preconditioning A/Data processing/Filtered Data/Recoded Day CSV" # change to location of data
dayfile.loc = "run_3LLF16S100183_day_coded.csv" # change to file to be analysed
masterfileloc = "H:/Data processing/AcousticTagFile_2016.xlsx" # change to location of AcousticTagFile.xlsx


workingdir = "H:/Data processing/2016 Conditioning study A/Filtered Data/Recoded Fish CSV/Conditioned" # change to location of data
dayfile.loc = "run_3LLF16S1009621_fish_coded.csv" # change to file to be analysed
masterfileloc = "H:/Data processing/AcousticTagFile_2016.xlsx" # change to location of AcousticTagFile.xlsx


#old dayfile classes
dayfile.classes <- c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                     'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                     'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                     'double', 'double', 'double', 'double', 'double', 'double', 'double',
                     'double', 'double', 'double', 'double', 'double', 'double', 'double',
                     'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                     'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                     'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                     'double', 'double', 'double', 'double', 'double', 'double', 'double'
)


# LOAD FILES-------------------------------------------------------------------------------------------------------------------

#LOAD LOCATIONS CODING DATA
#locations.lookup <- read.xlsx(masterfileloc, sheetName = 'Locations coding', startRow = 1, endRow = 43, colIndex = seq(1, 7)) # read in codes from Locations Coding spreadsheet
locations.lookup <- readWorksheetFromFile(masterfileloc, sheet = 12, startRow = 1, endCol = 7) # read in codes from Locations Coding spreadsheet
rownames(locations.lookup) <- locations.lookup$Code


# LOAD DAYFILE
setwd(workingdir)                                                                                                    
dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = dayfile.classes) #read data into table


#SORT BY TIME AND TAG
dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag


# SANDPIT-----------------------------------------------------------------------------------------------------------------

# animated 3d plot
plot3d(fish.id$PosX, fish.id$PosY, fish.id$PosZ, pch = 20, xlim =  c(0, 35), ylim = c(5, 40), zlim = c(0, 26), xlab = 'X', ylab = 'Y', zlab = 'Z', type = 'l')
dir.create("animation")
for (i in 1:1000){
  view3d(userMatrix=rotationMatrix(pi/2 * i/1000, 0, 1, -1))
  rgl.snapshot(filename=paste("animation/frame-", sprintf("%03d", i), ".png", sep=""))
}


# hexplot for all fish
bin <- hexbin(dayfile$PosX, dayfile$PosY, xbins = 50)
plot(hexbin(dayfile$PosX, dayfile$PosY, xbins = 50), xlab = 'X', ylab = 'Y')


# pen 7 x,y plots
par(mfrow=c(3,3))
fish.3plot('8977', '7073', '9313')
fish.3plot('7997', '9761', '8585')
fish.3plot('7549', '9369', '8669')
fish.3plot('8641', '9341', '9957')
fish.3plot('8753', '9845', '8445')
fish.3plot('7017', '8333', '8613')
fish.plot('9621')
fish.plot('9285')


# pen 8 x,y plots
par(mfrow=c(3,3))
fish.3plot('9257', '8305', '7801')
fish.3plot('8137', '7969', '8361')
fish.3plot('8221', '7465', '7325')
fish.3plot('9565', '9593', '8949')
fish.3plot('9817', '8781', '8809')
fish.3plot('8697', '7605', '7829')
fish.plot('7689')
fish.plot('9929')


# pen 7 x,y plot
par(mfrow=c(1,1))
fishpal <- rainbow_hcl(20, c=100, l=63, start=-360, end=-32, alpha = 0.2)
fish.plot('8977')
add.fish('8445', fishcol = fishpal[19])
add.fish('8333', fishcol = fishpal[18])
add.fish('7017', fishcol = fishpal[17])
add.fish('8613', fishcol = fishpal[16])
add.fish('9621', fishcol = fishpal[15])
add.fish('9285', fishcol = fishpal[14])
add.fish('7073', fishcol = fishpal[13])
add.fish('9313', fishcol = fishpal[12])
add.fish('7997', fishcol = fishpal[11])
add.fish('9761', fishcol = fishpal[10])
add.fish('8585', fishcol = fishpal[9])
add.fish('7549', fishcol = fishpal[8])
add.fish('9369', fishcol = fishpal[7])
add.fish('8669', fishcol = fishpal[6])
add.fish('8641', fishcol = fishpal[5])
add.fish('9341', fishcol = fishpal[4])
add.fish('9957', fishcol = fishpal[3])
add.fish('8753', fishcol = fishpal[2])
add.fish('9845', fishcol = fishpal[1])


# pen 8 x,y plot
par(mfrow=c(1,1))
fishpal <- rainbow_hcl(20, c=100, l=63, start=-360, end=-32, alpha = 0.2)
fish.plot('9257')
add.fish('8697', fishcol = fishpal[19])
add.fish('7605', fishcol = fishpal[18])
add.fish('9929', fishcol = fishpal[17])
add.fish('9817', fishcol = fishpal[16])
add.fish('7829', fishcol = fishpal[15])
add.fish('8305', fishcol = fishpal[14])
add.fish('7801', fishcol = fishpal[13])
add.fish('8137', fishcol = fishpal[12])
add.fish('7969', fishcol = fishpal[11])
add.fish('8361', fishcol = fishpal[10])
add.fish('8221', fishcol = fishpal[9])
add.fish('7465', fishcol = fishpal[8])
add.fish('7325', fishcol = fishpal[7])
add.fish('8949', fishcol = fishpal[6])
add.fish('9593', fishcol = fishpal[5])
add.fish('9565', fishcol = fishpal[4])
add.fish('7689', fishcol = fishpal[3])
add.fish('8781', fishcol = fishpal[2])
add.fish('8809', fishcol = fishpal[1])



# pen 7 depth plots
par(mfrow=c(3,3))
fish.3depth('8977', '7073', '9313')
fish.3depth('7997', '9761', '8585')
fish.3depth('7549', '9369', '8669')
fish.3depth('8641', '9341', '9957')
fish.3depth('8753', '9845', '8445')
fish.3depth('9621', '9285', '8613')
fish.depth(7017)
fish.depth(8333)


# pen 8 depth plots
par(mfrow=c(3,3))
fish.3depth('9257', '8305', '7801')
fish.3depth('8137', '7969', '8361')
fish.3depth('8221', '7465', '7325')
fish.3depth('9565', '9593', '8949')
fish.3depth('7689', '8781', '8809')
fish.3depth('8697', '7605', '9929')
fish.depth('9817')
fish.depth('7829')


# pen 7 x,y plot by depth
par(mfrow=c(1,1))
depthpal <- diverge_hcl(30, h = c(11,266), c = 100, l = c(21,85), power = 0.6, alpha = 0.2)
plot.bydepth('9313')
add.depthfish('7997')
add.depthfish('9761')
add.depthfish('8585')
add.depthfish('7549')
add.depthfish('9369')
add.depthfish('8669')
add.depthfish('8641')
add.depthfish('9341')
add.depthfish('9957')
add.depthfish('8753')
add.depthfish('9845')
add.depthfish('8445')
add.depthfish('9621')
add.depthfish('9285')
add.depthfish('8613')
add.depthfish('7017')
add.depthfish('8977')
add.depthfish('8333')
add.depthfish('7073')
rect(locations.lookup['7EW', 'xmin'], locations.lookup['7EW', 'ymin'], locations.lookup['7EW', 'xmax'], locations.lookup['7EW', 'ymax'], lty = 2) # 7EW edge
rect(locations.lookup['7ES', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7ES', 'xmax'], locations.lookup['7ES', 'ymax'], lty = 2) # 7ES edge
rect(locations.lookup['7EE', 'xmin'], locations.lookup['7EE', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EE', 'ymax'], lty = 2) # 7EE edge
rect(locations.lookup['7EN', 'xmin'], locations.lookup['7EN', 'ymin'], locations.lookup['7EN', 'xmax'], locations.lookup['7EN', 'ymax'], lty = 2) # 7EN edge
rect(locations.lookup['7WHSE', 'xmin'], locations.lookup['7WHSE', 'ymin'], locations.lookup['7WHSE', 'xmax'], locations.lookup['7WHSE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
rect(locations.lookup['7WHNW', 'xmin'], locations.lookup['7WHNW', 'ymin'], locations.lookup['7WHNW', 'xmax'], locations.lookup['7WHNW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
rect(locations.lookup['7EW', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EN', 'ymax'], lwd = 2) # cage limits

#legend(32, 42, c(1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30), fill = depthpal, pch = 20, cex = 0.7)


# pen 8 x,y plot by depth
par(mfrow=c(1,1))
depthpal <- diverge_hcl(30, h = c(11,266), c = 100, l = c(21,85), power = 0.6, alpha = 0.2)
plot.bydepth('9257')
add.depthfish('8305')
add.depthfish('7801')
add.depthfish('8137')
add.depthfish('7969')
add.depthfish('8361')
add.depthfish('8221')
add.depthfish('7465')
add.depthfish('7325')
add.depthfish('8949')
add.depthfish('9593')
add.depthfish('9565')
add.depthfish('7689')
add.depthfish('8781')
add.depthfish('8809')
add.depthfish('8697')
add.depthfish('7605')
add.depthfish('9929')
add.depthfish('9817')
add.depthfish('7829')
rect(locations.lookup['8EW', 'xmin'], locations.lookup['8EW', 'ymin'], locations.lookup['8EW', 'xmax'], locations.lookup['8EW', 'ymax'], lty = 2) # 7EW edge
rect(locations.lookup['8ES', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8ES', 'xmax'], locations.lookup['8ES', 'ymax'], lty = 2) # 7ES edge
rect(locations.lookup['8EE', 'xmin'], locations.lookup['8EE', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EE', 'ymax'], lty = 2) # 7EE edge
rect(locations.lookup['8EN', 'xmin'], locations.lookup['8EN', 'ymin'], locations.lookup['8EN', 'xmax'], locations.lookup['8EN', 'ymax'], lty = 2) # 7EN edge
rect(locations.lookup['8WHSW', 'xmin'], locations.lookup['8WHSW', 'ymin'], locations.lookup['8WHSW', 'xmax'], locations.lookup['8WHSW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
rect(locations.lookup['8WHNE', 'xmin'], locations.lookup['8WHNE', 'ymin'], locations.lookup['8WHNE', 'xmax'], locations.lookup['8WHNE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
rect(locations.lookup['8EW', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EN', 'ymax'], lwd = 2) # cage limits


#1 plot
par(mfrow=c(1,1))

#blank plot
plot(x=NULL, y=NULL, xlim=c(0,72), ylim=c(0,45))

#subset all fish from 1 pen
fish.id <- subset(dayfile, PEN == '7')

#mean fish swim speed
mean(fish.id$MSEC)

#create list of all files in working directory
files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)

# code for manaully removing dead fish ------------------------------------------------------------------------------------

tot.days <- unique(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d')) # returns list of days in file
tot.days

dayfile <- dayfile[!(dayfile$Period == 7017),] # remove dead fish

write.csv(dayfile, file = dayfile.loc) #write output to file

#-------------------------------------------------------------------------------------------------------------------------------

#ggplot2 hexplot code

pen.col <- 'black'
pen.size <- 1.2
#plot.col <- rev(heat.colors(2, alpha = 1))
plot.col <- matlab.like(1000)

hexplot <- ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY))
hexplot <- hexplot + geom_hex(bins = 40, alpha = 0.6) + scale_fill_gradientn(colours=plot.col)
hexplot + annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) +
  annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +
  annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) +
  annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) +
  annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'longdash', size = pen.size) +
  annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'longdash', size = pen.size) +
  annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'longdash', size = pen.size) +
  annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'longdash', size = pen.size)






ani.options(interval = 0.01)

saveGIF({  
  

for (i in 1:100){
  plot(fish.id[1:i,'PosX'], fish.id[1:i,'PosY'], xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 0.8, xlim = c(5, 36), ylim = c(8, 41), type = 'p', col = fishpal[20]) # tight plot
  
  
}

})

# code for trimming edges of data

fish.id <- subset(dayfile, dayfile$PosY < 41 & dayfile$Period == 9929)
dayfile <- subset(dayfile, !(dayfile$Period == 9929))
dayfile <- rbind(dayfile, fish.id)


fish.id <- subset(dayfile, dayfile$Period == 8949)
fish.id <- subset(fish.id, duplicated(fish.id$EchoTime) == FALSE)



# code to create animated gif from sequence of plot images

system.time({
  setwd(paste0(workingdir, '/animate'))
  files <- list.files(path = paste0(workingdir, '/animate'), pattern = '*.png', all.files = FALSE, recursive = FALSE)
  
  anim.frames <- image_read(files)
  
  animation <- image_animate(anim.frames, fps = 2, loop = 0, dispose = 'previous')
  
  image_write(animation, 'anim.gif')
}
)


# code to draw top view of pen 7 with colour-coded locations

par(mfrow=c(1,1))

plot(50, 50, xlab = 'X (m)', ylab = 'Z (m)', pch = 20, cex = 1, xlim = c(10, 45), ylim = c(10, 45), type = 'l', col = '#26b426') # tight plot
polygon(c(15, 21, 21, 15), c(15, 15, 21, 21), lty = 1, lwd = 2, col = rgb(248, 203, 173, maxColorValue = 255)) # SW corner
polygon(c(15, 21, 21, 15), c(33, 33, 39, 39), lty = 1, lwd = 2, col = rgb(255, 153, 153, maxColorValue = 255)) # NW corner
polygon(c(33, 39, 39, 33), c(15, 15, 21, 21), lty = 1, lwd = 2, col = rgb(255, 153, 153, maxColorValue = 255)) # SE corner
polygon(c(33, 39, 39, 33), c(33, 33, 39, 39), lty = 1, lwd = 2, col = rgb(248, 203, 173, maxColorValue = 255)) # NE corner
polygon(c(21, 33, 33, 21), c(15, 15, 21, 21), lty = 1, lwd = 2, col = rgb(118, 113, 113, maxColorValue = 255)) # S edge
polygon(c(33, 39, 39, 33), c(21, 21, 33, 33), lty = 1, lwd = 2, col = rgb(118, 113, 113, maxColorValue = 255)) # E edge
polygon(c(21, 33, 33, 21), c(33, 33, 39, 39), lty = 1, lwd = 2, col = rgb(118, 113, 113, maxColorValue = 255)) # N edge
polygon(c(15, 21, 21, 15), c(21, 21, 33, 33), lty = 1, lwd = 2, col = rgb(118, 113, 113, maxColorValue = 255)) # W edge
polygon(c(21, 33, 33, 21), c(21, 21, 33, 33), lty = 1, lwd = 2, col = rgb(192, 0, 0, maxColorValue = 255)) # centre
polygon(c(33.35, 37.35, 37.35, 33.35), c(15.13, 15.13, 19.13, 19.13), lty = 1, lwd = 2, col = rgb(146, 208, 80, maxColorValue = 255)) # SE hide
polygon(c(15.49, 19.49, 19.49, 15.49), c(35.10, 35.10, 39.10, 39.10), lty = 1, lwd = 2, col = rgb(146, 208, 80, maxColorValue = 255)) # NW hide
polygon(c(36, 39, 39, 36), c(13.5, 13.5, 16.5, 16.5), lty = 1, lwd = 2, col = rgb(0, 176, 240, maxColorValue = 255)) # SE feed block
polygon(c(13.5, 16.5, 16.5, 13.5), c(36, 36, 39, 39), lty = 1, lwd = 2, col = rgb(0, 176, 240, maxColorValue = 255)) # NW feed block

# code to draw side view of pen 7 with colour-coded locations

par(mfrow=c(1,1))
plot(50, 50, xlab = 'X (m)', ylab = 'Z (m)', pch = 20, cex = 1, xlim = c(10, 43), ylim = c(25, -5), type = 'l', col = '#26b426') # tight plot
polygon(c(15, 21, 21, 15), c(15, 15, 0, 0), lty = 1, lwd = 2, col = rgb(248, 203, 173, maxColorValue = 255)) # left edge
polygon(c(21, 33, 33, 21), c(15, 15, 0, 0), lty = 1, lwd = 2, col = rgb(118, 113, 113, maxColorValue = 255)) # edge
polygon(c(33, 39, 39, 33), c(15, 15, 0, 0), lty = 1, lwd = 2, col = rgb(255, 153, 153, maxColorValue = 255)) # right edge
polygon(c(15, 27, 39), c(15, 20, 15), lwd = 2, col = rgb(208, 206, 206, maxColorValue = 255)) # bottom cone
polygon(c(33.35, 37.35, 37.35, 33.35), c(12, 12, 8, 8), lwd = 2, col = rgb(146, 208, 80, maxColorValue = 255)) # hide SE
#polygon(c(15.49, 19.49, 19.49, 15.49), c(9.98, 9.98, 13.9, 13.9), lty = 1, lwd = 2, col = rgb(146, 208, 80, maxColorValue = 255)) # NW hide
polygon(c(36, 39, 39, 36), c(4.5, 4.5, 7.5, 7.5), lty = 1, lwd = 2, col = rgb(0, 176, 240, maxColorValue = 255)) # SE feed block
#polygon(c(13.5, 16.5, 16.5, 13.5), c(4.5, 4.5, 7.5, 7.5), lty = 1, lwd = 2, col = rgb(0, 176, 240, maxColorValue = 255)) # NW feed block

# log scale and labels for activity histograms

# conditioned wrasse
hdep + scale_x_log10(breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.8, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10), labels = c('0.001', '', '', '', '', '', '', '', '', '0.01', '', '', '', '', '', '', '', '', '0.1', '', '', '', '', '', '', '', '', '1', '', '', '', '', '', '', '', '', '10')) + scale_y_continuous(limits = c(0, 100000)) + ggtitle('Conditioned wrasse activity histogram')

# unconditioned wrasse
hdep + scale_x_log10(breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.8, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10), labels = c('0.001', '', '', '', '', '', '', '', '', '0.01', '', '', '', '', '', '', '', '', '0.1', '', '', '', '', '', '', '', '', '1', '', '', '', '', '', '', '', '', '10')) + scale_y_continuous(limits = c(0, 100000)) + ggtitle('Unconditioned wrasse activity histogram')


# code to add date column to dayfile----------------

dayfile$date <- as.Date(dayfile$EchoTime + hours(0))


#--------------------------------------------------------------------------------------------------------------------------------------------

#STATS

# One-way anova to compare activity at different times of day-------------------------------------------------------------
# all comparisons are highly significant due to the big dataset (big Df)
# use eta squared to measure effect size

# extract required data
actdf <- dayfile[c(1, 3, 12, 42)] # extract required variables
actdf <- subset(actdf, Period == 8641) # extract single fish
actdf <- subset(actdf, SUN == 'D' | SUN == 'W' | SUN == 'K' | SUN == 'N') # extract observations with time of day codes
#actdf <- subset(actdf, SUN == 'D' | SUN == 'N') # extract observations with time of day codes
actdf$log_BLSEC <- log(actdf$BLSEC) # log transform data
actdf <- actdf[!is.infinite(actdf$log_BLSEC),] # remove infinite observations
actdf <- na.omit(actdf) # remove NAs
actdf$log_BLSEC_trans <- actdf$log_BLSEC - floor(min(actdf$log_BLSEC)) # transpose so all observations are positive


aovact <- aov(log_BLSEC_trans~SUN, data = actdf)
summary(aovact)
TukeyHSD(aovact)

library(lsr)
etaSquared(aovact)
# significant effect sizes
# small >0.01, medium >0.06, large >0.14

library(effsize)
cohen.d(actdf$log_BLSEC_trans, actdf$SUN)
# significant effect sizes
# small >0.2, medium >0.5, large >0.8

boxplot(log_BLSEC_trans~SUN, data = actdf)
hist(log(actdf[which(actdf$SUN == 'W'),'BLSEC']))


# coverage stat analysis on per hour per fish per day results--------------------

cov.mean <- coverage[,c(1, 2, seq(3, 63, 2))]
tot.means <- aggregate(cov.mean, by = list(cov.mean$pen), FUN = mean)
tot.means <- tot.means[,-c(1, 2, 3, 4)]
rownames(tot.means) <- c('7', '8')
tot.sd <- aggregate(cov.mean, by = list(cov.mean$pen), FUN = sd)

# total means and sds for wild and farmed wrasse all days
tot.means <- as.data.frame(t(tot.means))
tot.means$day <- rownames(tot.means)
tot.means <- melt(tot.means, measure.vars = c(1, 2)) # melt for stat analysis

mean(tot.means[4:40, 1])
sd(tot.means[4:40, 1])
mean(tot.means[4:40, 2])
sd(tot.means[4:40, 2])

model <- lm(value~variable, data = tot.means)
anova(model)


# stat test for all fish coverage

statdf <- coverage[,c(1, 2, seq(3, 63, 2))]
statdf <- statdf[,-3]
statdf <- melt(statdf, id.vars = c(1, 2)) # melt for stat analysis

model <- lm(value~pen*variable, data = statdf)
anova(model)

# comparison of day and night per hour per fish results

setwd('H:/Data processing/2016 Conditioning study A/Filtered Data/Recoded Day CSV/Outputs')

cov.day <- read.csv('CoverageOutput_hmeanperfish_day.csv', header = T)
cov.day <- cov.day[,-c(1,2)]
cov.day <- cov.day[,c(1, seq(2, 61, 2))]
cov.day <- aggregate(.~pen, FUN = mean, data = cov.day)
cov.day <- as.data.frame(t(cov.day))
colnames(cov.day) <- c('pen 7', 'pen 8')
cov.day <- cov.day[-1,]
cov.day <- melt(cov.day, measure.vars = c(1, 2)) # melt for stat analysis
colnames(cov.day) <- c('pen', 'coverage')
cov.day$tod <- 'day'
cov.day$day <- rownames(cov.day)
cov.day <- cov.day[-c(1, 17, 31, 47),] # remove corresponding missing values in night dataset

cov.night <- read.csv('CoverageOutput_hmeanperfish_night.csv', header = T)
cov.night <- cov.night[,-c(1,2)]
cov.night <- cov.night[,c(1, seq(2, 61, 2))]
cov.night <- aggregate(.~pen, FUN = mean, data = cov.night)
cov.night <- as.data.frame(t(cov.night))
colnames(cov.night) <- c('pen 7', 'pen 8')
cov.night <- cov.night[-1,]
cov.night <- melt(cov.night, measure.vars = c(1, 2)) # melt for stat analysis
colnames(cov.night) <- c('pen', 'coverage')
cov.night$tod <- 'night'
cov.night$day <- rownames(cov.night)
cov.night <- cov.night[-c(1, 17, 31, 47),] # remove missing values

cov.tod <- rbind(cov.day, cov.night)

model <- lm(coverage~tod*pen, data = cov.tod)
model <- lm(coverage~tod(day), data = cov.tod[cov.tod$pen == 'pen 7',])
summary(model)

boxplot(coverage~tod, cov.tod[cov.tod$pen == 'pen 8',])

# repeated measures anova for coverage by tod

cov.aov <- with(cov.tod[cov.tod$pen == 'pen 8',], aov(coverage~tod + Error(day/(tod))))
summary(cov.aov)

# second coverage analysis by tod attempt using means for individual fish


setwd('H:/Data processing/2016 Conditioning study A/Filtered Data/Recoded Day CSV/Outputs')

cov.day <- read.csv('CoverageOutput_hmeanperfish_day.csv', header = T)
cov.day <- cov.day[,-c(1)]
cov.day <- cov.day[,c(1, 2, seq(3, 61, 2))]
colnames(cov.day) <- c('fish', 'pen', seq(1, 30, 1))
cov.day <- melt(cov.day, id.vars = c(1, 2)) # melt for stat analysis
colnames(cov.day) <- c('fish', 'pen', 'day', 'coverage')
cov.day$tod <- 'day'

cov.night <- read.csv('CoverageOutput_hmeanperfish_night.csv', header = T)
cov.night <- cov.night[,-c(1)]
cov.night <- cov.night[,c(1, 2, seq(3, 61, 2))]
colnames(cov.night) <- c('fish', 'pen', seq(1, 30, 1))
cov.night <- melt(cov.night, id.vars = c(1, 2)) # melt for stat analysis
colnames(cov.night) <- c('fish', 'pen', 'day', 'coverage')
cov.night$tod <- 'night'

cov.fish.tod <- rbind(cov.day, cov.night)

boxplot(coverage~tod, data = cov.fish.tod[cov.fish.tod$pen == '7',])

model <- aov(coverage~tod*day, data = cov.fish.tod[cov.fish.tod$pen == '7',])
summary(model)


# depth analysis -----------------------------------------

dayfile$date <- as.Date(dayfile$EchoTime + hours(1)) # add date to dayfile
statdf <- dayfile[c(1, 3, 4, 7, 43, 64)]

model <- lm(PosZ~PEN, data = statdf)
library(lsr)
etaSquared(model)

# aggregate by date (mean and sd) and plot means by pen
statdf <- statdf %>% group_by(PEN, date) %>% summarize_all(funs(mean, sd)) # aggregate by date and calculate mean and sd
statdf <- as.data.frame(statdf)
statdf <- statdf[-c(1, 33),]

plot(statdf$date[statdf$PEN == '7'], statdf$PosZ_mean[statdf$PEN == '7'], type = 'l', ylim = c(25, 0))
lines(statdf$date[statdf$PEN == '8'], statdf$PosZ_mean[statdf$PEN == '8'])
model7 <- lm(statdf$PosZ_mean[statdf$PEN == '7']~statdf$date[statdf$PEN == '7'])
model8 <- lm(statdf$PosZ_mean[statdf$PEN == '8']~statdf$date[statdf$PEN == '8'])

# calculate least-squares regressions of daily means per pen and compare slopes
library(lsmeans)
aggtest <- dayfile[,c(3, 7, 64)]
aggtest <- aggtest %>% group_by(PEN, date) %>% summarize_all(funs(mean, sd))
aggtest <- as.data.frame(aggtest)
aggtest <- aggtest[-c(1, 33),]
aggtest$day <- seq(1, 31, 1)
m.interaction <- lm(mean~day*PEN, data = aggtest)
anova(m.interaction)
m.lst <- lstrends(m.interaction, 'PEN', var = 'day')
m.lst
pairs(m.lst)


# activity stat analysis----------------------

statdf <- dayfile[c(1, 3, 4, 12, 43, 64)] # extract required variables from entire dataset
statdf <- arrange(statdf, date, PEN, Period, EchoTime)
statdf <- statdf[statdf$SUN == 'D' | statdf$SUN == 'N',]
statdf$SUN <- factor(statdf$SUN, levels(statdf$SUN)[c(2, 4)]) # remove unused factor levels
statdf <- statdf[is.na(statdf$BLSEC) == F,] # remove nas from activity data
statdf <- statdf[!statdf$BLSEC == 0,] # remove zero activity values for log transform

statdf$logact <- log(statdf$BLSEC) # log transform to unskew data

statdf <- statdf %>% group_by(PEN, date) %>% summarize_all(funs(mean, sd)) # calculates aggregated means and sds
statdf$logact <- log(statdf$BLSEC_mean) # log transform to unskew data

statdf <- aggregate(.~date*PEN*SUN, data = statdf, FUN = mean) # calculated aggregated means
statdf <- statdf[,-c(4, 5)]

#statsamp <- statdf[floor(runif(500, 1, nrow(statdf))),] # random sample of dataset to reduce calculation time

boxplot(logact~SUN, data = statdf[statdf$PEN == '8',])
hist(statdf$logact)

library(nortest)
ad.test(statdf$logact[statdf$PEN == '7' & statdf$SUN == 'D']) # calculates significant difference from normal distribution (Anderson-Darling test)

qqnorm(statdf$logact[statdf$PEN == '7' & statdf$SUN == 'D']) # qq plot for normality (should be a straight line)

library(car)
leveneTest(logact~SUN, data = statdf) # Levene's test for homogeniety of variance

range(statdf$BLSEC[statdf$PEN == '8'])

model <- lm(BLSEC~PEN, data = dayfile)
etaSquared(model)

model <- lm(logact~SUN, data = statdf[statdf$PEN == '8',])




# FUNCTIONS----------------------------------------------------------------------------------------------------------------------------------


# 1. FUNCTION TO CALCULATE SUMMARY OF FISH LOCATIONS
locations <- function()
{
  # pen 7 location summary
  dayfile.bot <- subset(dayfile, BOT == 'B' & PEN == '7')
  dayfile.top <- subset(dayfile, BOT == 'Z' & PEN == '7')
  dayfile.out <- subset(dayfile, OUT == '7OE' | OUT == '7OS' | OUT == '7ON' | OUT == '7OW' & PEN == '7')
  dayfile.edg <- subset(dayfile, EDG == '7EN' | EDG == '7EW' | EDG == '7ES' | EDG == '7EE' & PEN == '7')
  dayfile.hidc <- subset(dayfile, BIGC == '7CNW' | BIGC == '7CSE' & PEN == '7' & SEC >= 0)
  dayfile.mtc <- subset(dayfile, BIGC == '7CSW' | BIGC == '7CNE' & PEN == '7' & SEC >= 0)
  dayfile.cen <- subset(dayfile, CEN == '7MH' | CEN == '7MM' | CEN == '7ML' & PEN == '7')
  dayfile.hid <- subset(dayfile, HID == '7WHSE' | HID == '7WHNW' & PEN == '7')
  #location.sum <- data.frame(c(nrow(dayfile.bot), nrow(dayfile.top), nrow(dayfile.out), nrow(dayfile.edg), nrow(dayfile.bigc), nrow(dayfile.cen), nrow(dayfile.hid)))
  location.sum <- data.frame(c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600))
  rownames(location.sum) <- c('<15m', '>15m', 'outer', 'edge', 'hide_corner', 'empty_corner', 'centre', 'hides')
  colnames(location.sum) <- 'ConP7'
  
  # pen 8 location summary
  dayfile.bot <- subset(dayfile, BOT == 'B' & PEN == '8')
  dayfile.top <- subset(dayfile, BOT == 'Z' & PEN == '8')
  dayfile.out <- subset(dayfile, OUT == '8OE' | OUT == '8OS' | OUT == '8ON' | OUT == '8OW' & PEN == '8')
  dayfile.edg <- subset(dayfile, EDG == '8EN' | EDG == '8EW' | EDG == '8ES' | EDG == '8EE' & PEN == '8')
  dayfile.hidc <- subset(dayfile, BIGC == '8CSW' | BIGC == '8CNE' & PEN == '8' & SEC >= 0)
  dayfile.mtc <- subset(dayfile, BIGC == '8CNW' | BIGC == '8CSE' & PEN == '8' & SEC >= 0)
  dayfile.cen <- subset(dayfile, CEN == '8MH' | CEN == '8MM' | CEN == '8ML' & PEN == '8')
  dayfile.hid <- subset(dayfile, HID == '8WHSW' | HID == '8WHNE' & PEN == '8')
  #location.sum$UnconP8 <- c(nrow(dayfile.bot), nrow(dayfile.top), nrow(dayfile.out), nrow(dayfile.edg), nrow(dayfile.bigc), nrow(dayfile.cen), nrow(dayfile.hid))
  location.sum$UnconP8 <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600)
  location.sum
}

# 2. location summary for multiple day files (adapted to work with all data in one data frame)
batch.locations <- function()
{
  #files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  days <- unique(alldaysfile$date)
  locations.P7 <- data.frame(c('0', '0', '0', '0', '0', '0', '0', '0', '0'))
  colnames(locations.P7) <- 'ID'
  rownames(locations.P7) <- c('P7_<15m', 'P7_>15m', 'P7_outer', 'P7_edge', 'P7_hidecorner', 'P7_emptycorner', 'P7_centre', 'P7_hides', 'P7_feedblock')
  locations.P8 <- data.frame(c('0', '0', '0', '0', '0', '0', '0', '0', '0'))
  colnames(locations.P8) <- 'ID'
  rownames(locations.P8) <- c('P8_<15m', 'P8_>15m', 'P8_outer', 'P8_edge', 'P8_hidecorner', 'P8_emptycorner', 'P8_centre', 'P8_hides', 'P8_feedblock')
  
  #for (i in 1:length(files))
  for (i in 1:length(days))    
  {
    dayfile <- alldaysfile[alldaysfile$date == days[[i]],]
    #dayfile.loc <- files[[i]]
    #dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = dayfile.classes) #
    
    #SORT BY TIME AND TAG
    dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
    dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
    
    # pen 7 location summary
    dayfile.bot <- subset(dayfile, BOT == 'B' & PEN == '7' & SEC >= 0)
    dayfile.top <- subset(dayfile, BOT == 'Z' & PEN == '7' & SEC >= 0)
    dayfile.out <- subset(dayfile, OUT == '7OE' & PEN == '7' & SEC >= 0 | OUT == '7OS' & PEN == '7' & SEC >= 0 | OUT == '7ON' & PEN == '7' & SEC >= 0 | OUT == '7OW' & PEN == '7' & SEC >= 0)
    dayfile.edg <- subset(dayfile, EDG == '7EN' & PEN == '7' & SEC >= 0 | EDG == '7EW' & PEN == '7' & SEC >= 0 | EDG == '7ES' & PEN == '7' & SEC >= 0 | EDG == '7EE' & PEN == '7' & SEC >= 0)
    dayfile.hidc <- subset(dayfile, BIGC == '7CNW' & PEN == '7' & SEC >= 0 | BIGC == '7CSE' & PEN == '7' & SEC >= 0)
    dayfile.mtc <- subset(dayfile, BIGC == '7CSW' & PEN == '7' & SEC >= 0 | BIGC == '7CNE' & PEN == '7' & SEC >= 0)
    dayfile.cen <- subset(dayfile, CEN == '7MH' & PEN == '7' & SEC >= 0 | CEN == '7MM' & PEN == '7' & SEC >= 0 | CEN == '7ML' & PEN == '7' & SEC >= 0)
    dayfile.hid <- subset(dayfile, HID == '7WHSE' & PEN == '7' & SEC >= 0 | HID == '7WHNW' & PEN == '7' & SEC >= 0)
    dayfile.fdb <- subset(dayfile, FDB == '7FBSE'  & PEN == '7' & SEC >= 0| FDB == '7FBNW' & PEN == '7' & SEC >= 0)
    locations.P7[,as.character(i)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
    
    # pen 8 location summary
    dayfile.bot <- subset(dayfile, BOT == 'B' & SEC >= 0 & PEN == '8' & SEC >= 0)
    dayfile.top <- subset(dayfile, BOT == 'Z' & PEN == '8' & SEC >= 0)
    dayfile.out <- subset(dayfile, OUT == '8OE' & PEN == '8' & SEC >= 0| OUT == '8OS' & PEN == '8' & SEC >= 0 | OUT == '8ON' & PEN == '8' & SEC >= 0 | OUT == '8OW' & PEN == '8' & SEC >= 0)
    dayfile.edg <- subset(dayfile, EDG == '8EN' & PEN == '8' & SEC >= 0 | EDG == '8EW' & PEN == '8' & SEC >= 0 | EDG == '8ES' & PEN == '8' & SEC >= 0 | EDG == '8EE' & PEN == '8' & SEC >= 0)
    dayfile.hidc <- subset(dayfile, BIGC == '8CSW' & PEN == '8' & SEC >= 0 | BIGC == '8CNE' & PEN == '8' & SEC >= 0)
    dayfile.mtc <- subset(dayfile, BIGC == '8CNW' & PEN == '8' & SEC >= 0 | BIGC == '8CSE' & PEN == '8' & SEC >= 0)
    dayfile.cen <- subset(dayfile, CEN == '8MH' & PEN == '8' & SEC >= 0 | CEN == '8MM' & PEN == '8' & SEC >= 0 | CEN == '8ML' & PEN == '8' & SEC >= 0)
    dayfile.hid <- subset(dayfile, HID == '8WHSW' & PEN == '8' & SEC >= 0 | HID == '8WHNE' & PEN == '8' & SEC >= 0)
    dayfile.fdb <- subset(dayfile, FDB == '8FBSW' & PEN == '8' & SEC >= 0 | FDB == '8FBNE' & PEN == '8' & SEC >= 0)
    locations.P8[,as.character(i)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
    
  }
  location.sum <- rbind(locations.P7, locations.P8)  
  location.sum$ID <- NULL
  location.sum  
  
  #loadWorkbook('LocationsOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('LocationsOutput.xlsx', location.sum, 'Sheet 1')
  write.csv(location.sum, 'LocationsOutput.csv')
  #write.xlsx(location.sum, 'LocationsOutput.xlsx')
}


# 2. location summary for multiple day files. type = 'batch', 'days', or 'fish'

batch.locations <- function(type)
{
  
  locations.P7 <- data.frame(c('0', '0', '0', '0', '0', '0', '0', '0', '0'))
  colnames(locations.P7) <- 'ID'
  rownames(locations.P7) <- c('P7_<15m', 'P7_>15m', 'P7_outer', 'P7_edge', 'P7_hidecorner', 'P7_emptycorner', 'P7_centre', 'P7_hides', 'P7_feedblock')
  locations.P8 <- data.frame(c('0', '0', '0', '0', '0', '0', '0', '0', '0'))
  colnames(locations.P8) <- 'ID'
  rownames(locations.P8) <- c('P8_<15m', 'P8_>15m', 'P8_outer', 'P8_edge', 'P8_hidecorner', 'P8_emptycorner', 'P8_centre', 'P8_hides', 'P8_feedblock')
  
  get.locations7 <- function(){
    # pen 7 location summary
    dayfile.bot <<- subset(cutfile, BOT == 'B' & PEN == '7' & SEC >= 0)
    dayfile.top <<- subset(cutfile, BOT == 'Z' & PEN == '7' & SEC >= 0)
    dayfile.out <<- subset(cutfile, OUT == '7OE'  & PEN == '7' & SEC >= 0 | OUT == '7OS' & PEN == '7' & SEC >= 0 | OUT == '7ON' & PEN == '7' & SEC >= 0 | OUT == '7OW' & PEN == '7' & SEC >= 0)
    dayfile.edg <<- subset(cutfile, EDG == '7EN' & PEN == '7' & SEC >= 0 | EDG == '7EW' & PEN == '7' & SEC >= 0 | EDG == '7ES' & PEN == '7' & SEC >= 0 | EDG == '7EE' & PEN == '7' & SEC >= 0)
    dayfile.hidc <<- subset(cutfile, BIGC == '7CSE' & PEN == '7' & SEC >= 0 | BIGC == '7CNW' & PEN == '7' & SEC >= 0)
    dayfile.mtc <<- subset(cutfile, BIGC == '7CSW' & PEN == '7' & SEC >= 0 | BIGC == '7CNE' & PEN == '7' & SEC >= 0)
    dayfile.cen <<- subset(cutfile, CEN == '7MH' & PEN == '7' & SEC >= 0 | CEN == '7MM' & PEN == '7' & SEC >= 0 | CEN == '7ML' & PEN == '7' & SEC >= 0)
    dayfile.hid <<- subset(cutfile, HID == '7WHSE' & PEN == '7' & SEC >= 0 | HID == '7WHNW' & PEN == '7' & SEC >= 0)
    dayfile.fdb <<- subset(cutfile, FDB == '7FBSE' & PEN == '7' & SEC >= 0 | FDB == '7FBNW' & PEN == '7')
    #locations.P7[,as.character(i)] <<- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
  }
  
  get.locations8 <- function(){ 
    # pen 8 location summary
    dayfile.bot <<- subset(cutfile, BOT == 'B' & PEN == '8' & SEC >= 0)
    dayfile.top <<- subset(cutfile, BOT == 'Z' & PEN == '8' & SEC >= 0)
    dayfile.out <<- subset(cutfile, OUT == '8OE' & PEN == '8' & SEC >= 0 | OUT == '8OS' & PEN == '8' & SEC >= 0 | OUT == '8ON' & PEN == '8' & SEC >= 0 | OUT == '8OW' & PEN == '8' & SEC >= 0)
    dayfile.edg <<- subset(cutfile, EDG == '8EN' & PEN == '8' & SEC >= 0 | EDG == '8EW' & PEN == '8' & SEC >= 0 | EDG == '8ES' & PEN == '8' & SEC >= 0 | EDG == '8EE' & PEN == '8' & SEC >= 0)
    dayfile.hidc <<- subset(cutfile, BIGC == '8CSW' & PEN == '8' & SEC >= 0 | BIGC == '8CNE' & PEN == '8' & SEC >= 0)
    dayfile.mtc <<- subset(cutfile, BIGC == '8CNW' & PEN == '8' & SEC >= 0 | BIGC == '8CSE' & PEN == '8' & SEC >= 0)
    dayfile.cen <<- subset(cutfile, CEN == '8MH' & PEN == '8' & SEC >= 0 | CEN == '8MM' & PEN == '8' & SEC >= 0 | CEN == '8ML' & PEN == '8' & SEC >= 0)
    dayfile.hid <<- subset(cutfile, HID == '8WHSW' & PEN == '8' & SEC >= 0 | HID == '8WHNE' & PEN == '8' & SEC >= 0)
    dayfile.fdb <<- subset(cutfile, FDB == '8FBSW' & PEN == '8' & SEC >= 0 | FDB == '8FBNE' & PEN == '8')
    #locations.P8[,as.character(i)] <<- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
    
  }
  
  if(type == 'batch'){ # dayfiles in seperate files code
    
    files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)  
    
    for (i in 1:length(files))
    {
      dayfile.loc <- files[[i]]
      cutfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = dayfile.classes)
      
      #SORT BY TIME AND TAG
      cutfile <- cutfile[order(cutfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
      cutfile <- cutfile[order(cutfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
      
      get.locations7()
      locations.P7[,as.character(i)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
      
      get.locations8()
      locations.P8[,as.character(i)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
      
    }
    
  } else { 
    
    if(type == 'days'){
      
      days <- c(paste0(sort(unique(as.Date(dayfile$EchoTime))), ' 00:00:00'), paste0(max(unique(as.Date(dayfile$EchoTime)))+days(1), ' 00:00:00'))
      
      for(d in 1:length(days)-1){
        
        cutfile <- dayfile[dayfile$EchoTime > days[d] & dayfile$EchoTime < days[d+1],] 
        
        get.locations7()
        locations.P7[,as.character(d)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
        
        get.locations8()
        locations.P8[,as.character(d)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
        
      }
      
    } else { # type == 'fish'
      
      fish <- sort(unique(dayfile$Period))
      
      for(f in 1:length(fish)){
        
        cutfile <- dayfile[dayfile$Period == fish[f],]
        
        get.locations7()
        locations.P7[,as.character(f)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
        
        get.locations8()
        locations.P8[,as.character(f)] <- c(sum(dayfile.bot$SEC, na.rm = T)/3600, sum(dayfile.top$SEC, na.rm = T)/3600, sum(dayfile.out$SEC, na.rm = T)/3600, sum(dayfile.edg$SEC, na.rm = T)/3600, sum(dayfile.hidc$SEC, na.rm = T)/3600, sum(dayfile.mtc$SEC, na.rm = T)/3600, sum(dayfile.cen$SEC, na.rm = T)/3600, sum(dayfile.hid$SEC, na.rm = T)/3600, sum(dayfile.fdb$SEC, na.rm = T)/3600)
        
      }
      
      
    }
    
  }
  
  location.sum <- rbind(locations.P7, locations.P8)  
  location.sum$ID <- NULL
  location.sum  
  
  #loadWorkbook('LocationsOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('LocationsOutput.xlsx', location.sum, 'Sheet 1')
  
  write.csv(location.sum, 'LocationsOutput.csv')
}



# 3a. depth and activity summary
depact <- function()
{
  day <- subset(dayfile, SUN == 'D' & PEN == '7')
  night <- subset(dayfile, SUN == 'N' & PEN == '7')
  depact.sum <- data.frame(c(format(mean(day$PosZ), digits = 4), format(mean(night$PosZ), digits = 4), format(mean(day$MSEC), digits = 4), format(mean(night$MSEC), digits = 4)))
  rownames(depact.sum) <- c('mean depth day (m)', 'mean depth night (m)', 'mean activity day (BL/sec)', 'mean activity night (BL/sec)')
  colnames(depact.sum) <- 'mean.ConP7'
  depact.sum$sd.conP7 <-c(format(sd(day$PosZ), digits = 4), format(sd(night$PosZ), digits = 4), format(sd(day$MSEC), digits = 4), format(sd(night$MSEC), digits = 4))
  
  
  day <- subset(dayfile, SUN == 'D' & PEN == '8')
  night <- subset(dayfile, SUN == 'N' & PEN == '8')
  depact.sum$mean.UnconP8 <-c(format(mean(day$PosZ), digits = 4), format(mean(night$PosZ), digits = 4), format(mean(day$MSEC), digits = 4), format(mean(night$MSEC), digits = 4))
  depact.sum$sd.conP8 <-c(format(sd(day$PosZ), digits = 4), format(sd(night$PosZ), digits = 4), format(sd(day$MSEC), digits = 4), format(sd(night$MSEC), digits = 4))
  depact.sum
}


# 3b. depth and activity summary
depact.se <- function()
{
  day <- subset(dayfile, SUN == 'D' & PEN == '7')
  night <- subset(dayfile, SUN == 'N' & PEN == '7')
  depact.sum <- data.frame(c(format(mean(day$PosZ), digits = 4), format(mean(night$PosZ), digits = 4), format(mean(day$MSEC), digits = 4), format(mean(night$MSEC), digits = 4)))
  rownames(depact.sum) <- c('mean depth day (m)', 'mean depth night (m)', 'mean activity day (BL/sec)', 'mean activity night (BL/sec)')
  colnames(depact.sum) <- 'mean.ConP7'
  depact.sum$sd.conP7 <-c(format(sd(day$PosZ)/sqrt(length(day$PosZ)), digits = 4), format(sd(night$PosZ)/sqrt(length(night$PosZ)), digits = 4), format(sd(day$MSEC)/sqrt(length(day$MSEC)), digits = 4), format(sd(night$MSEC)/sqrt(length(night$MSEC)), digits = 4))
  
  
  day <- subset(dayfile, SUN == 'D' & PEN == '8')
  night <- subset(dayfile, SUN == 'N' & PEN == '8')
  depact.sum$mean.UnconP8 <-c(format(mean(day$PosZ), digits = 4), format(mean(night$PosZ), digits = 4), format(mean(day$MSEC), digits = 4), format(mean(night$MSEC), digits = 4))
  depact.sum$sd.conP8 <-c(format(sd(day$PosZ)/sqrt(length(day$PosZ)), digits = 4), format(sd(night$PosZ)/sqrt(length(night$PosZ)), digits = 4), format(sd(day$MSEC)/sqrt(length(day$MSEC)), digits = 4), format(sd(night$MSEC)/sqrt(length(night$MSEC)), digits = 4))
  depact.sum
}

# 4. function to return depth summary for each fish

depth.sum <- function(){
  sumfunc <- function(x){ c(min = min(x), max = max(x), range = max(x)-min(x), mean = mean(x), median = median(x), std = sd(x)) }
  depth.sum.tab <- cbind(Period = unique(dayfile$Period), do.call(rbind, tapply(dayfile$PosZ, dayfile$Period, sumfunc)))
  print(depth.sum.tab)
}


# 5. batch function to return matrix of mean and standard deviation depths for individual fish over multiple days

batch.depth <- function(){
  
  sumfunc <- function(x){ c(min = min(x), max = max(x), range = max(x)-min(x), mean = mean(x), median = median(x), std = sd(x)) }
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  depths.P7 <- data.frame(c('P7_dawn_mean', 'P7_dawn_stdev', 'P7_day_mean', 'P7_day_stdev', 'P7_dusk_mean', 'P7_dusk_stdev', 'P7_night_mean', 'P7_night_stdev'))
  colnames(depths.P7) <- 'ID'
  rownames(depths.P7) <- c('P7_dawn_mean', 'P7_dawn_stdev', 'P7_day_mean', 'P7_day_stdev', 'P7_dusk_mean', 'P7_dusk_stdev', 'P7_night_mean', 'P7_night_stdev')
  depths.P8 <- data.frame(c('P8_dawn_mean', 'P8_dawn_stdev', 'P8_day_mean', 'P8_day_stdev', 'P8_dusk_mean', 'P8_dusk_stdev', 'P8_night_mean', 'P8_night_stdev'))
  colnames(depths.P8) <- 'ID'
  rownames(depths.P8) <- c('P8_dawn_mean', 'P8_dawn_stdev', 'P8_day_mean', 'P8_day_stdev', 'P8_dusk_mean', 'P8_dusk_stdev', 'P8_night_mean', 'P8_night_stdev')
  
  for (i in 1:length(files))
  {
    dayfile.loc <- files[[i]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                        (
                        'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                        )) #read data into table
    
    
    depths.dawn <- subset(dayfile, SUN == 'W' & PEN == '7')
    depths.day <- subset(dayfile, SUN == 'D' & PEN == '7')
    depths.dusk <- subset(dayfile, SUN == 'K' & PEN == '7')
    depths.night <- subset(dayfile, SUN == 'N' & PEN == '7')
    dawn.sum <- cbind(Period = unique(depths.dawn$Period), do.call(rbind, tapply(depths.dawn$PosZ, depths.dawn$Period, sumfunc)))
    day.sum <- cbind(Period = unique(depths.day$Period), do.call(rbind, tapply(depths.day$PosZ, depths.day$Period, sumfunc)))
    dusk.sum <- cbind(Period = unique(depths.dusk$Period), do.call(rbind, tapply(depths.dusk$PosZ, depths.dusk$Period, sumfunc)))
    night.sum <- cbind(Period = unique(depths.night$Period), do.call(rbind, tapply(depths.night$PosZ, depths.night$Period, sumfunc)))
    dawn.sum[is.na(dawn.sum)] <- 0
    day.sum[is.na(day.sum)] <- 0
    dusk.sum[is.na(dusk.sum)] <- 0
    night.sum[is.na(night.sum)] <- 0
    depths.P7[,as.character(i)] <- c(mean(dawn.sum[,'mean']), mean(dawn.sum[,'std']), mean(day.sum[,'mean']), mean(day.sum[,'std']), mean(dusk.sum[,'mean']), mean(dusk.sum[,'std']), mean(night.sum[,'mean']), mean(night.sum[,'std']))
    
    depths.dawn <- subset(dayfile, SUN == 'W' & PEN == '8')
    depths.day <- subset(dayfile, SUN == 'D' & PEN == '8')
    depths.dusk <- subset(dayfile, SUN == 'K' & PEN == '8')
    depths.night <- subset(dayfile, SUN == 'N' & PEN == '8')
    dawn.sum <- cbind(Period = unique(depths.dawn$Period), do.call(rbind, tapply(depths.dawn$PosZ, depths.dawn$Period, sumfunc)))
    day.sum <- cbind(Period = unique(depths.day$Period), do.call(rbind, tapply(depths.day$PosZ, depths.day$Period, sumfunc)))
    dusk.sum <- cbind(Period = unique(depths.dusk$Period), do.call(rbind, tapply(depths.dusk$PosZ, depths.dusk$Period, sumfunc)))
    night.sum <- cbind(Period = unique(depths.night$Period), do.call(rbind, tapply(depths.night$PosZ, depths.night$Period, sumfunc)))
    dawn.sum[is.na(dawn.sum)] <- 0
    day.sum[is.na(day.sum)] <- 0
    dusk.sum[is.na(dusk.sum)] <- 0
    night.sum[is.na(night.sum)] <- 0
    depths.P8[,as.character(i)] <- c(mean(dawn.sum[,'mean']), mean(dawn.sum[,'std']), mean(day.sum[,'mean']), mean(day.sum[,'std']), mean(dusk.sum[,'mean']), mean(dusk.sum[,'std']), mean(night.sum[,'mean']), mean(night.sum[,'std']))
  }
  
  depths.sum <- rbind(depths.P7, depths.P8)  
  #depths.sum$ID <- NULL
  depths.sum    
  loadWorkbook('DepthsOutput.xlsx', create = TRUE)
  writeWorksheetToFile('DepthsOutput.xlsx', depths.sum, 'Sheet 1')
}


# 6. batch function to return matrix of mean and standard error depths for all fish combined over multiple days

batch.totdepth <- function(type){
  
  sumfunc <- function(x){ c(min = min(x), max = max(x), range = max(x)-min(x), mean = mean(x), median = median(x), std = sd(x)) }
  
  depth.P7 <- data.frame(c('P7_dawn_mean', 'P7_dawn_se', 'P7_day_mean', 'P7_day_se', 'P7_dusk_mean', 'P7_dusk_se', 'P7_night_mean', 'P7_night_se'))
  colnames(depth.P7) <- 'ID'
  rownames(depth.P7) <- c('P7_dawn_mean', 'P7_dawn_se', 'P7_day_mean', 'P7_day_se', 'P7_dusk_mean', 'P7_dusk_se', 'P7_night_mean', 'P7_night_se')
  depth.P8 <- data.frame(c('P8_dawn_mean', 'P8_dawn_se', 'P8_day_mean', 'P8_day_se', 'P8_dusk_mean', 'P8_dusk_se', 'P8_night_mean', 'P8_night_se'))
  colnames(depth.P8) <- 'ID'
  rownames(depth.P8) <- c('P8_dawn_mean', 'P8_dawn_se', 'P8_day_mean', 'P8_day_se', 'P8_dusk_mean', 'P8_dusk_se', 'P8_night_mean', 'P8_night_se')
  
  
  if(type == 'batch'){  
    
    files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)  
    
    for (i in 1:length(files))
    {
      dayfile.loc <- files[[i]]
      dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = dayfile.classes) 
      
      
      depth.dawn <- subset(dayfile, SUN == 'W' & PEN == '7')
      depth.day <- subset(dayfile, SUN == 'D' & PEN == '7')
      depth.dusk <- subset(dayfile, SUN == 'K' & PEN == '7')
      depth.night <- subset(dayfile, SUN == 'N' & PEN == '7')
      depth.P7[,as.character(i)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
      
      depth.dawn <- subset(dayfile, SUN == 'W' & PEN == '8')
      depth.day <- subset(dayfile, SUN == 'D' & PEN == '8')
      depth.dusk <- subset(dayfile, SUN == 'K' & PEN == '8')
      depth.night <- subset(dayfile, SUN == 'N' & PEN == '8')
      depth.P8[,as.character(i)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
    }
    
  } else {
    
    if(type == 'day'){
      
      days <- c(paste0(sort(unique(as.Date(dayfile$EchoTime))), ' 00:00:00'), paste0(max(unique(as.Date(dayfile$EchoTime)))+days(1), ' 00:00:00'))
      
      for(d in 1:length(days)-1){
        
        daycut <- dayfile[dayfile$EchoTime > days[d] & dayfile$EchoTime < days[d+1],]
        
        depth.dawn <- subset(daycut, SUN == 'W' & PEN == '7')
        depth.day <- subset(daycut, SUN == 'D' & PEN == '7')
        depth.dusk <- subset(daycut, SUN == 'K' & PEN == '7')
        depth.night <- subset(daycut, SUN == 'N' & PEN == '7')
        depth.P7[,as.character(d)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
        
        depth.dawn <- subset(daycut, SUN == 'W' & PEN == '8')
        depth.day <- subset(daycut, SUN == 'D' & PEN == '8')
        depth.dusk <- subset(daycut, SUN == 'K' & PEN == '8')
        depth.night <- subset(daycut, SUN == 'N' & PEN == '8')
        depth.P8[,as.character(d)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
        
      }
      
    } else { # else type == fish
      
      fish <- sort(unique(dayfile$Period))
      
      for(f in 1:length(fish)){
        
        fishcut <- dayfile[dayfile$Period == fish[f],]
        
        depth.dawn <- subset(fishcut, SUN == 'W' & PEN == '7')
        depth.day <- subset(fishcut, SUN == 'D' & PEN == '7')
        depth.dusk <- subset(fishcut, SUN == 'K' & PEN == '7')
        depth.night <- subset(fishcut, SUN == 'N' & PEN == '7')
        depth.P7[,as.character(f)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
        
        depth.dawn <- subset(fishcut, SUN == 'W' & PEN == '8')
        depth.day <- subset(fishcut, SUN == 'D' & PEN == '8')
        depth.dusk <- subset(fishcut, SUN == 'K' & PEN == '8')
        depth.night <- subset(fishcut, SUN == 'N' & PEN == '8')
        depth.P8[,as.character(f)] <- c(mean(depth.dawn$PosZ), sd(depth.dawn$PosZ)/sqrt(length(depth.dawn)), mean(depth.day$PosZ), sd(depth.day$PosZ)/sqrt(length(depth.day)), mean(depth.dusk$PosZ), sd(depth.dusk$PosZ)/sqrt(length(depth.dusk)), mean(depth.night$PosZ), sd(depth.night$PosZ)/sqrt(length(depth.night)))
        
      }
      
    }
    
  }
  
  depths.sum <- rbind(depth.P7, depth.P8)  
  #depths.sum$ID <- NULL
  depths.sum    
  #loadWorkbook('DepthTotOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('DepthTotOutput.xlsx', depths.sum, 'Sheet 1')
  
  write.csv(depths.sum, 'DepthTotOutput.csv')
}



# 7. batch function to return matrix of mean and standard deviation activity for individual fish over multiple days

batch.activity <- function(){
  
  sumfunc <- function(x){ c(min = min(x), max = max(x), range = max(x)-min(x), mean = mean(x), median = median(x), std = sd(x)) }
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  activity.P7 <- data.frame(c('P7_dawn_mean', 'P7_dawn_stdev', 'P7_day_mean', 'P7_day_stdev', 'P7_dusk_mean', 'P7_dusk_stdev', 'P7_night_mean', 'P7_night_stdev'))
  colnames(activity.P7) <- 'ID'
  rownames(activity.P7) <- c('P7_dawn_mean', 'P7_dawn_stdev', 'P7_day_mean', 'P7_day_stdev', 'P7_dusk_mean', 'P7_dusk_stdev', 'P7_night_mean', 'P7_night_stdev')
  activity.P8 <- data.frame(c('P8_dawn_mean', 'P8_dawn_stdev', 'P8_day_mean', 'P8_day_stdev', 'P8_dusk_mean', 'P8_dusk_stdev', 'P8_night_mean', 'P8_night_stdev'))
  colnames(activity.P8) <- 'ID'
  rownames(activity.P8) <- c('P8_dawn_mean', 'P8_dawn_stdev', 'P8_day_mean', 'P8_day_stdev', 'P8_dusk_mean', 'P8_dusk_stdev', 'P8_night_mean', 'P8_night_stdev')
  
  for (i in 1:length(files))
  {
    dayfile.loc <- files[[i]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                        (
                        'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                        )) #read data into table
    
    
    activity.dawn <- subset(dayfile, SUN == 'W' & PEN == '7')
    activity.day <- subset(dayfile, SUN == 'D' & PEN == '7')
    activity.dusk <- subset(dayfile, SUN == 'K' & PEN == '7')
    activity.night <- subset(dayfile, SUN == 'N' & PEN == '7')
    dawn.sum <- cbind(Period = unique(activity.dawn$Period), do.call(rbind, tapply(activity.dawn$BLSEC, activity.dawn$Period, sumfunc)))
    day.sum <- cbind(Period = unique(activity.day$Period), do.call(rbind, tapply(activity.day$BLSEC, activity.day$Period, sumfunc)))
    dusk.sum <- cbind(Period = unique(activity.dusk$Period), do.call(rbind, tapply(activity.dusk$BLSEC, activity.dusk$Period, sumfunc)))
    night.sum <- cbind(Period = unique(activity.night$Period), do.call(rbind, tapply(activity.night$BLSEC, activity.night$Period, sumfunc)))
    dawn.sum[is.na(dawn.sum)] <- 0
    day.sum[is.na(day.sum)] <- 0
    dusk.sum[is.na(dusk.sum)] <- 0
    night.sum[is.na(night.sum)] <- 0
    activity.P7[,as.character(i)] <- c(mean(dawn.sum[,'mean']), mean(dawn.sum[,'std']), mean(day.sum[,'mean']), mean(day.sum[,'std']), mean(dusk.sum[,'mean']), mean(dusk.sum[,'std']), mean(night.sum[,'mean']), mean(night.sum[,'std']))
    
    activity.dawn <- subset(dayfile, SUN == 'W' & PEN == '8')
    activity.day <- subset(dayfile, SUN == 'D' & PEN == '8')
    activity.dusk <- subset(dayfile, SUN == 'K' & PEN == '8')
    activity.night <- subset(dayfile, SUN == 'N' & PEN == '8')
    dawn.sum <- cbind(Period = unique(activity.dawn$Period), do.call(rbind, tapply(activity.dawn$BLSEC, activity.dawn$Period, sumfunc)))
    day.sum <- cbind(Period = unique(activity.day$Period), do.call(rbind, tapply(activity.day$BLSEC, activity.day$Period, sumfunc)))
    dusk.sum <- cbind(Period = unique(activity.dusk$Period), do.call(rbind, tapply(activity.dusk$BLSEC, activity.dusk$Period, sumfunc)))
    night.sum <- cbind(Period = unique(activity.night$Period), do.call(rbind, tapply(activity.night$BLSEC, activity.night$Period, sumfunc)))
    dawn.sum[is.na(dawn.sum)] <- 0
    day.sum[is.na(day.sum)] <- 0
    dusk.sum[is.na(dusk.sum)] <- 0
    night.sum[is.na(night.sum)] <- 0
    activity.P8[,as.character(i)] <- c(mean(dawn.sum[,'mean']), mean(dawn.sum[,'std']), mean(day.sum[,'mean']), mean(day.sum[,'std']), mean(dusk.sum[,'mean']), mean(dusk.sum[,'std']), mean(night.sum[,'mean']), mean(night.sum[,'std']))
  }
  
  activity.sum <- rbind(activity.P7, activity.P8)  
  #depths.sum$ID <- NULL
  activity.sum    
  #loadWorkbook('ActivityOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('ActivityOutput.xlsx', activity.sum, 'Sheet 1')
  
  write.xlsx(activity.sum, 'ActivityOutput.xlsx')
}


# 8. batch function to return matrix of mean and standard error activity for all fish combined over multiple days

batch.totactivity <- function(type){
  
  sumfunc <- function(x){ c(min = min(x), max = max(x), range = max(x)-min(x), mean = mean(x), median = median(x), std = sd(x)) }
  
  activity.P7 <- data.frame(c('P7_dawn_mean', 'P7_dawn_se', 'P7_day_mean', 'P7_day_se', 'P7_dusk_mean', 'P7_dusk_se', 'P7_night_mean', 'P7_night_se'))
  colnames(activity.P7) <- 'ID'
  rownames(activity.P7) <- c('P7_dawn_mean', 'P7_dawn_se', 'P7_day_mean', 'P7_day_se', 'P7_dusk_mean', 'P7_dusk_se', 'P7_night_mean', 'P7_night_se')
  activity.P8 <- data.frame(c('P8_dawn_mean', 'P8_dawn_se', 'P8_day_mean', 'P8_day_se', 'P8_dusk_mean', 'P8_dusk_se', 'P8_night_mean', 'P8_night_se'))
  colnames(activity.P8) <- 'ID'
  rownames(activity.P8) <- c('P8_dawn_mean', 'P8_dawn_se', 'P8_day_mean', 'P8_day_se', 'P8_dusk_mean', 'P8_dusk_se', 'P8_night_mean', 'P8_night_se')
  
  if(type == 'batch'){
    
    files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
    
    for (i in 1:length(files))
    {
      dayfile.loc <- files[[i]]
      dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = dayfile.classes) 
      
      activity.dawn <- subset(dayfile, SUN == 'W' & PEN == '7')
      activity.day <- subset(dayfile, SUN == 'D' & PEN == '7')
      activity.dusk <- subset(dayfile, SUN == 'K' & PEN == '7')
      activity.night <- subset(dayfile, SUN == 'N' & PEN == '7')
      activity.P7[,as.character(i)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
      
      activity.dawn <- subset(dayfile, SUN == 'W' & PEN == '8')
      activity.day <- subset(dayfile, SUN == 'D' & PEN == '8')
      activity.dusk <- subset(dayfile, SUN == 'K' & PEN == '8')
      activity.night <- subset(dayfile, SUN == 'N' & PEN == '8')
      activity.P8[,as.character(i)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
    }
    
    activity.sum <- rbind(activity.P7, activity.P8)  
    activity.sum    
    write.csv(activity.sum, 'ActivityTotOutput.csv')
    
    
  } else {
    
    if(type == 'days'){
      
      days <- c(paste0(sort(unique(as.Date(dayfile$EchoTime))), ' 00:00:00'), paste0(max(unique(as.Date(dayfile$EchoTime)))+days(1), ' 00:00:00'))
      
      for(d in 1:length(days)-1){
        
        daycut <- dayfile[dayfile$EchoTime > days[d] & dayfile$EchoTime < days[d+1],] 
        
        activity.dawn <- subset(daycut, SUN == 'W' & PEN == '7')
        activity.day <- subset(daycut, SUN == 'D' & PEN == '7')
        activity.dusk <- subset(daycut, SUN == 'K' & PEN == '7')
        activity.night <- subset(daycut, SUN == 'N' & PEN == '7')
        activity.P7[,as.character(d)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
        
        activity.dawn <- subset(daycut, SUN == 'W' & PEN == '8')
        activity.day <- subset(daycut, SUN == 'D' & PEN == '8')
        activity.dusk <- subset(daycut, SUN == 'K' & PEN == '8')
        activity.night <- subset(daycut, SUN == 'N' & PEN == '8')
        activity.P8[,as.character(d)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
        
      }
      
      activity.sum <- rbind(activity.P7, activity.P8)  
      activity.sum    
      write.csv(activity.sum, 'ActivityTotOutput-days.csv')
      
      
    } else { # else type == 'fish'
      
      fish <- sort(unique(dayfile$Period))
      
      for(f in 1:length(fish)){
        
        fishcut <- dayfile[dayfile$Period == fish[f],]
        
        activity.dawn <- subset(fishcut, SUN == 'W' & PEN == '7')
        activity.day <- subset(fishcut, SUN == 'D' & PEN == '7')
        activity.dusk <- subset(fishcut, SUN == 'K' & PEN == '7')
        activity.night <- subset(fishcut, SUN == 'N' & PEN == '7')
        activity.P7[,as.character(f)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
        
        activity.dawn <- subset(fishcut, SUN == 'W' & PEN == '8')
        activity.day <- subset(fishcut, SUN == 'D' & PEN == '8')
        activity.dusk <- subset(fishcut, SUN == 'K' & PEN == '8')
        activity.night <- subset(fishcut, SUN == 'N' & PEN == '8')
        activity.P8[,as.character(f)] <- c(mean(activity.dawn$BLSEC, na.rm = T), sd(activity.dawn$BLSEC, na.rm = T)/sqrt(length(activity.dawn)), mean(activity.day$BLSEC, na.rm = T), sd(activity.day$BLSEC, na.rm = T)/sqrt(length(activity.day)), mean(activity.dusk$BLSEC, na.rm = T), sd(activity.dusk$BLSEC, na.rm = T)/sqrt(length(activity.dusk)), mean(activity.night$BLSEC, na.rm = T), sd(activity.night$BLSEC, na.rm = T)/sqrt(length(activity.night)))
        
      }
      
      activity.sum <- rbind(activity.P7, activity.P8)  
      activity.sum    
      write.csv(activity.sum, 'ActivityTotOutput-fish.csv')
      
      
    }
  }  
  
  #activity.sum <- rbind(activity.P7, activity.P8)  
  #activity.sum    
  #write.csv(activity.sum, 'ActivityTotOutput.csv')
}


# 9a. proportion coverage

prop.coverage <- function(xmin7 = 15, xmax7 = 39, ymin7 = 15, ymax7 = 39, xmin8 = 41, xmax8 = 65, ymin8 = 15, ymax8 = 39, boxsize = 0.3) {
  fish.id <- subset(dayfile, PEN == '7')
  x.grid <- floor((fish.id$PosX - xmin7) / boxsize) + 1
  y.grid <- floor((fish.id$PosY - ymin7) / boxsize) + 1
  x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
  y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  eg <- expand.grid(t.y,t.x)
  grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
  coverage.P7 <- matrix(c(length(which(grid.cov > 0)), length(grid.cov), length(which(grid.cov > 0))/length(grid.cov)), ncol = 3)
  colnames(coverage.P7) <- c('occupied', 'total', 'proportion')
  
  fish.id <- subset(dayfile, PEN == '8')
  x.grid <- floor((fish.id$PosX - xmin8) / boxsize) + 1
  y.grid <- floor((fish.id$PosY - ymin8) / boxsize) + 1
  x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
  y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  eg <- expand.grid(t.y,t.x)
  grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
  coverage.P8 <- matrix(c(length(which(grid.cov > 0)), length(grid.cov), length(which(grid.cov > 0))/length(grid.cov)), ncol = 3)
  colnames(coverage.P8) <- c('occupied', 'total', 'proportion')
  
  coverage <- rbind(coverage.P7, coverage.P8) 
  rownames(coverage) <- c('P7', 'P8')
  coverage
}



# 9b. mean proportion coverage per hour

hmean.prop.coverage <- function(xmin7 = 15, xmax7 = 39, ymin7 = 15, ymax7 = 39, xmin8 = 41, xmax8 = 65, ymin8 = 15, ymax8 = 39, boxsize = 0.3) {
  
  fish.id <- subset(dayfile, PEN == '7')
  
  fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
  starttime <- fish.id[1,'EchoTime']-seconds(1)
  nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
  fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
  
  occupied <- numeric()
  total <- numeric()
  proportion <- numeric()
  
  for (i in 1:nhours){
  
  hoursub <- fish.id[fish.id$EchoTime >starttime & fish.id$EchoTime <starttime+hours(1),]   
    
  x.grid <- floor((hoursub$PosX - xmin7) / boxsize) + 1
  y.grid <- floor((hoursub$PosY - ymin7) / boxsize) + 1
  x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
  y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  eg <- expand.grid(t.y,t.x)
  grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
  occupied <- c(occupied, length(which(grid.cov > 0)))
  total <- c(total, length(grid.cov))
  proportion <- c(proportion, length(which(grid.cov > 0))/length(grid.cov))
  
  starttime <- starttime+hours(1)
  
  }

  coverage.P7 <- matrix(c(mean(occupied), mean(total), mean(proportion)), ncol = 3)
  colnames(coverage.P7) <- c('occupied', 'total', 'proportion')
  
  
  fish.id <- subset(dayfile, PEN == '8')
    
  fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
  
  starttime <- fish.id[1,'EchoTime']-seconds(1)
  nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
  
  fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
  
  occupied <- numeric()
  total <- numeric()
  proportion <- numeric()
  
  for (i in 1:nhours){
    
  hoursub <- fish.id[fish.id$EchoTime >starttime & fish.id$EchoTime <starttime+hours(1),]   
  
  x.grid <- floor((hoursub$PosX - xmin8) / boxsize) + 1
  y.grid <- floor((hoursub$PosY - ymin8) / boxsize) + 1
  x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
  y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  eg <- expand.grid(t.y,t.x)
  grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
  
  occupied <- c(occupied, length(which(grid.cov > 0)))
  total <- c(total, length(grid.cov))
  proportion <- c(proportion, length(which(grid.cov > 0))/length(grid.cov))
  
  starttime <- starttime+hours(1)
  
  }
  
  coverage.P8 <- matrix(c(mean(occupied), mean(total), mean(proportion)), ncol = 3)
  colnames(coverage.P8) <- c('occupied', 'total', 'proportion')
  
  coverage <- rbind(coverage.P7, coverage.P8) 
  rownames(coverage) <- c('P7', 'P8')
  coverage
}



# 10a. batch proportion coverage

batch.coverage <- function(xmin7 = 15, xmax7 = 39, ymin7 = 15, ymax7 = 39, xmin8 = 41, xmax8 = 65, ymin8 = 15, ymax8 = 39, boxsize = 0.3) {
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  coverage.P7 <- data.frame(c('P7'))
  colnames(coverage.P7) <- 'ID'
  rownames(coverage.P7) <- c('P7')
  coverage.P8 <- data.frame(c('P8'))
  colnames(coverage.P8) <- 'ID'
  rownames(coverage.P8) <- c('P8')
  
  for (i in 1:length(files))
  {
    dayfile.loc <- files[[i]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                        (
                        'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                        )) #read data into table
    
    if(length(unique(dayfile$Period)) == 1) {
    
      if(unique(dayfile$PEN) == '7'){
      
    fish.id <- subset(dayfile, PEN == '7')
    x.grid <- floor((fish.id$PosX - xmin7) / boxsize) + 1
    y.grid <- floor((fish.id$PosY - ymin7) / boxsize) + 1
    x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
    y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    coverage.P7[,as.character(i)] <-  length(which(grid.cov > 0))/length(grid.cov)
    coverage.P8[,as.character(i)] <- 'NA'
    
      }else{
    
    fish.id <- subset(dayfile, PEN == '8')
    x.grid <- floor((fish.id$PosX - xmin8) / boxsize) + 1
    y.grid <- floor((fish.id$PosY - ymin8) / boxsize) + 1
    x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
    y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    coverage.P8[,as.character(i)] <- length(which(grid.cov > 0))/length(grid.cov)
    coverage.P7[,as.character(i)] <- 'NA'
      }
  }
  
  else {
    
    fish.id <- subset(dayfile, PEN == '7')
    x.grid <- floor((fish.id$PosX - xmin7) / boxsize) + 1
    y.grid <- floor((fish.id$PosY - ymin7) / boxsize) + 1
    x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
    y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    coverage.P7[,as.character(i)] <-  length(which(grid.cov > 0))/length(grid.cov)
    
    fish.id <- subset(dayfile, PEN == '8')
    x.grid <- floor((fish.id$PosX - xmin8) / boxsize) + 1
    y.grid <- floor((fish.id$PosY - ymin8) / boxsize) + 1
    x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
    y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    coverage.P8[,as.character(i)] <- length(which(grid.cov > 0))/length(grid.cov)
    
  }  
    
  }  
    
  coverage <- rbind(coverage.P7, coverage.P8)
  print(coverage)
  #loadWorkbook('CoverageOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('CoverageOutput.xlsx', coverage, 'Sheet 1')
  
  write.xlsx(coverage, 'CoverageOutput.xlsx')
}



# 10b. batch mean proportion coverage per hour

hmean.batch.coverage <- function(xmin7 = 15, xmax7 = 39, ymin7 = 15, ymax7 = 39, xmin8 = 41, xmax8 = 65, ymin8 = 15, ymax8 = 39, boxsize = 0.3) {
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  coverage.P7 <- data.frame(c('P7_mean_coverage', 'P7_sd'))
  colnames(coverage.P7) <- 'ID'
  rownames(coverage.P7) <- c('P7_mean_coverage', 'P7_sd')
  coverage.P8 <- data.frame(c('P8_mean_coverage', 'P8_sd'))
  colnames(coverage.P8) <- 'ID'
  rownames(coverage.P8) <- c('P8_mean_coverage', 'P8_sd')
  
  anova.list <- data.frame('P value')
  colnames(anova.list) <- 'ID'
  rownames(anova.list) <- 'P value'
  
  for (i in 1:length(files))
  {
    dayfile.loc <- files[[i]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                        (
                        'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                        )) #read data into table
    
    if(length(unique(dayfile$Period)) == 1) {
      
      if(unique(dayfile$PEN) == '7'){
        
        fish.id <- subset(dayfile, PEN == '7')
        
        
        fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
        starttime <- fish.id[1,'EchoTime']-seconds(1)
        nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
        fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
        
        proportion.P7 <- numeric()
        
        for (j in 1:nhours){
          
          hoursub <- fish.id[fish.id$EchoTime > starttime & fish.id$EchoTime < starttime+hours(1),]  
          
          if (nrow(hoursub) > 1){
            
            
            x.grid <- floor((hoursub$PosX - xmin7) / boxsize) + 1
            y.grid <- floor((hoursub$PosY - ymin7) / boxsize) + 1
            x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
            y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
            t.x <- sort(unique(x.grid))
            t.y <- sort(unique(y.grid))
            tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
            ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
            t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
            grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
            t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
            t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
            eg <- expand.grid(t.y,t.x)
            grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
            
            proportion.P7 <- c(proportion.P7, length(which(grid.cov > 0))/length(grid.cov))
            
          } else {
            
            proportion.P7 <- c(proportion.P7, 0)  
            
          }
          
          starttime <- starttime+hours(1)
          
        }
        
        proportion.P7[proportion.P7 == 0] <- NA
        #coverage.P7[,as.character(i)] <-  mean(proportion, na.rm = T)
        coverage.P7[,as.character(i)] <-  c(mean(proportion.P7, na.rm = T), sd(proportion.P7, na.rm = T))
        coverage.P8[,as.character(i)] <- c('NA', 'NA')
        
      }else{
        
        fish.id <- subset(dayfile, PEN == '8')
        
        fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
        starttime <- fish.id[1,'EchoTime']-seconds(1)
        nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
        fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
        
        proportion.P8 <- numeric()
        
        for (j in 1:nhours){
          
          hoursub <- fish.id[fish.id$EchoTime >starttime & fish.id$EchoTime <starttime+hours(1),]   
          
          if (nrow(hoursub) > 1){
            
            x.grid <- floor((hoursub$PosX - xmin8) / boxsize) + 1
            y.grid <- floor((hoursub$PosY - ymin8) / boxsize) + 1
            x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
            y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
            t.x <- sort(unique(x.grid))
            t.y <- sort(unique(y.grid))
            tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
            ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
            t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
            grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
            t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
            t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
            eg <- expand.grid(t.y,t.x)
            grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
            
            proportion.P8 <- c(proportion.P8, length(which(grid.cov > 0))/length(grid.cov))
            
          } else {
            
            proportion.P8 <- c(proportion.P8, 0)  
            
          }
          
          
          starttime <- starttime+hours(1)
          
        }
        
        proportion.P8[proportion.P8 == 0] <- NA
        #coverage.P8[,as.character(i)] <-  mean(proportion, na.rm = T)
        coverage.P8[,as.character(i)] <- c(mean(proportion.P8, na.rm = T), sd(proportion.P8, na.rm = T))
        coverage.P7[,as.character(i)] <- c('NA', 'NA')
        
      }
    }
    
    else {
      
      fish.id <- subset(dayfile, PEN == '7')
      
      
      fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
      starttime <- fish.id[1,'EchoTime']-seconds(1)
      nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
      fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
      
      proportion.P7 <- numeric()
      
      for (j in 1:nhours){
        
        hoursub <- fish.id[fish.id$EchoTime > starttime & fish.id$EchoTime < starttime+hours(1),]   
        
        if (nrow(hoursub) > 1){
          
          x.grid <- floor((hoursub$PosX - xmin7) / boxsize) + 1
          y.grid <- floor((hoursub$PosY - ymin7) / boxsize) + 1
          x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
          y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
          t.x <- sort(unique(x.grid))
          t.y <- sort(unique(y.grid))
          tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
          ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
          t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
          grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
          t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
          t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
          eg <- expand.grid(t.y,t.x)
          grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
          
          proportion.P7 <- c(proportion.P7, length(which(grid.cov > 0))/length(grid.cov))
          
        } else {
          
          proportion.P7 <- c(proportion.P7, 0)  
          
        }
        
        starttime <- starttime+hours(1)
        
      }
      
      proportion.P7[proportion.P7 == 0] <- NA
      #coverage.P7[,as.character(i)] <-  mean(proportion, na.rm = T)
      coverage.P7[,as.character(i)] <-  c(mean(proportion.P7, na.rm = T), sd(proportion.P7, na.rm = T))
      
      
      proportion.P7 <- as.data.frame(proportion.P7)
      proportion.P7$pen <- 7
      names(proportion.P7) <- c('proportion', 'pen')
      
      
      fish.id <- subset(dayfile, PEN == '8')
      
      fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
      starttime <- fish.id[1,'EchoTime']-seconds(1)
      nhours <- length(unique(hour(fish.id[,'EchoTime'])))-1
      fish.id <- fish.id[order(fish.id$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
      
      proportion.P8 <- numeric()
      
      
      for (j in 1:nhours){
        
        hoursub <- fish.id[fish.id$EchoTime >starttime & fish.id$EchoTime <starttime+hours(1),]   
        
        if (nrow(hoursub) > 1){
          
          x.grid <- floor((hoursub$PosX - xmin8) / boxsize) + 1
          y.grid <- floor((hoursub$PosY - ymin8) / boxsize) + 1
          x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
          y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
          t.x <- sort(unique(x.grid))
          t.y <- sort(unique(y.grid))
          tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
          ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
          t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
          grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
          t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
          t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
          eg <- expand.grid(t.y,t.x)
          grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
          
          proportion.P8 <- c(proportion.P8, length(which(grid.cov > 0))/length(grid.cov))
          
        } else {
          
          proportion.P8 <- c(proportion.P8, 0)  
          
        }
        
        starttime <- starttime+hours(1)
        
      }
      
      proportion.P8[proportion.P8 == 0] <- NA
      #coverage.P8[,as.character(i)] <- mean(proportion, na.rm = T)
      coverage.P8[,as.character(i)] <- c(mean(proportion.P8, na.rm = T), sd(proportion.P8, na.rm = T))
      
      proportion.P8 <- as.data.frame(proportion.P8)
      proportion.P8$pen <- 8
      names(proportion.P8) <- c('proportion', 'pen')
      
      prop.perhr <- rbind(proportion.P7, proportion.P8)
      cov.anova <- aov(proportion~pen, data = prop.perhr)
      anova.sum <- unlist(summary(cov.anova))
      anova.list[,as.character(i)] <- anova.sum[9]
      
      
    }  
    
  }  
  
  coverage <- rbind(coverage.P7, coverage.P8, anova.list)
  print(coverage)
  
  write.xlsx(coverage, 'CoverageOutput_hmean.xlsx')
}

# 10c. hmean.perfish.coverage - daily hourly coverage per fish for all days loaded as one file using load.all()

hmean.perfish.coverage <- function(xmin7 = 15, xmax7 = 39, ymin7 = 15, ymax7 = 39, xmin8 = 41, xmax8 = 65, ymin8 = 15, ymax8 = 39, boxsize = 0.3) {
  
  #dayfile <- read.csv(files[1], header = TRUE, sep = ",", colClasses = dayfile.classes)
  fish7 <- sort(unique(dayfile$Period[dayfile$PEN == '7']))
  fish8 <- sort(unique(dayfile$Period[dayfile$PEN == '8']))
  
  days <- c(paste0(sort(unique(as.Date(dayfile$EchoTime))), ' 00:00:00'), paste0(max(unique(as.Date(dayfile$EchoTime)))+days(1), ' 00:00:00'))
  
  coverage.P7 <- data.frame(fish = fish7, pen = rep(7, length(fish7)))
  coverage.P8 <- data.frame(fish = fish8, pen = rep(8, length(fish8)))
  
  pencut <- subset(dayfile, PEN == '7')
  
  for(d in 1:length(days)-1){
    
    daycut <- pencut[pencut$EchoTime > days[d] & pencut$EchoTime < days[d+1],]
    daymean <- numeric()
    daysd <- numeric()
    
    for (f in 1:length(fish7)){
      
      fishcut <- daycut[daycut$Period == fish7[f],]  
      
      fishcut <- fishcut[order(fishcut$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
      starttime <- fishcut[1,'EchoTime']-(hours(1) + seconds(1))
      nhours <- length(unique(hour(fishcut[,'EchoTime'])))-1
      #fishcut <- fishcut[order(fishcut$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
      
      occupied <- numeric()
      total <- numeric()
      proportion <- numeric()
      
      for (i in 1:nhours){
        
        hoursub <- fishcut[fishcut$EchoTime > starttime & fishcut$EchoTime < starttime+hours(1),]   
        
        if(nrow(hoursub) > 1 & mean(hoursub$PosX) > xmin7 & mean(hoursub$PosX) < xmax7 & mean(hoursub$PosY) > ymin7 & mean(hoursub$PosY) < ymax7){
          
          x.grid <- floor((hoursub$PosX - xmin7) / boxsize) + 1 # pen 8 because both wild and farmed were in pen 8
          y.grid <- floor((hoursub$PosY - ymin7) / boxsize) + 1
          x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
          y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
          t.x <- sort(unique(x.grid))
          t.y <- sort(unique(y.grid))
          tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
          ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
          t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
          grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
          t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
          t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
          eg <- expand.grid(t.y,t.x)
          grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
          occupied <- c(occupied, length(which(grid.cov > 0)))
          total <- c(total, length(grid.cov))
          proportion <- c(proportion, length(which(grid.cov > 0))/length(grid.cov))
          
        } else {proportion <- c(proportion, 0) }
        
        starttime <- starttime+hours(1)
        
        
      } # end of hour cut loop
      
      daymean <- c(daymean, mean(proportion))
      daysd <- c(daysd, sd(proportion))
      
    } # end of fishcut loop
    
    coverage.P7[,paste0(as.character(d), '_mean')] <- daymean
    coverage.P7[,paste0(as.character(d), '_sd')] <- daysd
    
  } # end of daycut loop
  
  
  pencut <- subset(dayfile, PEN == '8')
  
  for(d in 1:length(days)-1){
    
    daycut <- pencut[pencut$EchoTime > days[d] & pencut$EchoTime < days[d+1],]
    daymean <- numeric()
    daysd <- numeric()
    
    for (f in 1:length(fish8)){
      
      fishcut <- daycut[daycut$Period == fish8[f],]  
      
      fishcut <- fishcut[order(fishcut$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
      starttime <- fishcut[1,'EchoTime']-(hours(1) + seconds(1))
      nhours <- length(unique(hour(fishcut[,'EchoTime'])))-1
      #fishcut <- fishcut[order(fishcut$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
      
      occupied <- numeric()
      total <- numeric()
      proportion <- numeric()
      
      for (i in 1:nhours){
        
        hoursub <- fishcut[fishcut$EchoTime > starttime & fishcut$EchoTime < starttime+hours(1),]   
        
        if(nrow(hoursub) > 1 & mean(hoursub$PosX) > xmin8 & mean(hoursub$PosX) < xmax8 & mean(hoursub$PosY) > ymin8 & mean(hoursub$PosY) < ymax8){
          
          x.grid <- floor((hoursub$PosX - xmin8) / boxsize) + 1
          y.grid <- floor((hoursub$PosY - ymin8) / boxsize) + 1
          x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
          y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
          t.x <- sort(unique(x.grid))
          t.y <- sort(unique(y.grid))
          tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
          ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
          t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
          grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
          t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
          t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
          eg <- expand.grid(t.y,t.x)
          grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
          occupied <- c(occupied, length(which(grid.cov > 0)))
          total <- c(total, length(grid.cov))
          proportion <- c(proportion, length(which(grid.cov > 0))/length(grid.cov))
          
        } else {proportion <- c(proportion, 0) }
        
        starttime <- starttime+hours(1)
        
        
      } # end of hour cut loop
      
      daymean <- c(daymean, mean(proportion))
      daysd <- c(daysd, sd(proportion))
      
    } # end of fishcut loop
    
    coverage.P8[,paste0(as.character(d), '_mean')] <- daymean
    coverage.P8[,paste0(as.character(d), '_sd')] <- daysd
    
  } # end of daycut loop
  
  coverage <- rbind(coverage.P7, coverage.P8) 
  coverage[,'0_mean'] <- NULL
  coverage[,'0_sd'] <- NULL
  write.csv(coverage, 'CoverageOutput_hmeanperfish.csv')
  coverage <<- coverage
}



# 11a. draws a plot of fish depth for the fish id specified

fish.depth <- function(period)
{
  fish.id <- subset(dayfile, Period == period)
  plot(fish.id$EchoTime, fish.id$PosZ, xlab = 'Time', ylab = 'Depth (m)', ylim = c(35, 0), type = 'l', col = '#26b426')
  segments(fish.id[1,4], 15, fish.id[nrow(fish.id), 4], 15, lty = 2)
  legend('bottomleft', as.character(period), col = '#26b426', pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE, y.intersp = 0)
  
}



# 11b. draws a plot of fish activity for the fish id specified

fish.act <- function(period)
{
  fish.id <- subset(dayfile, Period == period)
  plot(fish.id$EchoTime, fish.id$BLSEC, xlab = 'Time', ylab = 'Activity (BL/SEC)', ylim = c(0, 5), type = 'l', col = '#26b426')
  legend('bottomleft', as.character(period), col = '#26b426', pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE, y.intersp = 0)
  
}

# 12. draws a plot of depths for three fish

fish.3depth <- function(period1, period2, period3)
{
  fish.id <- subset(dayfile, Period == period1)
  plot(fish.id$EchoTime, fish.id$PosZ, xlab = 'Time', ylab = 'Depth (m)', ylim = c(35,0), type = 'l', col = '#26b426')
  
  fish.id <- subset(dayfile, Period == period2)
  lines(fish.id$EchoTime, fish.id$PosZ, col = '#d80000')
  
  fish.id <- subset(dayfile, Period == period3)
  lines(fish.id$EchoTime, fish.id$PosZ, col = '#038ef0')
  segments(fish.id[1,4], 15, fish.id[nrow(fish.id), 4], 15, lty = 2)
  legend('bottom', as.character(c(period1, period2, period3)), col = c('#26b426', '#d80000', '#038ef0'), pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE, y.intersp = 0)
}

# 13. draws a plot of fish location

fish.plot <- function(period)
{
  fishpal <- rainbow_hcl(20, c=100, l=63, start=-360, end=-32, alpha = 0.2)
  fish.id <- subset(dayfile, Period == period)
  
  if(fish.id[1,3] == '7')
  {
    
    # plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, cex = 0.8, xlim = c(0, 40), ylim = c(0, 45), type = 'p', col = rgb(0, 0.6, 0, 0.2)) # wider plot
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(10, 45), ylim = c(10, 45), type = 'l', col = '#26b426') # tight plot
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7EW', 'ymin'], locations.lookup['7EW', 'xmax'], locations.lookup['7EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['7ES', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7ES', 'xmax'], locations.lookup['7ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['7EE', 'xmin'], locations.lookup['7EE', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['7EN', 'xmin'], locations.lookup['7EN', 'ymin'], locations.lookup['7EN', 'xmax'], locations.lookup['7EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['7WHSE', 'xmin'], locations.lookup['7WHSE', 'ymin'], locations.lookup['7WHSE', 'xmax'], locations.lookup['7WHSE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['7WHNW', 'xmin'], locations.lookup['7WHNW', 'ymin'], locations.lookup['7WHNW', 'xmax'], locations.lookup['7WHNW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EN', 'ymax'], lwd = 2) # cage limits
    #legend(1, 10, as.character(period), col = '#26b426', pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE)
    
  }else{
    
    #plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, cex = 0.8, xlim = c(25, 70), ylim = c(0, 45), type = 'p', col = rgb(0, 0.6, 0, 0.2)) # wider plot
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(37, 72), ylim = c(10, 45), type = 'l', col = '#26b426') # tight plot
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8EW', 'ymin'], locations.lookup['8EW', 'xmax'], locations.lookup['8EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['8ES', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8ES', 'xmax'], locations.lookup['8ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['8EE', 'xmin'], locations.lookup['8EE', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['8EN', 'xmin'], locations.lookup['8EN', 'ymin'], locations.lookup['8EN', 'xmax'], locations.lookup['8EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['8WHSW', 'xmin'], locations.lookup['8WHSW', 'ymin'], locations.lookup['8WHSW', 'xmax'], locations.lookup['8WHSW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['8WHNE', 'xmin'], locations.lookup['8WHNE', 'ymin'], locations.lookup['8WHNE', 'xmax'], locations.lookup['8WHNE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EN', 'ymax'], lwd = 2) # cage limits
    #legend(25, 10, as.character(period), col = '#26b426', pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE)
    
  }
}

# 14. Draws a plot of fish locations for 3 fish

fish.3plot <- function(period1, period2, period3)
{
  fish.id <- subset(dayfile, Period == period1)
  if(fish.id[1,3] == '7')
  {
    
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, xlim = c(10, 45), ylim = c(10, 45), type = 'l', col = '#26b426')
    fish.id <- subset(dayfile, Period == period2)
    lines(fish.id$PosX, fish.id$PosY, pch = 20, col = '#d80000')
    fish.id <- subset(dayfile, Period == period3)
    lines(fish.id$PosX, fish.id$PosY, pch = 20, col = '#038ef0')
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7EW', 'ymin'], locations.lookup['7EW', 'xmax'], locations.lookup['7EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['7ES', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7ES', 'xmax'], locations.lookup['7ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['7EE', 'xmin'], locations.lookup['7EE', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['7EN', 'xmin'], locations.lookup['7EN', 'ymin'], locations.lookup['7EN', 'xmax'], locations.lookup['7EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['7WHSE', 'xmin'], locations.lookup['7WHSE', 'ymin'], locations.lookup['7WHSE', 'xmax'], locations.lookup['7WHSE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['7WHNW', 'xmin'], locations.lookup['7WHNW', 'ymin'], locations.lookup['7WHNW', 'xmax'], locations.lookup['7WHNW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EN', 'ymax'], lwd = 2) # cage limits
    legend(1, 10, as.character(c(period1, period2, period3)), col = c('#26b426', '#d80000', '#038ef0'), pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE)
    
  }else{
    
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, xlim = c(37, 72), ylim = c(10, 45), type = 'l', col = '#26b426')
    fish.id <- subset(dayfile, Period == period2)
    lines(fish.id$PosX, fish.id$PosY, pch = 20, col = '#d80000')
    fish.id <- subset(dayfile, Period == period3)
    lines(fish.id$PosX, fish.id$PosY, pch = 20, col = '#038ef0')
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8EW', 'ymin'], locations.lookup['8EW', 'xmax'], locations.lookup['8EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['8ES', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8ES', 'xmax'], locations.lookup['8ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['8EE', 'xmin'], locations.lookup['8EE', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['8EN', 'xmin'], locations.lookup['8EN', 'ymin'], locations.lookup['8EN', 'xmax'], locations.lookup['8EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['8WHSW', 'xmin'], locations.lookup['8WHSW', 'ymin'], locations.lookup['8WHSW', 'xmax'], locations.lookup['8WHSW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['8WHNE', 'xmin'], locations.lookup['8WHNE', 'ymin'], locations.lookup['8WHNE', 'xmax'], locations.lookup['8WHNE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EN', 'ymax'], lwd = 2) # cage limits
    legend(25, 10, as.character(c(period1, period2, period3)), col = c('#26b426', '#d80000', '#038ef0'), pch = 20, bty = 'n', pt.cex = 1.5, horiz = TRUE)
    
  }
}


# 15. Add a fish to the current plot

add.fish <- function(period, fishcol)
{
  fish.id <- subset(dayfile, Period == period)
  points(fish.id$PosX, fish.id$PosY, pch = 20, cex = 1, col = fishcol)
}

#16a. draws a plot of fish location density for the fish id specified 

fish.hexplot <- function(period)
  
{

  pen.col <- 'black'
  pen.size <- 1.4
  #plot.col <- rev(heat.colors(2, alpha = 1))
  plot.col <- matlab.like(1000)  
  
  fish.id <- subset(dayfile, Period == period)
  
  pingmax <- as.integer((as.double(max(dayfile$EchoTime))-as.double(min(dayfile$EchoTime)))/500)
  
  if(dayfile[1, 'PEN'] == 7){  
    
    ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY)) +
      geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, pingmax), na.value = plot.col[length(plot.col)], name = 'No. pings') +
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
      annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
      scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45))
    
  } else {
    
    ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY)) +
      geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, pingmax), na.value = plot.col[length(plot.col)], name = 'No. pings') +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
      scale_x_continuous('x (m)', limits = c(35,70)) + scale_y_continuous('y (m)', limits = c(10,45))  
  
  }
}


#16b. draws a plot of fish location density for all fish in the specified pen (7 or 8)

hexplot.all <- function(pen)
{
  
  pen.col <- 'black'
  pen.size <- 1.4
  #plot.col <- rev(heat.colors(2, alpha = 1))
  plot.col <- matlab.like(1000)  
  
if(pen == 7){  
  
fish.id <- subset(dayfile, PEN == 7)  

  hexplot <- ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY))
  hexplot <- hexplot + geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 1000), na.value = plot.col[length(plot.col)], name = 'No. pings')
  hexplot + annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
    scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45))
  
  } else {
  
    
    fish.id <- subset(dayfile, PEN == 8)  
    
    hexplot <- ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY))
    hexplot <- hexplot + geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 1000), na.value = plot.col[length(plot.col)], name = 'No. pings') 
    hexplot + annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
      scale_x_continuous('x (m)', limits = c(35,70)) + scale_y_continuous('y (m)', limits = c(10,45))
}  
  
}



#16c. draws plots of fish location density for all fish in pens 7 and 8 and plots side by side

hexplot.compare <- function(pen)
{
  
  pen.col <- 'black'
  pen.size <- 1.4
  #plot.col <- rev(heat.colors(2, alpha = 1))
  plot.col <- matlab.like(1000)  
  
  #if(pen == 7){  
  
  fish.id7 <- subset(dayfile, PEN == 7)  
  
  hexplot7 <- ggplot(fish.id7, aes(fish.id7$PosX, fish.id7$PosY)) +
    geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 1000), na.value = plot.col[length(plot.col)], name = 'No. pings') +
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
    scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45)) +
    ggtitle(label = 'Acclimated wrasse')
  
  #} else {
  
  
  fish.id8 <- subset(dayfile, PEN == 8)  
  
  hexplot8 <- ggplot(fish.id8, aes(fish.id8$PosX, fish.id8$PosY)) +
    geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 1000), na.value = plot.col[length(plot.col)], name = 'No. pings') +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
    scale_x_continuous('x (m)', limits = c(35,70)) + scale_y_continuous('y (m)', limits = c(10,45)) +
    ggtitle(label = 'Non-acclimated wrasse')
  
  #}  
  
  hexleg <- get_legend(hexplot7)
  hexplot7 <- hexplot7 + theme(legend.position = 'none')
  hexplot8 <- hexplot8 + theme(legend.position = 'none')
  
  plot_grid(hexplot7, hexplot8, hexleg, ncol = 3, nrow = 1, rel_widths = c(1,1, 0.2))
  
}




# 17. draws a 3d plot of fish location and depth

fish.3dplot <- function(period)
{
  fish.id <- subset(dayfile, Period == period)
  scatterplot3d(fish.id$PosX, fish.id$PosY, fish.id$PosZ, pch = 20, xlim =  c(10, 45), ylim = c(10, 45), zlim = c(26, 0))
}


# 18. draws a 3d interactive plot of fish location and depth

fish.3dmove <- function(period)
{
  fish.id <- subset(dayfile, Period == period)
  plot3d(fish.id$PosX, fish.id$PosY, fish.id$PosZ, cex = 1, xlim =  c(10, 45), ylim = c(10, 45), zlim = c(0, 35), xlab = 'X', ylab = 'Y', zlab = 'Z', type = 'l', col = '#26b426', lwd = 2)
}



# 19a. draws a plot of fish location by depth

plot.bydepth <- function(period)
{
  depthpal <- diverge_hcl(30, h = c(11,266), c = 100, l = c(21,85), power = 0.6)
  fish.id <- subset(dayfile, Period == period)
  
  if(fish.id[1,3] == '7')
  {
    
    # plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, cex = 0.8, xlim = c(0, 40), ylim = c(0, 45), type = 'p', col = rgb(0, 0.6, 0, 0.2)) # wider plot
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(10, 45), ylim = c(10, 45), type = 'p', col = depthpal[round(fish.id$PosZ)]) # tight plot
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7EW', 'ymin'], locations.lookup['7EW', 'xmax'], locations.lookup['7EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['7ES', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7ES', 'xmax'], locations.lookup['7ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['7EE', 'xmin'], locations.lookup['7EE', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['7EN', 'xmin'], locations.lookup['7EN', 'ymin'], locations.lookup['7EN', 'xmax'], locations.lookup['7EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['7WHSE', 'xmin'], locations.lookup['7WHSE', 'ymin'], locations.lookup['7WHSE', 'xmax'], locations.lookup['7WHSE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['7WHNW', 'xmin'], locations.lookup['7WHNW', 'ymin'], locations.lookup['7WHNW', 'xmax'], locations.lookup['7WHNW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EN', 'ymax'], lwd = 2) # cage limits
    legend(41, 42, as.character(1:30), col = depthpal, pch = 15, bty = 'n', cex = 1, pt.cex = 2.6, horiz = FALSE, y.intersp = 0.5, title = 'depth (m)', text.width = 0.2, yjust = 1)
    
    
  }else{
    
    #plot(fish.id$PosX, fish.id$PosY, xlab = 'X', ylab = 'Y', pch = 20, cex = 0.8, xlim = c(25, 70), ylim = c(0, 45), type = 'p', col = rgb(0, 0.6, 0, 0.2)) # wider plot
    plot(fish.id$PosX, fish.id$PosY, xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(37, 72), ylim = c(10, 45), type = 'p', col = depthpal[round(fish.id$PosZ)]) # tight plot
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8EW', 'ymin'], locations.lookup['8EW', 'xmax'], locations.lookup['8EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['8ES', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8ES', 'xmax'], locations.lookup['8ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['8EE', 'xmin'], locations.lookup['8EE', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['8EN', 'xmin'], locations.lookup['8EN', 'ymin'], locations.lookup['8EN', 'xmax'], locations.lookup['8EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['8WHSW', 'xmin'], locations.lookup['8WHSW', 'ymin'], locations.lookup['8WHSW', 'xmax'], locations.lookup['8WHSW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['8WHNE', 'xmin'], locations.lookup['8WHNE', 'ymin'], locations.lookup['8WHNE', 'xmax'], locations.lookup['8WHNE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EN', 'ymax'], lwd = 2) # cage limits
    legend(67, 42, as.character(1:30), col = depthpal, pch = 15, bty = 'n', cex = 1, pt.cex = 2.6, horiz = FALSE, y.intersp = 0.5, title = 'depth (m)', text.width = 0.2)
    
  }
}



# 19b. draws a plot of fish location by activity behaviour state

plot.byactivity <- function(period, static = 0.1, burst = 1)
{
  activitypal <- heat_hcl(3, h = c(0,-100), c = c(40, 80), l = c(75,40), power = 1)
  activitypal <- brewer.pal(3, 'Set1')
  pen.col <- 'black'
  pen.size <- 0.8
  
  fish.id <- subset(dayfile, Period == period)
  fish.id$BS <- as.factor(ifelse(fish.id$BLSEC < 0.1, 'static', ifelse(fish.id$BLSEC >=0.1 & fish.id$BLSEC <1, 'cruise', 'burst')))
  fish.id$BS <- factor(fish.id$BS, levels = c('cruise', 'static', 'burst'))
  fish.id <- fish.id[order(fish.id$BS, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by behaviour state
  
 
if (unique(fish.id$PEN == '7')) {
  
  fish.plot <- ggplot(fish.id, aes(PosX, PosY)) +
    scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45)) + # set scale limits      
    theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
    geom_point(aes(colour = cut(BLSEC, c(-Inf, static, burst, Inf))), size = 3)  + scale_color_manual(name = 'activity (BL/sec)', values = c("(-Inf,0.1]" = activitypal[[3]], "(0.1,1]" = activitypal[[2]], "(1, Inf]" = activitypal[[1]]), labels = c('static (< 0.1)', 'cruise (0.1 - 1)', 'burst (>1)')) +
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) # hide boundary
   fish.plot

} else {
   
  fish.plot <- ggplot(fish.id, aes(PosX, PosY)) +
    scale_x_continuous('x (m)', limits = c(30,65)) + scale_y_continuous('y (m)', limits = c(8,43)) + 
    theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
    geom_point(aes(colour = cut(BLSEC, c(-Inf, static, burst, Inf))), size = 3)  + scale_color_manual(name = 'activity (BL/sec)', values = c("(-Inf,0.1]" = activitypal[[3]], "(0.1,1]" = activitypal[[2]], "(1, Inf]" = activitypal[[1]]), labels = c('static (< 0.1)', 'cruise (0.1 - 1)', 'burst (>1)')) +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
    annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
    annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1)# + # hide boundary
  fish.plot
  
  }
  
}

# 19c. draws a plot of fish location by time of day

plot.bylight <- function(period)
{

  lightpal <- brewer.pal(11, 'Spectral')
  lightpal <- c(lightpal[[4]], lightpal[[5]], lightpal[[3]], lightpal[[11]])
  pen.col <- 'black'
  pen.size <- 0.8
  
  fish.id <- subset(dayfile, Period == period)
  fish.id <- subset(fish.id, SUN == 'N' | SUN == 'W' | SUN == 'D' | SUN == 'K')
  #fish.id$BS <- as.factor(ifelse(fish.id$BLSEC < 0.1, 'static', ifelse(fish.id$BLSEC >=0.1 & fish.id$BLSEC <1, 'cruise', 'burst')))
  fish.id$SUN <- factor(fish.id$SUN, levels = c('D', 'W', 'K', 'N'))
  fish.id <- fish.id[order(fish.id$SUN, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by behaviour state
  fish.id$SUN <- factor(fish.id$SUN, levels = c('W', 'D', 'K', 'N'))
  
  if (unique(fish.id$PEN == '7')) {
    
    fish.plot <- ggplot(fish.id, aes(PosX, PosY)) +
      scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45)) + # set scale limits      
      theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
      geom_point(aes(colour = SUN), size = 3)  + scale_color_manual(name = 'Time of day', values = lightpal, labels = c('Dawn', 'Day', 'Dusk', 'Night')) +
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
      annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
      annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) # hide boundary
    fish.plot
    
  } else {
    
    fish.plot <- ggplot(fish.id, aes(PosX, PosY)) +
      scale_x_continuous('x (m)', limits = c(30,65)) + scale_y_continuous('y (m)', limits = c(8,43)) + 
      theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
      geom_point(aes(colour = SUN), size = 3)  + scale_color_manual(name = 'Time of day', values = lightpal, labels = c('Dawn', 'Day', 'Dusk', 'Night')) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
      annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1)# + # hide boundary
    fish.plot
    
  }
  
}

# 20. Add a fish to the current plot

add.depthfish <- function(period)
{
  depthpal <- diverge_hcl(30, h = c(11,266), c = 100, l = c(21,85), power = 0.6, alpha = 0.2)
  fish.id <- subset(dayfile, Period == period)
  points(fish.id$PosX, fish.id$PosY, pch = 20, cex = 1, col = depthpal[round(fish.id$PosZ)])
}




# 21. Fractal dimension

fractal <- function(xmin7 = 5, xmax7 = 45, ymin7 = 5, ymax7 = 45, xmin8 = 35, xmax8 = 75, ymin8 = 5, ymax8 = 45, boxsize = 0.1) {
  
  fd.P7 <- data.frame(x = numeric, y = integer)
  fd.P8 <- data.frame(x = numeric, y = integer)
  bs <- boxsize
  
  pen.id <- subset(dayfile, PEN == '7')
  
  repeat {
    
    
    x.grid <- floor((pen.id$PosX - xmin7) / bs) + 1
    y.grid <- floor((pen.id$PosY - ymin7) / bs) + 1
    x.grid.max <- floor((xmax7 - xmin7) / bs) + 1
    y.grid.max <- floor((ymax7 - ymin7) / bs) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    fd.P7 <- rbind(fd.P7, c(bs, length(which(grid.cov > 0))))
    bs <- bs*2
    
    if (bs > xmax7-xmin7 | bs > ymax7-ymin7)
    {break}
  }
  colnames(fd.P7) <- c('P7.boxsize', 'P7.count')
  bs <- boxsize
  
  
  fl <- lm(log(P7.count) ~ log(P7.boxsize), data=fd.P7)
  scatterplot(fd.P7$P7.boxsize, fd.P7$P7.count, log = 'xy', boxplots = FALSE, smoother = FALSE, grid = FALSE)
  text(1, 100, paste0('fd = ', as.character(round(fl$coefficients[[2]], 3)), '\nR2 = ', round(summary(fl)$r.squared, 4)))
  
  #scatterplot(fd.P7$P7.boxsize, fd.P7$P7.count, log = 'xy', boxplots = FALSE, smoother = FALSE, grid = FALSE)
  
  cat('Press [enter] to continue')
  line <- readline()
  
  pen.id <- subset(dayfile, PEN == '8')
  
  repeat{
    
    x.grid <- floor((pen.id$PosX - xmin8) / bs) + 1
    y.grid <- floor((pen.id$PosY - ymin8) / bs) + 1
    x.grid.max <- floor((xmax8 - xmin8) / bs) + 1
    y.grid.max <- floor((ymax8 - ymin8) / bs) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    fd.P8 <- rbind(fd.P8, c(bs, length(which(grid.cov > 0))))
    bs <- bs*2
    
    if (bs > xmax8-xmin8 | bs > ymax8-ymin8)
    {break}
  }
  colnames(fd.P8) <- c('P8.boxsize', 'P8.count')
  
  fl <- lm(log(P8.count) ~ log(P8.boxsize), data=fd.P8)
  scatterplot(fd.P8$P8.boxsize, fd.P8$P8.count, log = 'xy', boxplots = FALSE, smoother = FALSE, grid = FALSE)
  text(1, 100, paste0('fd = ', as.character(round(fl$coefficients[[2]], 3)), '\nR2 = ', round(summary(fl)$r.squared, 4)))
  
  fd <- cbind(fd.P7, fd.P8) 
  fd
  

}


# 22. batch Fractal dimension

batch.fractals <- function(xmin7 = 5, xmax7 = 45, ymin7 = 5, ymax7 = 45, xmin8 = 35, xmax8 = 75, ymin8 = 5, ymax8 = 45, boxsize = 0.1) {
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  #fcount.P7 <- data.frame(x = numeric, y = integer)
  #fcount.P8 <- data.frame(x = numeric, y = integer)
  bs <- boxsize
  
  dayfile.loc <- files[[1]]
  dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = 'character')
  # dayfile[,1] <- NULL
  
  pen.id <- subset(dayfile, dayfile$PEN == '7')
  fish.ids7 <- unique(pen.id$Period)
  fd.P7 <- data.frame(fish.ids7)
  rownames(fd.P7) <- fd.P7[,1]
  colnames(fd.P7) <- 'Period'
  pen.id <- subset(dayfile, dayfile$PEN == '8')
  fish.ids8 <- unique(pen.id$Period)
  fd.P8 <- data.frame(fish.ids8)
  rownames(fd.P8) <- fd.P8[,1]
  colnames(fd.P8) <- 'Period'
  
  for (n in 1:length(files))
  {
    dayfile.loc <- files[[n]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                        (
                        'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'double', 'double', 'double', 'double', 'double', 'double', 'double',
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                        'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                        'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                        )) #read data into table
  
    fcount.P7 <- data.frame(x = numeric, y = integer)
    fcount.P8 <- data.frame(x = numeric, y = integer)  
    
  pen.id <- subset(dayfile, PEN == '7')
  
  for (i in 1:length(fish.ids7)){
  
  fish.id <- subset(pen.id, Period == fish.ids7[[i]])  
    
  if(nrow(fish.id) == 0){
    fd.P7[i,paste0(n, '.fractal')] <- NA
    fd.P7[i,paste0(n, '.R2')] <- NA
    }
  else{
  
  repeat {
    
    x.grid <- floor((fish.id$PosX - xmin7) / bs) + 1
    y.grid <- floor((fish.id$PosY - ymin7) / bs) + 1
    x.grid.max <- floor((xmax7 - xmin7) / bs) + 1
    y.grid.max <- floor((ymax7 - ymin7) / bs) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    fcount.P7 <- rbind(fcount.P7, c(bs, length(which(grid.cov > 0))))
    bs <- bs*2
    
    if (bs > xmax7-xmin7 | bs > ymax7-ymin7)
    {break}
  }
  colnames(fcount.P7) <- c('P7.boxsize', 'P7.count')
  bs <- boxsize
  
  
  fl <- lm(log(P7.count) ~ log(P7.boxsize), data=fcount.P7)
  fd.P7[i,paste0(n, '.fractal')] <- round(fl$coefficients[[2]], 3)
  fd.P7[i,paste0(n, '.R2')] <- round(summary(fl)$r.squared, 4)
  #print(fcount.P7)
  
  }
  
  }
  
  pen.id <- subset(dayfile, PEN == '8')
  
  
  for (i in 1:length(fish.ids8)){
    
    fish.id <- subset(pen.id, Period == fish.ids8[[i]])
    
    if(nrow(fish.id) == 0){
      fd.P8[i,paste0(n, '.fractal')] <- NA
      fd.P8[i,paste0(n, '.R2')] <- NA
    }
    else{
  
  repeat{
    
    x.grid <- floor((fish.id$PosX - xmin8) / bs) + 1
    y.grid <- floor((fish.id$PosY - ymin8) / bs) + 1
    x.grid.max <- floor((xmax8 - xmin8) / bs) + 1
    y.grid.max <- floor((ymax8 - ymin8) / bs) + 1
    t.x <- sort(unique(x.grid))
    t.y <- sort(unique(y.grid))
    tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
    ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
    t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
    grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
    t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
    t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
    eg <- expand.grid(t.y,t.x)
    grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
    fcount.P8 <- rbind(fcount.P8, c(bs, length(which(grid.cov > 0))))
    bs <- bs*2
    
    if (bs > xmax8-xmin8 | bs > ymax8-ymin8)
    {break}
  }
  colnames(fcount.P8) <- c('P8.boxsize', 'P8.count')
  bs <- boxsize
  
  
  fl <- lm(log(P8.count) ~ log(P8.boxsize), data=fcount.P8)
  fd.P8[i,paste0(n, '.fractal')] <- round(fl$coefficients[[2]], 3)
  fd.P8[i,paste0(n, '.R2')] <- round(summary(fl)$r.squared, 4)
  #print(fcount.P8)
  
    }
  
  }
  
  remove(fcount.P7)
  remove(fcount.P8)
  
  }
  
  #fd.P7$fish.ids7 <- NULL
  #fd.P8$fish.ids8 <- NULL
  fd <- rbind(fd.P7, fd.P8) 
  fd
  #loadWorkbook('FractalOutput.xlsx', create = TRUE)
  #writeWorksheetToFile('FractalOutput.xlsx', fd, 'Sheet 1')
  
  write.xlsx(fd, 'FractalOutput.xlsx')
}




# 23. Invidual fish Fractal dimension

id.fractals <- function(xmin7 = 5, xmax7 = 45, ymin7 = 5, ymax7 = 45, xmin8 = 35, xmax8 = 75, ymin8 = 5, ymax8 = 45, boxsize = 0.1) {
  
  #files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  #fcount.P7 <- data.frame(x = numeric, y = integer)
  #fcount.P8 <- data.frame(x = numeric, y = integer)
  bs <- boxsize
  
  #dayfile.loc <- files[[1]]
  dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c
                      (
                      'NULL', 'factor', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                      'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                      'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                      'double', 'double', 'double', 'double', 'double', 'double', 'double',
                      'double', 'double', 'double', 'double', 'double', 'double', 'double',
                      'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                      'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                      'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                      'double', 'double', 'double', 'double', 'double', 'double', 'double' 
                      )) #read data into table
  # dayfile[,1] <- NULL
  
  pen.id <- subset(dayfile, dayfile$PEN == '7')
  fish.ids7 <- unique(pen.id$Period)
  fd.P7 <- data.frame(fish.ids7)
  rownames(fd.P7) <- fd.P7[,1]
  colnames(fd.P7) <- 'Period'
  pen.id <- subset(dayfile, dayfile$PEN == '8')
  fish.ids8 <- unique(pen.id$Period)
  fd.P8 <- data.frame(fish.ids8)
  rownames(fd.P8) <- fd.P8[,1]
  colnames(fd.P8) <- 'Period'
  
  
  fcount.P7 <- data.frame(x = numeric, y = integer)
  fcount.P8 <- data.frame(x = numeric, y = integer)  
  
  pen.id <- subset(dayfile, PEN == '7')
  
  for (i in 1:length(fish.ids7)){
    
    fish.id <- subset(pen.id, Period == fish.ids7[[i]])  
    
    if(nrow(fish.id) == 0){
      fd.P7[i,'fractal'] <- NA
      fd.P7[i,'R2'] <- NA
    }
    else{
      
      repeat {
        
        x.grid <- floor((fish.id$PosX - xmin7) / bs) + 1
        y.grid <- floor((fish.id$PosY - ymin7) / bs) + 1
        x.grid.max <- floor((xmax7 - xmin7) / bs) + 1
        y.grid.max <- floor((ymax7 - ymin7) / bs) + 1
        t.x <- sort(unique(x.grid))
        t.y <- sort(unique(y.grid))
        tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
        ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
        t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
        grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
        t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
        t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
        eg <- expand.grid(t.y,t.x)
        grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
        fcount.P7 <- rbind(fcount.P7, c(bs, length(which(grid.cov > 0))))
        bs <- bs*2
        
        if (bs > xmax7-xmin7 | bs > ymax7-ymin7)
        {break}
      }
      colnames(fcount.P7) <- c('P7.boxsize', 'P7.count')
      bs <- boxsize
      
      
      fl <- lm(log(P7.count) ~ log(P7.boxsize), data=fcount.P7)
      fd.P7[i,'fractal'] <- round(fl$coefficients[[2]], 3)
      fd.P7[i,'R2'] <- round(summary(fl)$r.squared, 4)
      #print(fcount.P7)
      
    }
    
  }
  
  pen.id <- subset(dayfile, PEN == '8')
  
  
  for (i in 1:length(fish.ids8)){
    
    fish.id <- subset(pen.id, Period == fish.ids8[[i]])
    
    if(nrow(fish.id) == 0){
      fd.P8[i,'fractal'] <- NA
      fd.P8[i,'R2'] <- NA
    }
    else{
      
      repeat{
        
        x.grid <- floor((fish.id$PosX - xmin8) / bs) + 1
        y.grid <- floor((fish.id$PosY - ymin8) / bs) + 1
        x.grid.max <- floor((xmax8 - xmin8) / bs) + 1
        y.grid.max <- floor((ymax8 - ymin8) / bs) + 1
        t.x <- sort(unique(x.grid))
        t.y <- sort(unique(y.grid))
        tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
        ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
        t <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
        grid.cov <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
        t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
        t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
        eg <- expand.grid(t.y,t.x)
        grid.cov[cbind(eg$Var1,eg$Var2)] <- as.vector(t)  
        fcount.P8 <- rbind(fcount.P8, c(bs, length(which(grid.cov > 0))))
        bs <- bs*2
        
        if (bs > xmax8-xmin8 | bs > ymax8-ymin8)
        {break}
      }
      colnames(fcount.P8) <- c('P8.boxsize', 'P8.count')
      bs <- boxsize
      
      
      fl <- lm(log(P8.count) ~ log(P8.boxsize), data=fcount.P8)
      fd.P8[i,'fractal'] <- round(fl$coefficients[[2]], 3)
      fd.P8[i,'R2'] <- round(summary(fl)$r.squared, 4)
      #print(fcount.P8)
      
    }
    
  }
  
  #print(fcount.P7)
  #print(fcount.P8)
  
  
  
  #fd.P7$fish.ids7 <- NULL
  #fd.P8$fish.ids8 <- NULL
  fd <- rbind(fd.P7, fd.P8) 
  print(fd)
  loadWorkbook('FractalOutput.xlsx', create = TRUE)
  writeWorksheetToFile('FractalOutput.xlsx', fd, 'Sheet 1')
}


# 24. draws a plot of fish location coloured by time

plot.bytime <- function(period, units = 'd')
{
  fish.id <- subset(dayfile, Period == period)
  ifelse(units == 'd', timepoints <- unique(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d')), ifelse(units == 'h', timepoints <- unique(trunc(dayfile$EchoTime, "hour")), print('Error: specify days (d) or hours (h)'))) 
  bins <- length(timepoints)
  timepal <- rainbow(bins, alpha = 0.2)
  par(mfrow=c(1,1))
  
  if(fish.id[1,3] == '7')
  {
    if(units == 'd'){
      plot(fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[1]]),'PosX'], fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[1]]),'PosY'], xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(10, 45), ylim = c(10, 45), type = 'p', col = timepal[1])
    }else{
      plot(fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[1]),'PosX'], fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[1]),'PosY'], xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(10, 45), ylim = c(10, 45), type = 'p', col = timepal[1])
    }
    
        legend(10, 47, as.character(1:bins), col = rainbow(bins, alpha = 1) , pch = 15, bty = 'n', pt.cex = 1.5, horiz = FALSE, y.intersp = 1, cex = (100-bins)/100)

    
   if(units == 'd'){
    for (i in 2:bins){
        points(fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[i]]),'PosX'], fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[i]]),'PosY'], pch = 20, cex = 1, col = timepal[i])
    }
    }else{
    for (i in 2:bins){   
        points(fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[i]),'PosX'], fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[i]),'PosY'], pch = 20, cex = 1, col = timepal[i])
    }
      }
    
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7EW', 'ymin'], locations.lookup['7EW', 'xmax'], locations.lookup['7EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['7ES', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7ES', 'xmax'], locations.lookup['7ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['7EE', 'xmin'], locations.lookup['7EE', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['7EN', 'xmin'], locations.lookup['7EN', 'ymin'], locations.lookup['7EN', 'xmax'], locations.lookup['7EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['7WHSE', 'xmin'], locations.lookup['7WHSE', 'ymin'], locations.lookup['7WHSE', 'xmax'], locations.lookup['7WHSE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['7WHNW', 'xmin'], locations.lookup['7WHNW', 'ymin'], locations.lookup['7WHNW', 'xmax'], locations.lookup['7WHNW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['7EW', 'xmin'], locations.lookup['7ES', 'ymin'], locations.lookup['7EE', 'xmax'], locations.lookup['7EN', 'ymax'], lwd = 2) # cage limits
    
  }else{
    
    
    if(units == 'd'){
      plot(fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[1]]),'PosX'], fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[1]]),'PosY'], xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(25, 70), ylim = c(0, 45), type = 'p', col = timepal[1])
    }else{
      plot(fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[1]),'PosX'], fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[1]),'PosY'], xlab = 'X (m)', ylab = 'Y (m)', pch = 20, cex = 1, xlim = c(37, 72), ylim = c(10, 45), type = 'p', col = timepal[1])
    }
    
      legend(32, 47, as.character(1:bins), col = rainbow(bins, alpha = 1) , pch = 15, bty = 'n', pt.cex = 1.5, horiz = FALSE, y.intersp = 1, cex = (100-bins)/100)

   if(units == 'd'){ 
    for (i in 2:bins){
        points(fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[i]]),'PosX'], fish.id[which(format(as.Date(dayfile$EchoTime, format='%Y-%m-%d %H:%M:%S'), '%Y-%m-%d') == timepoints[[i]]),'PosY'], pch = 20, cex = 1, col = timepal[i])
    }
      }else{
        for (i in 2:bins){    
        points(fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[i]),'PosX'], fish.id[which(trunc(dayfile$EchoTime, "hour") == timepoints[i]),'PosY'], pch = 20, cex = 1, col = timepal[i])
        }
    }
    
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8EW', 'ymin'], locations.lookup['8EW', 'xmax'], locations.lookup['8EW', 'ymax'], lty = 2) # 7EW edge
    rect(locations.lookup['8ES', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8ES', 'xmax'], locations.lookup['8ES', 'ymax'], lty = 2) # 7ES edge
    rect(locations.lookup['8EE', 'xmin'], locations.lookup['8EE', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EE', 'ymax'], lty = 2) # 7EE edge
    rect(locations.lookup['8EN', 'xmin'], locations.lookup['8EN', 'ymin'], locations.lookup['8EN', 'xmax'], locations.lookup['8EN', 'ymax'], lty = 2) # 7EN edge
    rect(locations.lookup['8WHSW', 'xmin'], locations.lookup['8WHSW', 'ymin'], locations.lookup['8WHSW', 'xmax'], locations.lookup['8WHSW', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHSE
    rect(locations.lookup['8WHNE', 'xmin'], locations.lookup['8WHNE', 'ymin'], locations.lookup['8WHNE', 'xmax'], locations.lookup['8WHNE', 'ymax'], lty = 3, col = rgb(1, 0.6, 0, 0.4)) # 7WHNW
    rect(locations.lookup['8EW', 'xmin'], locations.lookup['8ES', 'ymin'], locations.lookup['8EE', 'xmax'], locations.lookup['8EN', 'ymax'], lwd = 2) # cage limits
    
  }
  remove(timepoints)
}

# 25. Removes single fish id from specified day files

batch.remove <- function(period, start.day, no.days){
  
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  day1 <- grep(paste0('^..............', start.day, '_day_coded.csv'), files)
  end.day <- day1+(no.days-1)
  # dayfile.loc <- files[[grep(paste0('^..............', start.day, '_day_coded.csv'), files)]]
  
  for (i in day1:end.day) {
    dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                             'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double'
                                                                             
    )) #read data into table

    dayfile <- dayfile[!(dayfile$Period == period),] # remove dead fish
    write.csv(dayfile, file = files[[i]]) #write output to file
    
  } 

}



# 26. proportion coverage 3D (not sure this is working properly!)

prop.coverage.3d <- function(xmin7 = 15, xmax7 = 40, ymin7 = 15, ymax7 = 40, xmin8 = 42, xmax8 = 67, ymin8 = 15, ymax8 = 40, zmin7 = 0, zmax7 = 15, zmin8 = 0, zmax8 = 15, boxsize = 0.3) {
  fish.id <- subset(dayfile, PEN == '7')
  x.grid <- floor((fish.id$PosX - xmin7) / boxsize) + 1
  y.grid <- floor((fish.id$PosY - ymin7) / boxsize) + 1
  z.grid <- floor((fish.id$PosZ - zmin7) / boxsize) + 1
  x.grid.max <- floor((xmax7 - xmin7) / boxsize) + 1
  y.grid.max <- floor((ymax7 - ymin7) / boxsize) + 1
  z.grid.max <- floor((zmax7 - zmin7) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  t.z <- sort(unique(z.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  tz.range <- c(min(which(t.z > 0)), max(which(t.z <= z.grid.max)))
  t.xy <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  t.yz <- table(y.grid, z.grid)[ty.range[1]:ty.range[2],tz.range[1]:tz.range[2]]
  grid.cov.xy <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  grid.cov.yz <- matrix(0,nrow=y.grid.max,ncol=z.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  t.z <- t.z[(t.z > 0) & (t.z <= z.grid.max)]
  eg.xy <- expand.grid(t.y,t.x)
  eg.yz <- expand.grid(t.y,t.z)
  grid.cov.xy[cbind(eg.xy$Var1,eg.xy$Var2)] <- as.vector(t.xy)  
  grid.cov.yz[cbind(eg.yz$Var1,eg.yz$Var2)] <- as.vector(t.yz) 
  coverage.P7 <- matrix(c(round(length(which(grid.cov.xy > 0))+length(which(grid.cov.yz > 0)), digits = 3), round(length(grid.cov.xy)*((zmax7-zmin7)/boxsize), digits = 3), signif((length(which(grid.cov.xy > 0))+length(which(grid.cov.yz > 0)))/(length(grid.cov.xy)*((zmax7-zmin7)/boxsize)), digits = 3)), ncol = 3)
  coverage.P7
  colnames(coverage.P7) <- c('occupied', 'total', 'proportion')
  
  
  #density.pal <- heat_hcl(length(as.vector(t)))
  #eg$col <- as.vector(t)
  #plot(eg$Var1, eg$Var2, col = density.pal[eg$col], pch = 15, cex = 2.5)
  
  
  fish.id <- subset(dayfile, PEN == '8')
  x.grid <- floor((fish.id$PosX - xmin8) / boxsize) + 1
  y.grid <- floor((fish.id$PosY - ymin8) / boxsize) + 1
  z.grid <- floor((fish.id$PosZ - zmin8) / boxsize) + 1
  x.grid.max <- floor((xmax8 - xmin8) / boxsize) + 1
  y.grid.max <- floor((ymax8 - ymin8) / boxsize) + 1
  z.grid.max <- floor((zmax8 - zmin8) / boxsize) + 1
  t.x <- sort(unique(x.grid))
  t.y <- sort(unique(y.grid))
  t.z <- sort(unique(z.grid))
  tx.range <- c(min(which(t.x > 0)), max(which(t.x <= x.grid.max)))
  ty.range <- c(min(which(t.y > 0)), max(which(t.y <= y.grid.max)))
  tz.range <- c(min(which(t.z > 0)), max(which(t.z <= z.grid.max)))
  t.xy <- table(y.grid, x.grid)[ty.range[1]:ty.range[2],tx.range[1]:tx.range[2]]
  t.yz <- table(y.grid, z.grid)[ty.range[1]:ty.range[2],tz.range[1]:tz.range[2]]
  grid.cov.xy <- matrix(0,nrow=y.grid.max,ncol=x.grid.max)
  grid.cov.yz <- matrix(0,nrow=y.grid.max,ncol=z.grid.max)
  t.x <- t.x[(t.x > 0) & (t.x <=x.grid.max)]
  t.y <- t.y[(t.y > 0) & (t.y <=y.grid.max)]
  t.z <- t.z[(t.z > 0) & (t.z <= z.grid.max)]
  eg.xy <- expand.grid(t.y,t.x)
  eg.yz <- expand.grid(t.y,t.z)
  grid.cov.xy[cbind(eg.xy$Var1,eg.xy$Var2)] <- as.vector(t.xy)  
  grid.cov.yz[cbind(eg.yz$Var1,eg.yz$Var2)] <- as.vector(t.yz) 
  coverage.P8 <- matrix(c(round(length(which(grid.cov.xy > 0))+length(which(grid.cov.yz > 0)), digits = 3), round(length(grid.cov.xy)*((zmax8-zmin8)/boxsize), digits = 3), signif((length(which(grid.cov.xy > 0))+length(which(grid.cov.yz > 0)))/(length(grid.cov.xy)*((zmax8-zmin8)/boxsize)), digits = 3)), ncol = 3)
  coverage.P8
  colnames(coverage.P8) <- c('occupied', 'total', 'proportion')
  
  coverage <- rbind(coverage.P7, coverage.P8) 
  rownames(coverage) <- c('P7', 'P8')
  coverage
}



# 27. moving average filter function


ma.filter <- function(period, smooth = 20, thresh = 5){
  
  fish.id <- subset(dayfile, dayfile$Period == period)
  par(mfrow=c(2,2))
  #fish.id <- subset(fish.id, fish.id$SEC >5 | is.na(fish.id$SEC) == TRUE) # remove entries where time delay too low or too high
  plot(fish.id$PosX, fish.id$PosY, xlab = 'Original', ylab = '')
  axes <- par('usr')
  filt <- rep(1/smooth, smooth)
  rem.tot <- data.frame(numeric(0))
  iteration <- 0
  
  repeat{
    
    fish.id$PosX.ma <- filter(fish.id$PosX, filt, sides = 1)
    fish.id$PosY.ma <- filter(fish.id$PosY, filt, sides = 1)
    fish.id$PosZ.ma <- filter(fish.id$PosZ, filt, sides = 1)
    fish.id$PosX.ma <- as.numeric(fish.id$PosX.ma)
    fish.id$PosY.ma <- as.numeric(fish.id$PosY.ma)
    fish.id$PosZ.ma <- as.numeric(fish.id$PosZ.ma)
    
    rem <- subset(fish.id, !(fish.id$PosX < (fish.id$PosX.ma+thresh) & fish.id$PosX > (fish.id$PosX.ma-thresh) & fish.id$PosY < (fish.id$PosY.ma+thresh) & fish.id$PosY > (fish.id$PosY.ma-thresh) & fish.id$PosZ < (fish.id$PosZ.ma+thresh) & fish.id$PosZ > (fish.id$PosZ.ma-thresh) | is.na(fish.id$PosX.ma) == TRUE))
    fish.id <- subset(fish.id, fish.id$PosX < (fish.id$PosX.ma+thresh) & fish.id$PosX > (fish.id$PosX.ma-thresh) & fish.id$PosY < (fish.id$PosY.ma+thresh) & fish.id$PosY > (fish.id$PosY.ma-thresh) & fish.id$PosZ < (fish.id$PosZ.ma+thresh) & fish.id$PosZ > (fish.id$PosZ.ma-thresh) | is.na(fish.id$PosX.ma) == TRUE)
    
    rem.tot <- rbind(rem.tot, rem)
    iteration <- iteration+1
    
    if (nrow(rem) == 0){break}
    rem <- data.frame(numeric(0))
  }
  
  cat(paste('Iterations =', iteration, '\n', sep = ' '))
  cat(paste('obervations removed =', nrow(rem.tot), '\n', sep = ' '))
  cat(paste('observations remaining =', nrow(fish.id), '\n', sep = ' '))
  plot(rem.tot$PosX, rem.tot$PosY, xlim = c(axes[[1]], axes[[2]]), ylim = c(axes[[3]], axes[[4]]), xlab = 'Observations removed', ylab = '')
  plot(fish.id$PosX, fish.id$PosY, xlim = c(axes[[1]], axes[[2]]), ylim = c(axes[[3]], axes[[4]]), xlab = 'Observations remaining', ylab = '')
  plot(fish.id$EchoTime, fish.id$PosZ, xlab = 'Time series', type = 'l')
  
  fish.id$PosX.ma <- NULL
  fish.id$PosY.ma <- NULL
  fish.id$PosZ.ma <- NULL
  
  fish.id <<- fish.id
  
}

# 28. add single fish to dayfile after cleaning data using ma.filter

add <- function(period){
  
  dayfile <- subset(dayfile, !(dayfile$Period == period))
  dayfile <- rbind(dayfile, fish.id)
  #dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
  #dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
  
  dayfile <<- dayfile
  
}

# 29. function to recode fish speeds and save to dayfile after cleaning data

recode <- function(masterfileloc = "H:/Data processing/AcousticTagFile_2016.xlsx"){
  
  fishid_tbl <- readWorksheetFromFile(masterfileloc, sheet = 5, startRow = 18, endCol = 16) # read in code from Fish ID lookup table
  
  periods <- unique(dayfile$Period)
  SEC <- numeric(0)
  for(i in 1:length(periods)){
    SEC <- c(SEC, as.integer(c(NA, diff(subset(dayfile$EchoTime, dayfile$Period == periods[i]), lag = 1, differences = 1)))) # calculate time delay between pings
  }
  dayfile$SEC <- SEC
  rm(SEC)  
  
  dayfile$M <- round(c(0, sqrt(diff(dayfile$PosX)^2+diff(dayfile$PosY)^2+diff(dayfile$PosZ)^2)), digits = 3) # calculate distance between pings
  dayfile$MSEC <- round(dayfile$M/dayfile$SEC, digits = 3) # calculate swimming speed in m/sec
  dayfile$MSEC <- as.numeric(sub("Inf", "0", dayfile$MSEC)) # replace "Inf" entries
  dayfile <- subset(dayfile, !dayfile$SEC <0 | is.na(dayfile$SEC) == T) # remove negative time differences
  
  fishid.bl.lookup <- fishid_tbl$L_m # create fish ID lookup table
  names(fishid.bl.lookup) <- fishid_tbl$Period
  dayfile$BL <- as.numeric(fishid.bl.lookup[as.character(dayfile$Period)]) # add fish lengths to day file
  dayfile$BLSEC <- round(dayfile$MSEC/dayfile$BL, 3) # calculate BL per sec
  
  write.csv(dayfile, file = sub("coded.csv", "recoded.csv", dayfile.loc, ignore.case = FALSE, fixed = T)) #write output to file
  
}


# 30. batch function to subset and save data according to specified variable and factors

batch.subset <- function(variable = 'SUN', factors = c('N', 'W', 'D', 'K')) {
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
  for (i in 1:length(files))
  {
    dayfile.loc <- files[[i]]
    dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                                                                              'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                              'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                              'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double'
                                                                              )) #read data into table
    
    #SORT BY TIME AND TAG
    dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
    dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
  
    for (j in 1:length(factors))
    {
    assign(factors[[j]], subset(dayfile, dayfile[,variable] == factors[[j]]))  
    write.csv(get(factors[[j]]), file = sub('.csv', paste0('_', factors[[j]], '.csv'), files[[i]]))
    remove(list = ls(pattern = factors[[j]])) 
    }
    
  }
  
}



# 31a. Create series of heatplots for animation

heatplot.anim <- function(pen, frames){
  
  system.time({ 
    dir.create(paste0(workingdir, '/animate'))
    setwd(paste0(workingdir, '/animate'))
    
    #frames = 24
    #pen = 7
    
    #dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
    
    pen.col <- 'black'
    pen.size <- 0.8
    plot.col <- matlab.like(1000)  
    
    pingmax <- as.integer((as.double(max(dayfile$EchoTime))-as.double(min(dayfile$EchoTime)))/(500*5))
    
    if(pen == 7){
      pen.group <- subset(dayfile, PEN == 7)
    } else {
      pen.group <- subset(dayfile, PEN == 8)
    }
    
    minseg <- pen.group[1,'EchoTime']-seconds(1)
    
    for(i in 1:frames){
      
      # creating a name for each plot file with leading zeros
      if (i < 10) {name = paste('000',i,'plot.png',sep='')}
      
      if (i < 100 && i >= 10) {name = paste('00',i,'plot.png', sep='')}
      if (i >= 100) {name = paste('0', i,'plot.png', sep='')}
      
      # code to prepare dataset for each frame
      maxseg <- pen.group[1, 'EchoTime']+hours(i)
      
      fish.id <- subset(pen.group, EchoTime > minseg & EchoTime < maxseg)
      
      #saves the plot as a .png file in the working directory
      #png(name)
      sun <- ifelse(fish.id[1, 'SUN'] == 'N', 'Night', ifelse(fish.id[1, 'SUN'] == 'W', 'Dawn', ifelse(fish.id[1, 'SUN'] == 'K', 'Dusk', ifelse(fish.id[1,'SUN'] == 'D', 'Day', sun))))
      
      if(fish.id[1, 'PEN'] == 7){  
        
        ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY)) +
          geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, pingmax), na.value = plot.col[length(plot.col)], name = 'No. pings') +
          annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
          annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
          annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
          annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
          annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
          annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
          annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
          annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
          annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
          annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
          annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
          annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
          annotate('text', x = 42, y = 42, label = paste(as.character(i), 'h', sep = ' ')) + # hour count
          annotate('text', x = 42, y = 40, label = sun) + # Time of day
          theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
          scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45)) # set scale limits
        
      } else {
        
        ggplot(fish.id, aes(fish.id$PosX, fish.id$PosY)) +
          geom_hex(bins = 55, alpha = 0.6) + scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, pingmax), na.value = plot.col[length(plot.col)], name = 'No. pings') +
          annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
          annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
          annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
          annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
          annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
          annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
          annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
          annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
          annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
          annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
          annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
          annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
          annotate('text', x = 69, y = 42, label = paste(as.character(i), 'h', sep = ' ')) + # hour count
          annotate('text', x = 69, y = 40, label = sun) + # Time of day
          theme(panel.background = element_rect(fill = 'white', colour = 'black')) +
          scale_x_continuous('x (m)', limits = c(35,70)) + scale_y_continuous('y (m)', limits = c(10,45))  
        
      }
      
      ggsave(name)
      #write.csv(fish.id, paste0(as.character(i), '.csv'))
      
      #dev.off()
      minseg <- maxseg
    }
    
    
    setwd(workingdir)
  })
}



# 31b. Create series of individual fish plots for animation

fishplot.anim <- function(pen, frames, framedur, animdur){
  
  system.time({ 
    dir.create(paste0(workingdir, '/animate'))
    setwd(paste0(workingdir, '/animate'))
    
    dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
    
    pen.col <- 'black'
    pen.size <- 0.8
    #fish.cols <- brewer.pal(8, 'Dark2')  
    #fish.cols <- c(brewer.pal(7, 'Dark2'), brewer.pal(3, 'Paired')) 
    

    
    
    #pingmax <- as.integer((as.double(max(dayfile$EchoTime))-as.double(min(dayfile$EchoTime)))/(500*5))
    
    if(pen == 7){
      pen.group <- subset(dayfile, PEN == 7)
    } else {
      pen.group <- subset(dayfile, PEN == 8)
    }
    
    fish.codes <- unique(pen.group$Period)
    
    if(length(fish.codes) < 9){
      colours <- brewer.pal(length(fish.codes), 'Dark2')  
    } else {
      colours <- c(brewer.pal(8, 'Dark2'), brewer.pal(length(fish.codes)-8, 'Set1'))  
    }
    
    colours <- sort(colours)
    
    minseg <- pen.group[1,'EchoTime']#-seconds(1)
    
    fish.id <- data.frame(Period = double(), PEN = factor(), EchoTime = as.POSIXct(character()), PosX = double(), PosY = double(), PosZ = double(), BLSEC = double())
    
    if(pen.group[1, 'PEN'] == 7){
      
      fish.plot <- ggplot() + #fish.id, aes(fish.id$PosX, fish.id$PosY)) +
        scale_x_continuous('x (m)', limits = c(10, 45)) + scale_y_continuous('y (m)', limits = c(10,45)) + # set scale limits      
        theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
        #geom_point(fish.id, aes(fish.id$PosX, fish.id$PosY)) + #scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, pingmax), na.value = plot.col[length(plot.col)], name = 'No. pings') +
        annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
        annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CNW', 'xmin'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, size = pen.size) +  # pen boundary
        annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymax'], yend = locations.lookup['7CNE', 'ymax'], colour = pen.col, size = pen.size) + # pen boundary
        annotate('segment', x = locations.lookup['7CNE', 'xmax'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, size = pen.size) + # pen boundary
        annotate('segment', x = locations.lookup['7CSW', 'xmin'], xend = locations.lookup['7CSE', 'xmax'], y = locations.lookup['7CSW', 'ymax'], yend = locations.lookup['7CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
        annotate('segment', x = locations.lookup['7CSW', 'xmax'], xend = locations.lookup['7CNW', 'xmax'], y = locations.lookup['7CSW', 'ymin'], yend = locations.lookup['7CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
        annotate('segment', x = locations.lookup['7CNW', 'xmin'], xend = locations.lookup['7CNE', 'xmax'], y = locations.lookup['7CNW', 'ymin'], yend = locations.lookup['7CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
        annotate('segment', x = locations.lookup['7CNE', 'xmin'], xend = locations.lookup['7CSE', 'xmin'], y = locations.lookup['7CNE', 'ymax'], yend = locations.lookup['7CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) + # pen location boundary
        annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
        annotate('curve', x = locations.lookup['7WHNW', 'xmin']+1, xend = locations.lookup['7WHNW', 'xmax']-1, y = locations.lookup['7WHNW', 'ymin']+1, yend = locations.lookup['7WHNW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
        annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
        annotate('curve', x = locations.lookup['7WHSE', 'xmin']+1, xend = locations.lookup['7WHSE', 'xmax']-1, y = locations.lookup['7WHSE', 'ymin']+1, yend = locations.lookup['7WHSE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
        theme(legend.position = 'none')
      #annotate('text', x = 42, y = 42, label = paste(as.character(i), 'h', sep = ' ')) + # hour count
      #annotate('text', x = 42, y = 40, label = sun) + # Time of day
      
    } else {
      
      fish.plot <- ggplot() + #fish.id, aes(fish.id$PosX, fish.id$PosY)) +
        scale_x_continuous('x (m)', limits = c(35,70)) + scale_y_continuous('y (m)', limits = c(10,45)) +      
        theme(panel.background = element_rect(fill = 'white', colour = 'black')) + # white background, black lines
        annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
        annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CNW', 'xmin'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, size = pen.size) +
        annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymax'], yend = locations.lookup['8CNE', 'ymax'], colour = pen.col, size = pen.size) +
        annotate('segment', x = locations.lookup['8CNE', 'xmax'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, size = pen.size) +
        annotate('segment', x = locations.lookup['8CSW', 'xmin'], xend = locations.lookup['8CSE', 'xmax'], y = locations.lookup['8CSW', 'ymax'], yend = locations.lookup['8CSE', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
        annotate('segment', x = locations.lookup['8CSW', 'xmax'], xend = locations.lookup['8CNW', 'xmax'], y = locations.lookup['8CSW', 'ymin'], yend = locations.lookup['8CNW', 'ymax'], colour = pen.col, linetype = 'dotted', size = pen.size) +
        annotate('segment', x = locations.lookup['8CNW', 'xmin'], xend = locations.lookup['8CNE', 'xmax'], y = locations.lookup['8CNW', 'ymin'], yend = locations.lookup['8CNE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
        annotate('segment', x = locations.lookup['8CNE', 'xmin'], xend = locations.lookup['8CSE', 'xmin'], y = locations.lookup['8CNE', 'ymax'], yend = locations.lookup['8CSE', 'ymin'], colour = pen.col, linetype = 'dotted', size = pen.size) +
        annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
        annotate('curve', x = locations.lookup['8WHSW', 'xmin']+1, xend = locations.lookup['8WHSW', 'xmax']-1, y = locations.lookup['8WHSW', 'ymin']+1, yend = locations.lookup['8WHSW', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
        annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = 1) + # hide boundary
        annotate('curve', x = locations.lookup['8WHNE', 'xmin']+1, xend = locations.lookup['8WHNE', 'xmax']-1, y = locations.lookup['8WHNE', 'ymin']+1, yend = locations.lookup['8WHNE', 'ymax']-1, colour = pen.col, size = pen.size, curvature = -1) + # hide boundary
        theme(legend.position = 'none')
      #  annotate('text', x = 69, y = 42, label = paste(as.character(i), 'h', sep = ' ')) + # hour count
      #  annotate('text', x = 69, y = 40, label = sun) + # Time of day
      
    }
    
    
    #for(j in 1:length(fish.codes)){
    #  assign(as.character(paste0('fish_', fish.codes[[j]])), data.frame(Period = double(), PEN = factor(), EchoTime = as.POSIXct(character()), PosX = double(), PosY = double(), PosZ = double(), BLSEC = double())) 
    #}  
    
    
    for(i in 1:frames){
      
      # creating a name for each plot file with leading zeros
      if (i < 10) {name = paste('000',i,'plot.png',sep='')}
      
      if (i < 100 && i >= 10) {name = paste('00',i,'plot.png', sep='')}
      if (i >= 100) {name = paste('0', i,'plot.png', sep='')}
      
      # code to prepare dataset for each frame
      maxseg <- pen.group[1, 'EchoTime']+seconds(i*framedur)
      
      #for(k in 1:length(fish.codes)){
      
      #assign(as.character(paste0('fish_', fish.codes[[k]])), rbind(get(as.character(paste0('fish_', fish.codes[[k]]))), subset(pen.group, EchoTime >= minseg & EchoTime < maxseg & Period == as.character(fish.codes[[k]]), select=c(Period, PEN, EchoTime, PosX, PosY, PosZ, BLSEC))))
      
      
      if(animdur == 0){
        
        fish.id <- rbind(fish.id, subset(pen.group, EchoTime >= minseg & EchoTime < maxseg, select=c(Period, PEN, EchoTime, PosX, PosY, PosZ, BLSEC, SUN)))
        
      } else{
        
        fish.id <- rbind(fish.id, subset(pen.group, EchoTime >= minseg & EchoTime < maxseg, select=c(Period, PEN, EchoTime, PosX, PosY, PosZ, BLSEC, SUN)))  
        fish.id <- subset(fish.id, EchoTime >= minseg-seconds(framedur*animdur))
        
      }
      
      
      #saves the plot as a .png file in the working directory
      sun <- ifelse(fish.id[1, 'SUN'] == 'N', 'Night', ifelse(fish.id[1, 'SUN'] == 'W', 'Dawn', ifelse(fish.id[1, 'SUN'] == 'K', 'Dusk', ifelse(fish.id[1,'SUN'] == 'D', 'Day', sun))))
      
      #xinput <- paste0('fish_', as.character(fish.codes[[k]]), '$PosX')
      #yinput <- paste0('fish_', as.character(fish.codes[[k]]), '$PosY')
      #fish.id <- fish.id[order(fish.id$EchoTime, na.last = FALSE, decreasing = TRUE, method = c("shell")),] # reverse chronological order
      #chronord <- as.factor(fish.id$EchoTime)
      
      
      if(pen.group[1, 'PEN'] == 7){
        fish.plot + geom_point(data = fish.id, aes(x = PosX, y = PosY, colour = as.factor(Period), alpha = as.factor(EchoTime)), size = 2) + scale_fill_manual(values = fish.cols) + scale_alpha_manual(values = seq(0.1, 1, length.out = nrow(fish.id))) +
          annotate('text', x = 42, y = 45, label = max(fish.id$EchoTime)) + # time stamp
          annotate('text', x = 42, y = 43, label = sun) # day period
      }
      
      if(pen.group[1, 'PEN'] == 8){
        fish.plot + geom_point(data = fish.id, aes(x = PosX, y = PosY, colour = as.factor(Period), alpha = as.factor(EchoTime)), size = 2) + scale_fill_manual(values = fish.cols) + scale_alpha_manual(values = seq(0.1, 1, length.out = nrow(fish.id))) +
          annotate('text', x = 66, y = 45, label = max(fish.id$EchoTime)) + # time stamp
          annotate('text', x = 66, y = 43, label = sun) # day period  
        
      }
      
      
      
      #fish.plot + geom_point(aes(x = fish.id$PosX, y = fish.id$PosY, colour = factor(fish.id$Period)))  + scale_alpha_discrete(range = c(1, 0.2))
      #fish.plot <- fish.plot + geom_point(aes(x = eval(parse(text = xinput)), y = eval(parse(text = yinput)), colour = fish.cols[[1]]))
      
      
      
      #}
      
      #print(fish.plot)
      
      ggsave(name)
      
      minseg <- maxseg
    }
    
    
    setwd(workingdir)
  })
}



# 32. draw histogram of fish depth or activity from fish files

fish.hist <- function(pt){
  
  if(pt == 'depth'){plot.type <- 'PosZ'}
  if(pt == 'activity'){plot.type <- 'BLSEC'}  
  
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE) 
  
  if(length(files) < 13){
    colours <- brewer.pal(length(files), 'Set3')  
  } else {
    colours <- c(brewer.pal(12, 'Set3'), brewer.pal(length(files)-12, 'Set1'))  
  }
  
  colours <- sort(colours)
  
  fish.codes <- substr(files, 15, 18)
  
  for(i in 1: length(files)) {
    
    assign(paste0('dayfile', as.character(i)), read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                                                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                                                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                                                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                                                             'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                                                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double'
                                                                                                             
    ))) #read data into table
    
    if(pt == 'activity'){
      assign(paste0('dayfile', as.character(i)), subset(get(paste0('dayfile', (i))), BLSEC < 5 & BLSEC >= 0 ))
      
    }
    
    #assign('dayfile1', subset(dayfile1, BLSEC < 10))  
    
  }
  
  
  
  hdep <- ggplot()
  
  for(j in 1: length(files)){
    
    # hdep <- print(hdep + geom_freqpoly(data = get(paste0('dayfile', as.character(j))), binwidth = 0.3, aes(get(paste0('dayfile', as.character(j)))[,'PosZ'])))
    loop_input = paste0('geom_freqpoly(data = dayfile', as.character(j), ', binwidth = 0.3, size = 1, aes(dayfile', as.character(j), '$', plot.type, ', color = colours[[', (j), ']]))')
    hdep <- hdep + eval(parse(text = loop_input))
    
  }
  
  hdep <- hdep + theme(panel.background = element_rect(fill = 'white', colour = 'black'))
  hdep <- hdep + scale_colour_manual('Fish ID', labels = fish.codes, values = colours)
  if(pt == 'depth'){
    hdep <- hdep + labs(x = 'Depth (m)', colour = 'fish ID') + scale_y_continuous(limits = c(0, 40000))
    hdep <- hdep + coord_flip() + scale_x_reverse()
  }
  if(pt == 'activity'){
    hdep <- hdep + labs(x = 'Activity (BL/s)', colour = 'fish ID') + scale_y_continuous(limits = c(0, 120000))
  }
  
  print(hdep)
  hdep <<- hdep
  
  
}



# 33. Load all data into single data frame

load.all <- function(){
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
  dayfile <- data.frame()
  
  for(i in 1:length(files)){
    
    #daytemp <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes) #read data into table
    daytemp <- fread(files[[i]])
    
    
    dayfile <- rbind(dayfile, daytemp)
    
  }
  
  dayfile$EchoTime <- as.POSIXct(dayfile$EchoTime)
  dayfile$V1 <- NULL
  
  #SORT BY TIME AND TAG
  #dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
  #dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
  
  dayfile <<- dayfile
  
}


#34. Crop edges of dataset to remove multipath

crop <- function(xmin = 30, xmax = 64, ymin = 7, ymax = 42){
  
  dayfile <- subset(dayfile, dayfile$PosY > ymin & dayfile$PosY < ymax & dayfile$PosX > xmin & dayfile$PosX < xmax)
  
  dayfile <<- dayfile
  
}


#35. Save loaded dayfile to .csv file of original name

save <- function(){
  
  write.csv(dayfile, file = dayfile.loc) #write output to file
  
}



#36. calculate distance travelled for each fish in dayfile

distance <- function(){
  
  fish.codes <- unique(dayfile$Period) 
  
  total.dist <- as.data.frame(setNames(replicate(2, numeric(0), simplify = F), c('Fish_ID', 'distance_m')))
  
  for (i in 1:length(fish.codes)){
    
    total.dist[i,] <- c(fish.codes[i], round(sum(dayfile[dayfile$Period == fish.codes[[i]],]$M), 1))
    
  }
  total.dist$distance_m <- as.double(total.dist$distance_m)
  ggplot(total.dist, aes(ID, distance_m)) + geom_bar(stat = 'identity') + scale_x_discrete('fish ID') + scale_y_continuous('distance (m)')
  total.dist
  
}

#37. calculate distance travelled in multiple fish files

batch.dist <- function(){
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  total.dist <- as.data.frame(setNames(replicate(2, numeric(0), simplify = F), c('Fish_ID', 'distance_km')))
  
  for(i in 1:length(files)){
    
    dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'numeric', 'factor', 'factor', 'POSIXct', 'double', 'double', 
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'factor',
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor',
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                             'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 'factor', 
                                                                             'factor', 'factor', 'double', 'double', 'double', 'double', 'double', 
                                                                             'double', 'double', 'double', 'double', 'double', 'double', 'double'
                                                                             
    )) #read data into table
    
    fish.codes <- unique(dayfile$Period) 
    total.dist[i,] <- c(fish.codes[1], (round(sum(dayfile[dayfile$Period == fish.codes[[1]],]$M), 2)/1000))
    
    
  }
  
  total.dist$distance_km <- as.double(total.dist$distance_km)
  total.dist$Fish_ID <- as.character(total.dist$Fish_ID)
  distplot <- ggplot(total.dist, aes(Fish_ID, distance_km)) + geom_bar(stat = 'identity') + scale_x_discrete('fish ID') + scale_y_continuous('distance (km)', expand = c(0, 0))
  total.dist  <<- total.dist
  print(distplot)
  return(distplot)
  #distplot <<- distplot
  
  
}


# 38. Load dayfile

load.dayfile <- function(filename){
  
  setwd(workingdir)  
  dayfile <- read.csv(filename, header = TRUE, sep = ",", colClasses = dayfile.classes)  
  
  dayfile <<- dayfile
  
  
}  


# 39. Multiple plot function
#
# ggplot objects can be passed in ..., or to plotlist (as a list of ggplot objects)
# - cols:   Number of columns in layout
# - layout: A matrix specifying the layout. If present, 'cols' is ignored.
#
# If the layout is something like matrix(c(1,2,3,3), nrow=2, byrow=TRUE),
# then plot 1 will go in the upper left, 2 will go in the upper right, and
# 3 will go all the way across the bottom.
#
multiplot <- function(..., plotlist=NULL, file, cols=1, layout=NULL) {
  library(grid)
  
  # Make a list from the ... arguments and plotlist
  plots <- c(list(...), plotlist)
  
  numPlots = length(plots)
  
  # If layout is NULL, then use 'cols' to determine layout
  if (is.null(layout)) {
    # Make the panel
    # ncol: Number of columns of plots
    # nrow: Number of rows needed, calculated from # of cols
    layout <- matrix(seq(1, cols * ceiling(numPlots/cols)),
                     ncol = cols, nrow = ceiling(numPlots/cols))
  }
  
  if (numPlots==1) {
    print(plots[[1]])
    
  } else {
    # Set up the page
    grid.newpage()
    pushViewport(viewport(layout = grid.layout(nrow(layout), ncol(layout))))
    
    # Make each plot, in the correct location
    for (i in 1:numPlots) {
      # Get the i,j matrix positions of the regions that contain this subplot
      matchidx <- as.data.frame(which(layout == i, arr.ind = TRUE))
      
      print(plots[[i]], vp = viewport(layout.pos.row = matchidx$row,
                                      layout.pos.col = matchidx$col))
    }
  }
}



# 40. Polar plots of headings

headplot <- function(threshold = 0.1){
  
  p7 <- subset(dayfile, PEN == 7 & MSEC >= threshold)
  p8 <- subset(dayfile, PEN == 8 & MSEC >= threshold)
  
  pplot7 <- ggplot(p7, aes(HEAD))
  pplot7 <- pplot7 + geom_histogram(breaks = seq(0, 360, 10), color = 'black', alpha = 0, size = 0.75, closed = 'left') + 
    theme_minimal() + theme(axis.text.y = element_blank(), axis.title.y = element_blank()) +
    scale_x_continuous('', limits = c(0, 360), expand = c(0, 0), breaks = c(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330)) +
    #scale_y_continuous(limits = c(0, 1500)) +
    coord_polar(theta = 'x', start = 0) +
    ggtitle('Acclimated wrasse') + theme(plot.title = element_text(hjust = 0.5))
  
  pplot8 <- ggplot(p8, aes(HEAD))
  pplot8 <- pplot8 + geom_histogram(breaks = seq(0, 360, 10), color = 'black', alpha = 0, size = 0.75) + 
    theme_minimal() + theme(axis.text.y = element_blank(), axis.title.y = element_blank()) +
    scale_x_continuous('', limits = c(0, 360), breaks = c(0, 30, 60, 90, 120, 150, 180, 210, 240, 270, 300, 330)) +
    # scale_y_continuous(limits = c(0, 1500)) +
    coord_polar(theta = 'x', start = 0) +
    ggtitle('Non-acclimated wrasse') + theme(plot.title = element_text(hjust = 0.5))
  
  multiplot(pplot7, pplot8, cols = 2)
  
}




# 45. calculate behaviour state frequencies

bsf <- function(static = 0.15, cruise = 1.1, save = T){
  
  bsffile <- dayfile[,c('Period', 'PEN', 'SEC', 'BLSEC')]
  bsffile$BSF <- ifelse(bsffile$BLSEC <= static, 'static', ifelse(bsffile$BLSEC > static & bsffile$BLSEC <= cruise, 'cruise', 'burst'))
  bsffile$BSFcount <- sequence(rle(bsffile$BSF)$lengths)
  bsffile$CountTF <- c(ifelse(diff(bsffile$BSFcount, 1, 1) < 1, T, F), F)
  
  #bsfsum <- 0
  
  #for (i in 1:nrow(bsffile)){
  #  bsfsum <- bsfsum + bsffile[i, 'SEC']
  #  if(bsffile[i, 'CountTF'] == T & is.na(bsffile[i, 'SEC']) == F){
  #    bsffile[i,'BSFdur2'] <- bsfsum
  #    bsfsum <- 0
  #  } else {
  #    bsffile[i,'BSFdur2'] <- NA    
  #  }
  #}
  
  
  library(data.table)
  
  setDT(bsffile)
  bsffile[,BSFdur:=ifelse(CountTF == T, sum(SEC),0), by =.(rleid(BSF))] # sums secs for each behaviour bout
  
  detach("package:data.table")
  
  bsffile <- subset(bsffile, BSFdur > 0)
  #bsffile$round <- as.numeric(as.character(cut(bsffile$BSFdur, breaks = c(0, 1, 2, 5, 10, 20, 50, 100, 200, 500, 1000), labels = c('1', '2', '5', '10', '20', '50', '100', '200', '500', '1000'))))
  bsffile$round <- as.numeric(as.character(cut(bsffile$BSFdur, breaks = c(0, 1, 2, 4, 8, 16, 32, 64, 128, 256, 512, 1024), labels = c('1', '2', '4', '8', '16', '32', '64', '128', '256', '512', '1024'))))
  
  # generates table of BSF frequencies and draws plot
  
  bsffile$BSF <- as.factor(bsffile$BSF)
  
  bsftab <- as.data.frame(table(bsffile$round, bsffile$BSF, bsffile$PEN)) # tabulate frequencies of each duration and BSF
  names(bsftab) <- c('dur', 'BSF', 'pen', 'count')
  bsftab$dur <- as.numeric(as.character(bsftab$dur))
  bsftab$count <- as.numeric(bsftab$count)
  
  bsfsum <- tapply(bsftab$count, list(bsftab$BSF, bsftab$pen), sum)
  bsftab$freq <- ifelse(bsftab$BSF == 'static' & bsftab$pen == '7', bsftab$count / bsfsum[3,1], ifelse(bsftab$BSF == 'cruise' & bsftab$pen == '7', bsftab$count / bsfsum[2,1], ifelse(bsftab$BSF == 'burst' & bsftab$pen == '7', bsftab$count / bsfsum[1,1], ifelse(bsftab$BSF == 'static' & bsftab$pen == '8', bsftab$count / bsfsum[3,2], ifelse(bsftab$BSF == 'cruise' & bsftab$pen == '8', bsftab$count / bsfsum[2,2], ifelse(bsftab$BSF == 'burst' & bsftab$pen == '8', bsftab$count / bsfsum[1,2], NA))))))
  
  bsftab <- subset(bsftab, bsftab$freq > 0)
  
  power_eqn = function(df, start = list(a = 50, b = 1)){
    m = nls(freq ~ a*dur^b, start = start, data = df);
    #eq <- substitute(italic(y) == a  ~italic(x)^b, list(a = format(coef(m)[1], digits = 2), b = format(coef(m)[2], digits = 2)))
    eq <- substitute(italic(y) == a  ~italic(x)^b, list(a = format(coef(m)[1], digits = 2), b = format(coef(m)[2], digits = 2)))
    as.character(as.expression(eq));                 
  }
  
  grouppal <- c(brewer.pal(3, 'Set1')[[1]], brewer.pal(3, 'Set1')[[2]], brewer.pal(3, 'Set1')[[1]], brewer.pal(3, 'Set1')[[2]])
  
  sp = ggplot(subset(bsftab, BSF == 'static'), aes(x=dur, y=freq, colour = pen)) + theme(panel.background = element_rect(fill = 'white', colour = 'black'))
  sp = sp + scale_x_log10(limits = c(10, 1000), breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000))
  #sp = sp + scale_y_log10(breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000)) 
  sp = sp + scale_y_log10(limits = c(0.001, 1), breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.8, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1), labels = c(bquote(10^-3), '', '', '', '', '', '', '', '', bquote(10^-2), '', '', '', '', '', '', '', '', bquote(10^-1), '', '', '', '', '', '', '', '', bquote(10^0))) 
  sp = sp + geom_path(size = 1) + labs(title = 'Static', x = 'duration', y = 'frequency') + guides(colour = F) + geom_smooth(linetype = 'dashed',  method = 'nls', formula = y~a*x^b, se = F) + geom_text(size = 4.5, hjust = 0, aes(x = 100, y = 1, colour = grouppal[[2]], label = power_eqn(subset(bsftab, pen == '7' & BSF == 'static'))), parse = TRUE) + geom_text(size = 4.5, hjust = 0, aes(x = 100, y = 0.6, colour = grouppal[[1]], label = power_eqn(subset(bsftab, pen == '8' & BSF == 'static'))), parse = TRUE) + scale_colour_manual(values = grouppal)
  
  #+ geom_text(aes(x = 100, y = 1, label = lm_eqn(lm(log(freq) ~ log(dur), subset(bsftab, pen == '7')))), parse = TRUE) + geom_text(aes(x = 100, y = 0.7, label = lm_eqn(lm(log(freq) ~ log(dur), subset(bsftab, pen == '8')))), parse = TRUE)
  
  cp = ggplot(subset(bsftab, BSF == 'cruise'), aes(x=dur, y=freq, colour = pen)) + theme(panel.background = element_rect(fill = 'white', colour = 'black'))
  cp = cp + scale_x_log10(limits = c(10, 1000), breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000))
  #cp = cp + scale_y_log10(breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000)) 
  cp = cp + scale_y_log10(limits = c(0.001, 1), breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.8, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1), labels = c(bquote(10^-3), '', '', '', '', '', '', '', '', bquote(10^-2), '', '', '', '', '', '', '', '', bquote(10^-1), '', '', '', '', '', '', '', '', bquote(10^0))) 
  #cp = cp + geom_path(size = 1) + labs(title = 'Cruise', x = 'duration', y = 'frequency') + guides(colour = F)
  cp = cp + geom_path(size = 1) + labs(title = 'Cruise', x = 'duration', y = 'frequency') + guides(colour = F) + geom_smooth(linetype = 'dashed',  method = 'nls', formula = y~a*x^b, se = F) + geom_text(size = 4.5, hjust = 0, aes(x = 100, y = 1, colour = grouppal[[2]], label = power_eqn(subset(bsftab, pen == '7' & BSF == 'cruise'))), parse = TRUE) + geom_text(size = 4.5, hjust = 0, aes(x = 100, y = 0.6, colour = grouppal[[1]], label = power_eqn(subset(bsftab, pen == '8' & BSF == 'cruise'))), parse = TRUE) + scale_colour_manual(values = grouppal)
  
  bp = ggplot(subset(bsftab, BSF == 'burst'), aes(x=dur, y=freq, colour = factor(pen, labels = c('conditioned', 'unconditioned')))) + theme(panel.background = element_rect(fill = 'white', colour = 'black'), legend.title = element_text(size = 16, face = 'bold'), legend.title.align = 0.5, legend.background = element_rect(colour = 'black', size = 1, linetype = 'solid'), legend.key.size = unit(1, 'cm'))
  bp = bp + scale_x_log10(limits = c(10, 1000), breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000))
  #bp = bp + scale_y_log10(breaks = c(1, 2, 3, 4, 5, 6, 7, 8, 9, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100, 200, 300, 400, 500, 600, 700, 800, 900, 1000, 2000, 3000, 4000, 5000, 6000, 7000, 8000, 9000, 10000), labels = c(1, '', '', '', '', '', '', '', '', 10, '', '', '', '', '', '', '', '', 100, '', '', '', '', '', '', '', '', 1000, '', '', '', '', '', '', '', '', 10000)) 
  bp = bp + scale_y_log10(limits = c(0.001, 1), breaks = c(0.001, 0.002, 0.003, 0.004, 0.005, 0.006, 0.007, 0.008, 0.009, 0.01, 0.02, 0.03, 0.04, 0.05, 0.06, 0.07, 0.8, 0.09, 0.1, 0.2, 0.3, 0.4, 0.5, 0.6, 0.7, 0.8, 0.9, 1), labels = c(bquote(10^-3), '', '', '', '', '', '', '', '', bquote(10^-2), '', '', '', '', '', '', '', '', bquote(10^-1), '', '', '', '', '', '', '', '', bquote(10^0))) 
  #bp = bp + geom_path(size = 1) + labs(title = 'Burst', x = 'duration', y = 'frequency', colour = 'Group')
  bp = bp + geom_path(size = 1) + labs(title = 'Burst', x = 'duration', y = 'frequency', colour = 'Group') + geom_smooth(linetype = 'dashed',  method = 'nls', formula = y~a*x^b, se = F) + geom_text(size = 4.5, hjust = 0, show.legend = F, aes(x = 100, y = 1, colour = grouppal[[2]], label = power_eqn(subset(bsftab, pen == '7' & BSF == 'burst'))), parse = TRUE) + geom_text(size = 4.5, hjust = 0, show.legend = F, aes(x = 100, y = 0.6, colour = grouppal[[1]], label = power_eqn(subset(bsftab, pen == '8' & BSF == 'burst'))), parse = TRUE) + scale_colour_manual(breaks = c('conditioned', 'unconditioned'), values = grouppal)
  
  legend <- get_legend(bp)
  bp = bp  + guides(colour = F)
  
  
  bsfplot <- plot_grid(sp, cp, bp, legend, nrow = 2, ncol = 2)
  daytext = paste('Day', substr(dayfile.loc, 15, 17), sep = ' ')
  bsfplot <- bsfplot + draw_text(daytext, size = 16, x = 0.71, y = 0.33, hjust = 0)
  print(bsfplot) 
  
  if(save == T){
    #ggsave(filename = sub('day_coded.csv', '_bsfplot.png', dayfile.loc), plot = bsfplot) 
    save_plot(sub('day_coded.csv', '_bsfplot.png', dayfile.loc), bsfplot, ncol = 2.5, nrow = 2.5, base_aspect_ratio = 1.1, base_height = 4)  
    write.csv(bsftab, file = sub("day_coded.csv", "_bsftable.csv", dayfile.loc))  
  }
  
}



# 51. density map of depth over time--------------------------------


# draw heatmap of time vs. depth

library(viridis)

dm <- ggplot(dayfile[dayfile$PEN == '8',], aes(x = EchoTime, y = PosZ)) +
  stat_density_2d(geom = 'raster', aes(fill = stat(density)), contour = F) + scale_fill_viridis() +
  #scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 100), na.value = plot.col[length(plot.col)], name = 'No. pings') +
  geom_density_2d(aes(colour = PosZ)) + #ylim(25, 0) +
  #scale_y_continuous(expand = c(0, 0), limits = c(0, 25)) + 
  scale_y_reverse(name = 'Depth (m)', expand = c(0, 0), limits = c(25, 0)) +
  scale_x_datetime(name = 'Date', expand = c(0, 0))
dm + theme(legend.position = 'none') + ggtitle('Non-acclimated wrasse')



dm <- ggplot(dayfile[dayfile$Period == '8081',], aes(x = EchoTime, y = PosZ)) +
  stat_density_2d(geom = 'raster', aes(fill = stat(density)), contour = F) + scale_fill_viridis() +
  #scale_fill_gradientn(colours=plot.col, space = 'Lab', limits = c(0, 100), na.value = plot.col[length(plot.col)], name = 'No. pings') +
  geom_density_2d(aes(colour = PosZ)) + #ylim(25, 0) +
  #scale_y_continuous(expand = c(0, 0), limits = c(0, 25)) + 
  scale_y_reverse(name = 'Depth (m)', expand = c(0, 0), limits = c(25, 0)) +
  scale_x_datetime(name = 'Date', expand = c(0, 0))
dm + theme(legend.position = 'none')# + ggtitle('Non-acclimated wrasse')


