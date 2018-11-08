#Delousing efficiency project data coding
#Adam Brooker
#12th July 2016

#Need to install MySQL and Java software on PC and RMySQL, XLConnectJars, XLconnect and rJava packages in R Studio before executing this code

# library(RMySQL)
library(rJava)
options(java.parameters = "-Xmx32000m")
library(XLConnectJars)
library(XLConnect) 
#library(rotations)
library(openxlsx)
library(dplyr)
library(tidyr)
library(tidyverse)
library(data.table)

#ENTER YOUR VARIABLES HERE
workingdir = "H:/Acoustic tag - Preconditioning A/Data processing/Filtered Data/Recoded Day CSV" # change to location of data
dayfileloc = "run_3LLF16S100168_day_coded.csv" # change to file to be analysed
masterfileloc = "H:/Data processing/AcousticTagFile_2016.xlsx" # change to location of AcousticTagFile.xlsx
day = '221' # day of the year
bottom.threshold = 15 # threshold for fish at bottom of cage coding (depth in metres)
water.height = 35
rot.ang = 335.12 # grid rotation angle in radians
UTMeast = 2978881.84 # grid origin x-axis
UTMnorth = 5546147.24 #  grid origin y-axis


# Enter periods of hide tags to be removed
hidetag1 = 10657 # P7 NW hide
hidetag2 = 11217 # P7 SE hide
hidetag3 = 10965 # P8 SW hide
hidetag4 = 10377 # P8 NE hide
hidetag5 = 0000
hidetag6 = 0000
hidetag7 = 0000
hidetag8 = 0000

# DON'T CHANGE ANYTHING AFTER THIS LINE UNLESS YOU KNOW WHAT YOU ARE DOING!

#------------------------------------------------------------------------------------------------------------------------------
# LOAD LOOKUP TABLES


# LOAD MASTERCODE
mastercode <- readWorksheetFromFile(masterfileloc, sheet = 11, startRow = 6, endCol = 115, colTypes = 'character') # read in mastercode from Acoustic Tag File
#mastercode <- read.xlsx(masterfileloc, sheetName = 'MasterCode', startRow = 6, endRow = 97, colIndex = seq(5, 95), colClasses = 'character')
rownames(mastercode) <- as.numeric(mastercode$DAY) # rename mastercode rows by day
mastercode$DATE <- substr(mastercode$DATE, 1, 10)

mastercode$SUN_N_S <- convert.to.date(col = mastercode$SUN_N_S)
mastercode$SUN_N_E <- convert.to.date(col = mastercode$SUN_N_E)
mastercode$SUN_W_S <- convert.to.date(col = mastercode$SUN_W_S)
mastercode$SUN_W_E <- convert.to.date(col = mastercode$SUN_W_E)
mastercode$SUN_D_S <- convert.to.date(col = mastercode$SUN_D_S)
mastercode$SUN_D_E <- convert.to.date(col = mastercode$SUN_D_E)
mastercode$SUN_K_S <- convert.to.date(col = mastercode$SUN_K_S)
mastercode$SUN_K_E <- convert.to.date(col = mastercode$SUN_K_E)
mastercode$SUN_N_S2 <- convert.to.date(col = mastercode$SUN_N_S2)
mastercode$SUN_N_E2 <- convert.to.date(col = mastercode$SUN_N_E2)

mastercode$TID_L_S <- convert.to.date(col = mastercode$TID_L_S)
mastercode$TID_L_E <- convert.to.date(col = mastercode$TID_L_E)
mastercode$TID_LH_S <- convert.to.date(col = mastercode$TID_LH_S)
mastercode$TID_LH_E <- convert.to.date(col = mastercode$TID_LH_E)
mastercode$TID_H_S <- convert.to.date(col = mastercode$TID_H_S)
mastercode$TID_H_E <- convert.to.date(col = mastercode$TID_H_E)
mastercode$TID_HL_S <- convert.to.date(col = mastercode$TID_HL_S)
mastercode$TID_HL_E <- convert.to.date(col = mastercode$TID_HL_E)
mastercode$TID_L_S2 <- convert.to.date(col = mastercode$TID_L_S2)
mastercode$TID_L_E2 <- convert.to.date(col = mastercode$TID_L_E2)
mastercode$TID_LH_S2 <- convert.to.date(col = mastercode$TID_LH_S2)
mastercode$TID_LH_E2 <- convert.to.date(col = mastercode$TID_LH_E2)
mastercode$TID_H_S2 <- convert.to.date(col = mastercode$TID_H_S2)
mastercode$TID_H_E2 <- convert.to.date(col = mastercode$TID_H_E2)
mastercode$TID_HL_S2 <- convert.to.date(col = mastercode$TID_HL_S2)
mastercode$TID_HL_E2 <- convert.to.date(col = mastercode$TID_HL_E2)

mastercode$SMEAL_P7_N_S <- convert.to.date(col = mastercode$SMEAL_P7_N_S)
mastercode$SMEAL_P7_N_E <- convert.to.date(col = mastercode$SMEAL_P7_N_E)
mastercode$SMEAL_P7_Y_S <- convert.to.date(col = mastercode$SMEAL_P7_Y_S)
mastercode$SMEAL_P7_Y_E <- convert.to.date(col = mastercode$SMEAL_P7_Y_E)
mastercode$SMEAL_P7_N_S2 <- convert.to.date(col = mastercode$SMEAL_P7_N_S2)
mastercode$SMEAL_P7_N_E2 <- convert.to.date(col = mastercode$SMEAL_P7_N_E2)
mastercode$SMEAL_P7_Y_S2 <- convert.to.date(col = mastercode$SMEAL_P7_Y_S2)
mastercode$SMEAL_P7_Y_E2 <- convert.to.date(col = mastercode$SMEAL_P7_Y_E2)
mastercode$SMEAL_P7_N_S3 <- convert.to.date(col = mastercode$SMEAL_P7_N_S3)
mastercode$SMEAL_P7_N_E3 <- convert.to.date(col = mastercode$SMEAL_P7_N_E3)
mastercode$SMEAL_P8_N_S <- convert.to.date(col = mastercode$SMEAL_P8_N_S)
mastercode$SMEAL_P8_N_E <- convert.to.date(col = mastercode$SMEAL_P8_N_E)
mastercode$SMEAL_P8_Y_S <- convert.to.date(col = mastercode$SMEAL_P8_Y_S)
mastercode$SMEAL_P8_Y_E <- convert.to.date(col = mastercode$SMEAL_P8_Y_E)
mastercode$SMEAL_P8_N_S2 <- convert.to.date(col = mastercode$SMEAL_P8_N_S2)
mastercode$SMEAL_P8_N_E2 <- convert.to.date(col = mastercode$SMEAL_P8_N_E2)
mastercode$SMEAL_P8_Y_S2 <- convert.to.date(col = mastercode$SMEAL_P8_Y_S2)
mastercode$SMEAL_P8_Y_E2 <- convert.to.date(col = mastercode$SMEAL_P8_Y_E2)
mastercode$SMEAL_P8_N_S3 <- convert.to.date(col = mastercode$SMEAL_P8_N_S3)
mastercode$SMEAL_P8_N_E3 <- convert.to.date(col = mastercode$SMEAL_P8_N_E3)

mastercode$AG7F1_N_S <- convert.to.date(col = mastercode$AG7F1_N_S)
mastercode$AG7F1_N_E <- convert.to.date(col = mastercode$AG7F1_N_E)
mastercode$AG7F1_Y_S <- convert.to.date(col = mastercode$AG7F1_Y_S)
mastercode$AG7F1_Y_E <- convert.to.date(col = mastercode$AG7F1_Y_E)
mastercode$AG7F1_M_S <- convert.to.date(col = mastercode$AG7F1_M_S)
mastercode$AG7F1_M_E <- convert.to.date(col = mastercode$AG7F1_M_E)
mastercode$AG7F2_N_S <- convert.to.date(col = mastercode$AG7F2_N_S)
mastercode$AG7F2_N_E <- convert.to.date(col = mastercode$AG7F2_N_E)
mastercode$AG7F2_Y_S <- convert.to.date(col = mastercode$AG7F2_Y_S)
mastercode$AG7F2_Y_E <- convert.to.date(col = mastercode$AG7F2_Y_E)
mastercode$AG7F2_M_S <- convert.to.date(col = mastercode$AG7F2_M_S)
mastercode$AG7F2_M_E <- convert.to.date(col = mastercode$AG7F2_M_E)
mastercode$AG8F1_N_S <- convert.to.date(col = mastercode$AG8F1_N_S)
mastercode$AG8F1_N_E <- convert.to.date(col = mastercode$AG8F1_N_E)
mastercode$AG8F1_Y_S <- convert.to.date(col = mastercode$AG8F1_Y_S)
mastercode$AG8F1_Y_E <- convert.to.date(col = mastercode$AG8F1_Y_E)
mastercode$AG8F1_M_S <- convert.to.date(col = mastercode$AG8F1_M_S)
mastercode$AG8F1_M_E <- convert.to.date(col = mastercode$AG8F1_M_E)
mastercode$AG8F2_N_S <- convert.to.date(col = mastercode$AG8F2_N_S)
mastercode$AG8F2_N_E <- convert.to.date(col = mastercode$AG8F2_N_E)
mastercode$AG8F2_Y_S <- convert.to.date(col = mastercode$AG8F2_Y_S)
mastercode$AG8F2_Y_E <- convert.to.date(col = mastercode$AG8F2_Y_E)
mastercode$AG8F2_M_S <- convert.to.date(col = mastercode$AG8F2_M_S)
mastercode$AG8F2_M_E <- convert.to.date(col = mastercode$AG8F2_M_E)

mastercode$LUMPEL_S <- convert.to.date(col = mastercode$LUMPEL_S)
mastercode$LUMPEL_E <- convert.to.date(col = mastercode$LUMPEL_E)

#LOAD FISH ID DATA
detach('package:xlsx')
fishid_tbl <- read.xlsx(masterfileloc, sheet = 5, rows = seq(18, 62), cols = c(2, 5, 7, 11)) # read in code from Fish ID lookup table
fishid_tbl$L_m <- round(as.numeric(fishid_tbl$L_m), digits = 3)

#LOAD LOCATIONS CODING DATA
locations.lookup <- read.xlsx(masterfileloc, sheet = 12, startRow = 1, cols = seq(1, 7)) # read in codes from Locations Coding spreadsheet
rownames(locations.lookup) <- locations.lookup$Code

#LOAD ENVIRONMENTAL PROBE READINGS
probe.DOT1 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(1, 2, 3))
probe.DOT1$DO.time.1m <- as.POSIXct(strptime(probe.DOT1$DO.time.1m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT1$DO.time.1m <- probe.DOT1$DO.time.1m - as.difftime(1, unit = 'hours')
probe.DOT1 <- probe.DOT1 %>% mutate_each(funs(round(.,2)), DO.1m, Temp.1m)
probe.sal1 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(4, 5))
probe.sal1$Sal.time.1m <- as.POSIXct(strptime(probe.sal1$Sal.time.1m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal1$Sal.time.1m <- probe.sal1$Sal.time.1m - as.difftime(1, unit = 'hours')
probe.sal1 <- probe.sal1 %>% mutate(Sal.1m = round(Sal.1m, 2))
probe.DOT2 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(6, 7, 8))
probe.DOT2$DO.time.2m <- as.POSIXct(strptime(probe.DOT2$DO.time.2m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT2$DO.time.2m <- probe.DOT2$DO.time.2m - as.difftime(1, unit = 'hours')
probe.DOT2 <- probe.DOT2 %>% mutate_each(funs(round(.,2)), DO.2m, Temp.2m)
probe.sal2 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(9, 10))
probe.sal2$Sal.time.2m <- as.POSIXct(strptime(probe.sal2$Sal.time.2m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal2$Sal.time.2m <- probe.sal2$Sal.time.2m - as.difftime(1, unit = 'hours')
probe.sal2 <- probe.sal2 %>% mutate(Sal.2m = round(Sal.2m, 2))
probe.DOT4 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(11, 12, 13))
probe.DOT4$DO.time.4m <- as.POSIXct(strptime(probe.DOT4$DO.time.4m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT4$DO.time.4m <- probe.DOT4$DO.time.4m - as.difftime(1, unit = 'hours')
probe.DOT4 <- probe.DOT4 %>% mutate_each(funs(round(.,2)), DO.4m, Temp.4m)
probe.sal4 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(14, 15))
probe.sal4$Sal.time.4m <- as.POSIXct(strptime(probe.sal4$Sal.time.4m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal4$Sal.time.4m <- probe.sal4$Sal.time.4m - as.difftime(1, unit = 'hours')
probe.sal4 <- probe.sal4 %>% mutate(Sal.4m = round(Sal.4m, 2))
probe.DOT12 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(16, 17, 18))
probe.DOT12$DO.time.12m <- as.POSIXct(strptime(probe.DOT12$DO.time.12m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.DOT12$DO.time.12m <- probe.DOT12$DO.time.12m - as.difftime(1, unit = 'hours')
probe.DOT12 <- probe.DOT12 %>% mutate_each(funs(round(.,2)), DO.12m, Temp.12m)
probe.sal12 <- read.xlsx(masterfileloc, sheet = 13, startRow = 3, cols = c(19, 20))
probe.sal12$Sal.time.12m <- as.POSIXct(strptime(probe.sal12$Sal.time.12m, "%m/%d/%y %I:%M:%S %p", tz = 'UTC'))
probe.sal12$Sal.time.12m <- probe.sal12$Sal.time.12m - as.difftime(1, unit = 'hours')
probe.sal12 <- probe.sal12 %>% mutate(Sal.12m = round(Sal.12m, 2))


# ----------------------------------------------------------------------------------------------------------------------------------------


#CODING

setwd(workingdir) 


# LOAD HOURFILE (for when coding hourfiles instead of dayfiles)
#dayfile_tbl <- read.csv(dayfile, header = TRUE, sep = ",", colClasses = c('NULL', 'NULL', 'NULL', 'character', 'character', 'NULL', 
#                                                                           'character', 'character', 'character', 'character', 'NULL', 'NULL', 
#                                                                           'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 
#                                                                           'NULL')) #read data into table

# LOAD DAYFILE
dayfile_tbl <- read.csv(dayfile, header = TRUE, sep = ",", colClasses = c('NULL', 'NULL', 'NULL', 'NULL', 'character', 'character', 'NULL', 
                                                                          'character', 'character', 'character', 'character', 'NULL', 'NULL', 
                                                                          'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 'NULL', 
                                                                          'NULL')) #read data into table

dayfile_tbl <- dayfile_tbl[!(dayfile_tbl$Period == 'Period'),] # remove old headers

#CONVERT FIELDS INTO CORRECT FORMATS
dayfile_tbl$Period <- sapply(dayfile_tbl$Period, as.numeric)
dayfile_tbl$SubCode <- sapply(dayfile_tbl$SubCode, as.numeric)
dayfile_tbl[, 'EchoTime'] <- as.POSIXct(strptime(dayfile_tbl[,'EchoTime'], "%d/%m/%Y %H:%M:%S", tz = "UTC")) # convert character format to date and time format
dayfile_tbl$PosX <- as.numeric(dayfile_tbl$PosX)
dayfile_tbl$PosY <- as.numeric(dayfile_tbl$PosY)
dayfile_tbl$PosZ <- as.numeric(dayfile_tbl$PosZ)

# TRANSLATE  COORDINATES INTO POSITIVE DEPTH AND ZERO ORIGIN

dayfile_tbl$PosX2 <- round((cos(rot.ang*pi/180)*dayfile_tbl$PosX-sin(rot.ang*pi/180)*dayfile_tbl$PosY)-UTMeast, digits = 2)
dayfile_tbl$PosY2 <- round((sin(rot.ang*pi/180)*dayfile_tbl$PosX+cos(rot.ang*pi/180)*dayfile_tbl$PosY)-UTMnorth, digits = 2)
dayfile_tbl$PosX <- dayfile_tbl$PosX2
dayfile_tbl$PosY <- dayfile_tbl$PosY2
dayfile_tbl$PosX2 <- NULL
dayfile_tbl$PosY2 <- NULL
dayfile_tbl$PosZ <- water.height-dayfile_tbl$PosZ

#REMOVE HIDE TAGS
#dayfile_tbl <- dayfile_tbl[!(dayfile_tbl$Period == hidetag1 | dayfile_tbl$Period == hidetag2 | dayfile_tbl$Period == hidetag3 | 
#               dayfile_tbl$Period == hidetag4 | dayfile_tbl$Period == hidetag5 | dayfile_tbl$Period == hidetag6 | dayfile_tbl$Period == hidetag7 | dayfile_tbl$Period == hidetag8),]

#REMOVE PINGS ABOVE WATER SURFACE
dayfile_tbl <- dayfile_tbl[!(dayfile_tbl$PosZ < 0),]

#SORT BY TIME AND TAG
#dayfile_tbl <- dayfile_tbl[order(dayfile_tbl$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
#dayfile_tbl <- dayfile_tbl[order(dayfile_tbl$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag
dayfile_tbl <- arrange(dayfile_tbl, Period, EchoTime) # sort by time and tag

#ADD PEN NUMBER
pen.lookup <- fishid_tbl$Pen # create pen lookup table
names(pen.lookup) <- fishid_tbl$Period
dayfile_tbl$PEN <- as.numeric(pen.lookup[as.character(dayfile_tbl$Period)]) # add pen number to day file
dayfile_tbl <- dayfile_tbl[,c('Period', 'SubCode', 'PEN', 'EchoTime', 'PosX', 'PosY', 'PosZ')] # reorder fields
  
  
#CALCULATE TIMES AND SPEEDS
periods <- unique(dayfile_tbl$Period)
SEC <- numeric(0)

for(i in 1:length(periods)){
SEC <- c(SEC, as.integer(c(NA, diff(subset(dayfile_tbl$EchoTime, dayfile_tbl$Period == periods[i]), lag = 1, differences = 1)))) # calculate time delay between pings
}
dayfile_tbl$SEC <- SEC
rm(SEC)
dayfile_tbl$M <- round(c(0, sqrt(diff(dayfile_tbl$PosX)^2+diff(dayfile_tbl$PosY)^2+diff(dayfile_tbl$PosZ)^2)), digits = 3) # calculate distance between pings
dayfile_tbl$MSEC <- round(dayfile_tbl$M/dayfile_tbl$SEC, digits = 3) # calculate swimming speed in m/sec
dayfile_tbl$MSEC <- as.numeric(sub("Inf", "0", dayfile_tbl$MSEC)) # replace "Inf" entries
dayfile_tbl <- subset(dayfile_tbl, dayfile_tbl$SEC >5 | is.na(dayfile_tbl$SEC) == TRUE) # remove entries where time delay too low or too high
#dayfile_tbl <- dayfile_tbl[!(dayfile_tbl$SEC <5 | dayfile_tbl$SEC >60),] # remove entries where time delay too low or too high
#dayfile_tbl <- dayfile_tbl[!(dayfile_tbl$SEC <5),] # remove entries where time delay too low or too high

#CALCULATE BODY LENGTHS/SEC
fishid.bl.lookup <- fishid_tbl$L_m # create fish ID lookup table
names(fishid.bl.lookup) <- fishid_tbl$Period
dayfile_tbl$BL <- as.numeric(fishid.bl.lookup[as.character(dayfile_tbl$Period)]) # add fish lengths to day file
dayfile_tbl$BLSEC <- round(dayfile_tbl$MSEC/dayfile_tbl$BL, 3) # calculate BL per sec
dayfile_tbl <- subset(dayfile_tbl, dayfile_tbl$BLSEC < 10 | is.na(dayfile_tbl$BLSEC) == TRUE) # remove entries where swimming speed is greater than 20 BL/sec (likely multipath)


#DYNAMIC HIDE CODING
dayfile_tbl <- arrange(dayfile_tbl, Period, EchoTime)

hide1 <- subset(dayfile_tbl, Period == hidetag1)
names(hide1)[names(hide1) == "EchoTime"] <- "HideTime"
hide2 <- subset(dayfile_tbl, Period == hidetag2)
names(hide2)[names(hide2) == "EchoTime"] <- "HideTime"
hide3 <- subset(dayfile_tbl, Period == hidetag3)
names(hide3)[names(hide3) == "EchoTime"] <- "HideTime"
hide4 <- subset(dayfile_tbl, Period == hidetag4)
names(hide4)[names(hide4) == "EchoTime"] <- "HideTime"

dayfile_tbl <- subset(dayfile_tbl, !(Period == hidetag1 | Period ==  hidetag2 | Period == hidetag3 | Period == hidetag4))
detach("package:dplyr")



hide.filter(hide1, 10, 2.5)
hide1 <- fish.id
hide.filter(hide2, 10, 2.5)
hide2 <- fish.id
hide.filter(hide3, 10, 2.5)
hide3 <- fish.id
hide.filter(hide4, 10, 2.5)
hide4 <- fish.id

library(dplyr)

for(i in 1:4){
  
  all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, get(paste0('hide', as.character(i)))[,'HideTime']))))
  
  all <- all %>%
    left_join(dayfile_tbl, by = c("ts" = "EchoTime")) %>%
    left_join(get(paste0('hide', as.character(i))), by = c("ts" = "HideTime")) %>%
    arrange(ts) %>%
    fill(PosX.y, PosY.y, PosZ.y) %>%
    filter(!is.na(PosX.x)) %>%
    arrange(Period.x, ts) 
  
  dayfile_tbl[,paste0("HID", as.character(i), ".x")] <- all$PosX.y
  dayfile_tbl[,paste0("HID", as.character(i), ".y")] <- all$PosY.y
  dayfile_tbl[,paste0("HID", as.character(i), ".z")] <- all$PosZ.y
}

rm(all)
rm(fish.id)

names(dayfile_tbl)[names(dayfile_tbl) == c('HID1.x', 'HID1.y', 'HID1.z', 'HID2.x', 'HID2.y', 'HID2.z', 'HID3.x', 'HID3.y', 'HID3.z', 'HID4.x', 'HID4.y', 'HID4.z')] <- c('P7NW.x', 'P7NW.y', 'P7NW.z', 'P7SE.x', 'P7SE.y', 'P7SE.z', 'P8SW.x', 'P8SW.y', 'P8SW.z', 'P8NE.x', 'P8NE.y', 'P8NE.z')
hides <- rbind(hide1, hide2, hide3, hide4)
names(hides)[names(hides) == 'HideTime'] <- 'EchoTime'
hides$SEC <- NULL
hides$M <- NULL
hides$MSEC <- NULL
hides$BL <- NULL
hides$BLSEC <- NULL


#ENTER CODES FROM MASTERCODE
dayfile_tbl$BIOF7 <- as.factor(mastercode[day,'BIOF7'])         
dayfile_tbl$BIOF8 <- as.factor(mastercode[day,'BIOF8'])  
dayfile_tbl$ARTL <- as.factor(mastercode[day,'ARTL'])  
dayfile_tbl$INFD <- as.factor(mastercode[day,'INFD'])  
dayfile_tbl$CHEM <- as.factor(mastercode[day,'CHEM'])  
dayfile_tbl$WVIS <- as.factor(mastercode[day,'WVIS'])                          
dayfile_tbl$MOON <- as.factor(mastercode[day,'MOON']) 

#Enter species code
fishid.origin.lookup <- fishid_tbl$Origin # create fish origin lookup table
names(fishid.origin.lookup) <- fishid_tbl$Period
dayfile_tbl$SPEC <- as.factor(fishid.origin.lookup[as.character(dayfile_tbl$Period)]) # add fish origins to day file

#LICE DATA
dayfile_tbl$TOT_P7 <- as.numeric(mastercode[day,'LICE_P7_TOT']) 
dayfile_tbl$PA_A_P7 <- as.numeric(mastercode[day,'LICE_P7_FGPAA']) 
dayfile_tbl$FG_P7 <- as.numeric(mastercode[day,'LICE_P7_FG']) 
dayfile_tbl$A_P7 <- as.numeric(mastercode[day,'LICE_P7_A']) 
dayfile_tbl$PA_P7 <- as.numeric(mastercode[day,'LICE_P7_PA']) 
dayfile_tbl$CHAL_P7 <- as.numeric(mastercode[day,'LICE_P7_CHAL']) 
dayfile_tbl$CAL_P7 <- as.numeric(mastercode[day,'LICE_P7_CAL']) 
dayfile_tbl$TOT_P8 <- as.numeric(mastercode[day,'LICE_P8_TOT']) 
dayfile_tbl$PA_A_P8 <- as.numeric(mastercode[day,'LICE_P8_FGPAA']) 
dayfile_tbl$FG_P8 <- as.numeric(mastercode[day,'LICE_P8_FG']) 
dayfile_tbl$A_P8 <- as.numeric(mastercode[day,'LICE_P8_A']) 
dayfile_tbl$PA_P8 <- as.numeric(mastercode[day,'LICE_P8_PA']) 
dayfile_tbl$CHAL_P8 <- as.numeric(mastercode[day,'LICE_P8_CHAL']) 
dayfile_tbl$CAL_P8 <- as.numeric(mastercode[day,'LICE_P8_CAL']) 

#LOCATIONS CODING
dayfile_tbl$BOT <- as.factor(ifelse(dayfile_tbl$PosZ >= bottom.threshold, 'B', 'Z')) # at cage bottom
dayfile_tbl$OUT <- as.factor(locationcode(n7code = '7ON', w7code = '7OW', s7code = '7OS', e7code = '7OE', n8code = '8ON', w8code = '8OW', s8code = '8OS', e8code = '8OE')) # fish outside cage
dayfile_tbl$EDG <- as.factor(locationcode(n7code = '7EN', w7code = '7EW', s7code = '7ES', e7code = '7EE', n8code = '8EN', w8code = '8EW', s8code = '8ES', e8code = '8EE')) # fish at edge of cage
dayfile_tbl$BIGC <- as.factor(locationcode(n7code = '7CNW', w7code = '7CSW', s7code = '7CSE', e7code = '7CNE', n8code = '8CNW', w8code = '8CSW', s8code = '8CSE', e8code = '8CNE')) # fish in big corners
dayfile_tbl$SMC <- as.factor(locationcode(n7code = '7XNW', w7code = '7XSW', s7code = '7XSE', e7code = '7XNE', n8code = '8XNW', w8code = '8XSW', s8code = '8XSE', e8code = '8XNE')) # fish in small corners
#dayfile_tbl$HID <- as.factor(hidecode(p7h1code = '7WHSE', p7h2code = '7WHNW', p8h1code = '8WHSW', p8h2code = '8WHNE')) # fish in hides
dayfile_tbl$HID <- as.factor(dynamic.hidecode(p7nwhide = '7WHNW', p7sehide = '7WHSE', p8swhide = '8WHSW', p8nehide = '8WHNE', radius = 1, depth = 2, height = 1)) # fish in hides
dayfile_tbl$CEN <- as.factor(centrecode(highcode7 = '7MH', midcode7 = '7MM', lowcode7 = '7ML', highcode8 = '8MH', midcode8 = '8MM', lowcode8 = '8ML')) # fish in centre of cage


#SUN AND TIDES CODING
dayfile_tbl$SUN <- suncode() # sun phase code
dayfile_tbl$TID <- tidecode() # tide phase code


#MEAL TIMES CODING
dayfile_tbl$SMEAL7 <- smealcode(pen = 'P7') # salmon feeding times cage 7 code
dayfile_tbl$SMEAL8 <- smealcode(pen = 'P8') # salmon feeding times cage 8 code


if(is.na(mastercode[day, 'AG7F1_N_S'])) {dayfile_tbl$AG7F1 <- 'NA'} else {dayfile_tbl$AG7F1 <- jellycode(feed.block = '7F1')}   # cleanerfish jelly feeding time cage 7 F1 code
if(is.na(mastercode[day, 'AG7F2_N_S'])) {dayfile_tbl$AG7F2 <- 'NA'} else {dayfile_tbl$AG7F2 <- jellycode(feed.block = '7F2')}   # cleanerfish jelly feeding time cage 7 F2 code
if(is.na(mastercode[day, 'AG8F1_N_S'])) {dayfile_tbl$AG8F1 <- 'NA'} else {dayfile_tbl$AG8F1 <- jellycode(feed.block = '8F1')}   # cleanerfish jelly feeding time cage 8 F1 code
if(is.na(mastercode[day, 'AG8F2_N_S'])) {dayfile_tbl$AG8F2 <- 'NA'} else {dayfile_tbl$AG8F2 <- jellycode(feed.block = '8F2')}   # cleanerfish jelly feeding time cage 8 F2 code


if(is.na(mastercode[day, 'LUMPEL_S'])) {dayfile_tbl$LUMPEL <- 'NA'} else {dayfile_tbl$LUMPEL <- lumpelcode()} # Lumpfish feeding time code

#ENVIRONMENTAL DATA


all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.DOT1$DO.time.1m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT1, by=c("ts" = "DO.time.1m")) %>%
  arrange(ts) %>%
  fill(DO.1m) %>%
  fill(Temp.1m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$O1 <- all$DO.1m
dayfile_tbl$T1 <- all$Temp.1m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.sal1$Sal.time.1m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal1, by=c("ts" = "Sal.time.1m")) %>%
  arrange(ts) %>%
  fill(Sal.1m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$S1 <- all$Sal.1m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.DOT2$DO.time.2m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT2, by=c("ts" = "DO.time.2m")) %>%
  arrange(ts) %>%
  fill(DO.2m) %>%
  fill(Temp.2m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$O2 <- all$DO.2m
dayfile_tbl$T2 <- all$Temp.2m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.sal2$Sal.time.2m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal2, by=c("ts" = "Sal.time.2m")) %>%
  arrange(ts) %>%
  fill(Sal.2m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$S2 <- all$Sal.2m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.DOT4$DO.time.4m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT4, by=c("ts" = "DO.time.4m")) %>%
  arrange(ts) %>%
  fill(DO.4m) %>%
  fill(Temp.4m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$O4 <- all$DO.4m
dayfile_tbl$T4 <- all$Temp.4m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.sal4$Sal.time.4m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal4, by=c("ts" = "Sal.time.4m")) %>%
  arrange(ts) %>%
  fill(Sal.4m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$S4 <- all$Sal.4m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.DOT12$DO.time.12m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.DOT12, by=c("ts" = "DO.time.12m")) %>%
  arrange(ts) %>%
  fill(DO.12m) %>%
  fill(Temp.12m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$O12 <- all$DO.12m
dayfile_tbl$T12 <- all$Temp.12m

all <- data.frame(ts = unique(unlist(c(dayfile_tbl$EchoTime, probe.sal12$Sal.time.12m))))

all <- all %>%
  left_join(dayfile_tbl, by=c("ts"="EchoTime")) %>%
  left_join(probe.sal12, by=c("ts" = "Sal.time.12m")) %>%
  arrange(ts) %>%
  fill(Sal.12m) %>%
  filter(!is.na(PosX)) %>%
  arrange(Period, ts) 

dayfile_tbl$S12 <- all$Sal.12m

rm(all)

#dayfile_tbl <- dayfile_tbl[c(seq(1, 12), seq(25, 74), seq(13, 24))]

dayfile_tbl$P7NW.x <- NULL
dayfile_tbl$P7NW.y <- NULL
dayfile_tbl$P7NW.z <- NULL
dayfile_tbl$P7SE.x <- NULL
dayfile_tbl$P7SE.y <- NULL
dayfile_tbl$P7SE.z <- NULL
dayfile_tbl$P8SW.x <- NULL
dayfile_tbl$P8SW.y <- NULL
dayfile_tbl$P8SW.z <- NULL
dayfile_tbl$P8NE.x <- NULL
dayfile_tbl$P8NE.y <- NULL
dayfile_tbl$P8NE.z <- NULL

#FINISH CODE
write.csv(dayfile_tbl, file = sub(".csv", "_coded.csv", dayfile, ignore.case = FALSE, fixed = T)) #write output to file
write.csv(hides, file = sub(".csv", "_hides.csv", dayfile, ignore.case = FALSE, fixed = T)) #write output to file


#remove(dayfile_tbl)
#remove(mastercode)
#remove(fishid_tbl)
#remove(locations.lookup)



# Code to add fish at feed blocks retrospectively ---------------------------------------------------------------------------------------


system.time({
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  
  for(i in 1:length(files)){
    
    day <- substr(files[[i]], 15, 17)
    dayfile_tbl <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)  
    
    dayfile_tbl$FDB <- as.factor(atfeedcode(p7fb1code = '7FBSE', p7fb2code = '7FBNW', p8fb1code = '8FBSW', p8fb2code = '8FBNE')) # fish at feed blocks
    
    
    #dayfile_tbl <- dayfile_tbl[,c(seq(1, 41), 63, seq(42, 62))]
    
    write.csv(dayfile_tbl, file = files[[i]]) #write output to file
    
  }
  
  
})




# Code to add fish heading to loaded dayfile retrospectively ------------------------

dayfile <- dayfile[order(dayfile$EchoTime, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by time
dayfile <- dayfile[order(dayfile$Period, na.last = FALSE, decreasing = FALSE, method = c("shell")),] # sort by tag


system.time({
  
    heading.func()
    dayfile$HEAD <- c(NA, heading)
    rm(heading)
    
    dayfile <- dayfile[,c(seq(1, 12), 64, seq(13, 63))]
    
  
})




# Retrospectively add new column of water temperature at the fish's depth

fdtemp <- function(x, t1, t2, t4, t12){ 
  
  if(is.na(t1) == T){
    
    tatd <- NA
    
  } else {
  
  tprofile <- data.frame(depth = seq(0, 35, 0.01)) %>%
    left_join(data.frame(depth = c(0, 1, 2, 4, 12, 35), temp = c(t1, t1, t2, t4, t12, t12)), by = 'depth') %>%
    mutate(temp = approx(depth, temp, depth)$y)
  
  rownames(tprofile) <- tprofile$depth
  #tprofile$depth <- NULL
  
  tatd <- as.numeric(tprofile[as.character(x),2])
  
  }
  
  return(tatd)
}


files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)

system.time({
  
  for(i in 1:length(files)){
    
    #day <- substr(files[[i]], 15, 17)
    #dayfile <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = dayfile.classes)  
    
    dayfile <- fread(files[[i]], drop = c(1))
    dayfile$EchoTime <- as.POSIXct(dayfile$EchoTime)
    
    dayfile$FISHTEMP <- round(mapply(fdtemp, x = dayfile$PosZ, t1 = dayfile$T1, t2 = dayfile$T2, t4 = dayfile$T4, t12 = dayfile$T12, SIMPLIFY = T), 2)
    
    write.csv(dayfile, files[[i]]) #write output to file
    
  }
  
  
})





#----------------------------------------------------------------------------------------------------------------------------------------

# FUNCTIONS

convert.to.date <- function(column = col) {
  as.POSIXct(strptime(paste(mastercode$DATE, substr(column, 12, 19), sep = " "), "%Y-%m-%d %H:%M:%S", tz = "UTC"))
}

# function to code for sun phase
suncode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_N_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_N_E']), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_W_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_W_E']), 'W', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_D_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_D_E']), 'D', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_K_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_K_E']), 'K', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'SUN_N_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'SUN_N_E2']), 'N', ' '
         )))))
}

# function to code for tide phase
tidecode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_L_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_L_E']), 'L', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_LH_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_LH_E']), 'LH', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_H_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_H_E']), 'H', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_HL_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_HL_E']), 'HL', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_L_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_L_E2']), 'L', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_LH_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_LH_E2']), 'LH', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_H_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_H_E2']), 'H', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'TID_HL_S2']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'TID_HL_E2']), 'HL', 'Z'
         ))))))))
}

# function to code for salmon feeding times
smealcode <- function(daycode = day, pennum = pen) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_E', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S2', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E2', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_S2', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_Y_E2', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_S3', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('SMEAL_', pennum, '_N_E3', sep = "")]), 'N', 'Z'
         )))))
}

# function to code for wrasse jelly feed times
jellycode <- function(daycode = day, fb = feed.block) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_N_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_N_E', sep = "")]), 'N', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_Y_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_Y_E', sep = "")]), 'Y', ifelse
         (as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode, paste('AG', fb, '_M_S', sep = "")]) &
           as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode, paste('AG', fb, '_M_E', sep = "")]), 'M', 'Z'
         )))
}

# function to code for lumpfish feeding times
lumpelcode <- function(daycode = day) {
  ifelse(as.numeric(dayfile_tbl$EchoTime) > as.numeric(mastercode[daycode,'LUMPEL_S']) & as.numeric(dayfile_tbl$EchoTime) < as.numeric(mastercode[daycode,'LUMPEL_E']), 'Y', 'N')
}

# function to code for fish location
locationcode <- function(n7code, w7code, s7code, e7code, n8code, w8code, s8code, e8code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[n7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[n7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[n7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[n7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[n7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[n7code, 'zmax'], n7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[w7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[w7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[w7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[w7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[w7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[w7code, 'zmax'], w7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[s7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[s7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[s7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[s7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[s7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[s7code, 'zmax'], s7code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[e7code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[e7code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[e7code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[e7code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[e7code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[e7code, 'zmax'], e7code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[n8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[n8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[n8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[n8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[n8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[n8code, 'zmax'], n8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[w8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[w8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[w8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[w8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[w8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[w8code, 'zmax'], w8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[s8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[s8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[s8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[s8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[s8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[s8code, 'zmax'], s8code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[e8code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[e8code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[e8code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[e8code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[e8code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[e8code, 'zmax'], e8code, '' 
         ))))))))
}

# function to code for fish in hide
hidecode <- function(p7h1code, p7h2code, p8h1code, p8h2code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7h1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7h1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7h1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p7h1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7h1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7h1code, 'zmax'], p7h1code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7h2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7h2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7h2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p7h2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7h2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7h2code, 'zmax'], p7h2code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8h1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8h1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8h1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8h1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8h1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8h1code, 'zmax'], p8h1code, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8h2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8h2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8h2code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p8h2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8h2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8h2code, 'zmax'], p8h2code, ''
         
         ))))
}



# function to code for fish in hide
dynamic.hidecode <- function(p7nwhide, p7sehide, p8swhide, p8nehide, radius, depth, height) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > (dayfile_tbl$P7NW.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P7NW.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P7NW.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P7NW.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P7NW.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P7NW.z + depth), p7nwhide, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > (dayfile_tbl$P7SE.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P7SE.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P7SE.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P7SE.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P7SE.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P7SE.z + depth), p7sehide, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > (dayfile_tbl$P8SW.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P8SW.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P8SW.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P8SW.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P8SW.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P8SW.z + depth), p8swhide, ifelse
         (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > (dayfile_tbl$P8NE.x - radius) & dayfile_tbl$PosX < (dayfile_tbl$P8NE.x + radius) & dayfile_tbl$PosY > (dayfile_tbl$P8NE.y - radius) & 
           dayfile_tbl$PosY < (dayfile_tbl$P8NE.y + radius) & dayfile_tbl$PosZ > (dayfile_tbl$P8NE.z - height) & dayfile_tbl$PosZ < (dayfile_tbl$P8NE.z + depth), p8nehide, ''
         
         ))))
}



# function to code for fish at feed blocks
atfeedcode <- function(p7fb1code, p7fb2code, p8fb1code, p8fb2code) {
  ifelse(dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7fb1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7fb1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7fb1code, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[p7fb1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7fb1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7fb1code, 'zmax'], p8fb1code, ifelse
         (dayfile_tbl$PEN == 7 & dayfile_tbl$PosX > locations.lookup[p7fb2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p7fb2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p7fb2code, 'ymin'] & 
             dayfile_tbl$PosY < locations.lookup[p7fb2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p7fb2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p7fb2code, 'zmax'], p7fb2code, ifelse
           (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8fb1code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb1code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb1code, 'ymin'] & 
               dayfile_tbl$PosY < locations.lookup[p8fb1code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb1code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb1code, 'zmax'], p8fb1code, ifelse
             (dayfile_tbl$PEN == 8 & dayfile_tbl$PosX > locations.lookup[p8fb2code, 'xmin'] & dayfile_tbl$PosX < locations.lookup[p8fb2code, 'xmax'] & dayfile_tbl$PosY > locations.lookup[p8fb2code, 'ymin'] & 
                 dayfile_tbl$PosY < locations.lookup[p8fb2code, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[p8fb2code, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[p8fb2code, 'zmax'], p8fb2code, ''
               
             ))))
}


# function to code for fish at centre of cage
centrecode <- function(highcode7, midcode7, lowcode7, highcode8, midcode8, lowcode8) {
  ifelse(dayfile_tbl$PosX > locations.lookup[highcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[highcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[highcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[highcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[highcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[highcode7, 'zmax'], highcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[midcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[midcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[midcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[midcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[midcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[midcode7, 'zmax'], midcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[lowcode7, 'xmin'] & dayfile_tbl$PosX < locations.lookup[lowcode7, 'xmax'] & dayfile_tbl$PosY > locations.lookup[lowcode7, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[lowcode7, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[lowcode7, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[lowcode7, 'zmax'], lowcode7, ifelse
         (dayfile_tbl$PosX > locations.lookup[highcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[highcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[highcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[highcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[highcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[highcode8, 'zmax'], highcode8, ifelse
         (dayfile_tbl$PosX > locations.lookup[midcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[midcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[midcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[midcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[midcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[midcode8, 'zmax'], midcode8, ifelse
         (dayfile_tbl$PosX > locations.lookup[lowcode8, 'xmin'] & dayfile_tbl$PosX < locations.lookup[lowcode8, 'xmax'] & dayfile_tbl$PosY > locations.lookup[lowcode8, 'ymin'] & 
           dayfile_tbl$PosY < locations.lookup[lowcode8, 'ymax'] & dayfile_tbl$PosZ > locations.lookup[lowcode8, 'zmin'] & dayfile_tbl$PosZ < locations.lookup[lowcode8, 'zmax'], lowcode8, ''
         ))))))
}


hide.filter <- function(hide, smooth = 10, thresh = 2.5){
  
  fish.id <- hide
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
  
  fish.id$PosX.ma <- NULL
  fish.id$PosY.ma <- NULL
  fish.id$PosZ.ma <- NULL
  
  fish.id <<- fish.id
  
}




# function to calculate fish headings from positions (outputs vector of fish headings)

heading.func <- function(){
  
  diffx <- diff(dayfile$PosX)
  diffy <- diff(dayfile$PosY)
  heading <- numeric()
  
  for (i in 1:length(diffx)){
    
    
    if(diffx[[i]] > 0.02 & diffy[[i]] > 0.02) {
      
      heading <- c(heading, round((atan(diffy[[i]]/diffx[[i]]))*180/pi, 2))
      
    } else {
      
      if(diffx[[i]] > 0.02 & diffy[[i]] < -0.02) {
        
        heading <- c(heading, round(90+((atan((diffy[[i]]*-1)/diffx[[i]]))*180/pi), 2)) 
        
      } else {
        
        if(diffx[[i]] < -0.02 & diffy[[i]] < -0.02) {
          
          heading <- c(heading, round(270-((atan((diffy[[i]]*-1)/(diffx[[i]]*-1)))*180/pi), 2))
          
        } else {
          
          if(diffx[[i]] < -0.02 & diffy[[i]] > 0.02){
            
            heading <- c(heading, round(270+((atan(diffy[[i]]/(diffx[[i]]*-1)))*180/pi), 2)) 
            
          } else {
            
            if(diffx[[i]] == 0 & diffy[[i]] > 0.02) {
              
              heading <- c(heading, 0)
              
            } else {
              
              if(diffx[[i]] > 0.02 & diffy[[i]] == 0) {
                
                heading <- c(heading, 90)
                
              } else {
                
                if(diffx[[i]] == 0 & diffy[[i]] < -0.02) {
                  
                  heading <- c(heading, 180)
                  
                } else {
                  
                  if(diffx[[i]] < -0.02 & diffy[[i]] == 0) {
                    
                    heading <- c(heading, 270)
                    
                  } else {
                    
                    heading <- c(heading, NA)
                    
                  }
                  
                }
                
                
              }
              
              
            }
            
          }
          
        }
        
      }
      
    }
    
  }
  
  heading <<- heading
  
}







