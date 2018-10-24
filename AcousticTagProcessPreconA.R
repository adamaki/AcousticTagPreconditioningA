# Delousing efficiency project data processing
# Adam Brooker
# 31st August 2016

# LIST OF FUNCTIONS-------------------------------------------------------------------------------------------------------------------------

# hour.combine(filename) = combines 24 hour files into 1 day file. (filename) is the name of the midnight hour file for the day to be combined.
# fish.extract(fish.id, start.day, no.days) = extract individual fish from coded dayfiles and combine into a single file of a specified number of days.
# batch.fish.extract(start.day, no.days) = extract all individual fish from day files into seperate files for a specific time period
# batch.fish.extract.recoded(start.day, no.days) = extract all individual fish from recoded day files into seperate files for a specific time period





# ENTER YOUR VARIABLES HERE-----------------------------------------------------------------------------------------------------------------

workingdir = "H:/Data processing/2016 Conditioning study A/Filtered Data/Recoded Day CSV" # change to location of data
#file.name = "run2_LLF16S1001990000POS.csv" # change to name of midnight hour file for day to be combined
setwd(workingdir)





# FUNCTIONS--------------------------------------------------------------------------------------------------------------------------------

# combine 24 hour files into one day file

hour.combine <- function(file.name) # combine 24 hour files into 1 day file
{
  hour <- as.numeric(substring(file.name, 19, 19))
  file1 <- read.csv(file.name, header = TRUE, sep = ",", colClasses = c('character', 'character', 'character', 'character', 'character', 'character', 
                                                                         'character', 'character', 'character', 'character', 'character', 'character', 
                                                                         'character', 'character', 'character', 'character', 'character', 'character', 
                                                                         'character')) #read data into table
  hour <- hour+1
  for (hour in 1:9){
    substr(file.name, 19, 19) <- as.character(hour)
    file2 <- read.csv(file.name, header = TRUE, sep = ",", colClasses = c('character', 'character', 'character', 'character', 'character', 'character', 
                                                                                          'character', 'character', 'character', 'character', 'character', 'character', 
                                                                                          'character', 'character', 'character', 'character', 'character', 'character', 
                                                                                          'character')) #read data into table
    file1 <- rbind(file1, file2)
  }
  
  for (hour in 10:23){
    substr(file.name, 18, 19) <- as.character(hour)
    file2 <- read.csv(file.name, header = TRUE, sep = ",", colClasses = c('character', 'character', 'character', 'character', 'character', 'character', 
                                                                          'character', 'character', 'character', 'character', 'character', 'character', 
                                                                          'character', 'character', 'character', 'character', 'character', 'character', 
                                                                          'character')) #read data into table
    file1 <- rbind(file1, file2)
  }
  
  write.csv(file1, file = sub("2300POS.csv", "_day.csv", file.name, ignore.case = FALSE, fixed = T)) #write output to file
}



# extracts single fish id and combines multiple days into one file for a specified time period

fish.extract <- function(fish.id, start.day, no.days)
{
  
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  day1 <- grep(paste0('^..............', start.day, '_day_coded.csv'), files)
  end.day <- day1+(no.days-1)
  dayfile.loc <- files[[grep(paste0('^..............', start.day, '_day_coded.csv'), files)]]
  
  dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'integer', 'integer', 'POSIXct', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double' 
  )) #read data into table
  
  
  
  dayfile <- dayfile[which(dayfile$Period == fish.id), ]
  
  for (i in (day1+1):(end.day-1)) {
    dayfile2 <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'integer', 'integer', 'POSIXct', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double' 
    )) #read data into table
    dayfile2 <- dayfile2[which(dayfile2$Period == fish.id), ]
    dayfile <- rbind(dayfile, dayfile2) 
  } 
  
  write.csv(dayfile, file = sub(paste0(start.day, '_day_coded.csv'), paste0(fish.id, '_fish_coded.csv'), dayfile.loc, ignore.case = FALSE, fixed = T)) #write output to file  
  
}



# extract all individual fish from day files into seperate files for a specific time period

batch.fish.extract <- function(start.day, no.days) {

  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  day1 <- grep(paste0('^..............', start.day, '_day_coded.csv'), files)
  end.day <- day1+(no.days-1)
  dayfile.loc <- files[[grep(paste0('^..............', start.day, '_day_coded.csv'), files)]]
  
  #dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'integer', 'integer', 'POSIXct', 'double', 'double', 
  #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'character',
  #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character',
  #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double',
  #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double',
  #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character', 
  #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character', 
  #                                                                          'character', 'character', 'double', 'double', 'double', 'double', 'double', 
  #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double' 
  #)) #read data into table
  
  dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'character', 'character', 'POSIXct', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double' 
  )) #read data into table
                        
  fish.ids <- unique(dayfile$Period)
  
  for (i in 1:length(fish.ids)){
    assign(paste0('fish.id_', as.character(fish.ids[[i]])), dayfile[which(dayfile$Period == fish.ids[[i]]), ])
  }
  
  
  for (i in (day1+1):(end.day)) {
    #dayfile2 <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'integer', 'integer', 'POSIXct', 'double', 'double', 
    #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'character',
    #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character',
    #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double',
    #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double',
    #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character', 
    #                                                                          'character', 'character', 'character', 'character', 'character', 'character', 'character', 
    #                                                                          'character', 'character', 'double', 'double', 'double', 'double', 'double', 
    #                                                                          'double', 'double', 'double', 'double', 'double', 'double', 'double' 
    #)) #read data into table
    
    dayfile2 <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'character', 'character', 'POSIXct', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double' 
    )) #read data into table
                           
    for (i in 1:length(fish.ids)){
      
    assign(paste0(as.character(fish.ids[[i]]), '_2'), dayfile2[which(dayfile2$Period == fish.ids[[i]]), ])
    assign(paste0('fish.id_', as.character(fish.ids[[i]])),  rbind(get(paste0('fish.id_', as.character(fish.ids[[i]]))), get(paste0(as.character(fish.ids[[i]]), '_2'))))
    
    }
    
    
  } 
  
  for (i in 1:length(fish.ids)){
    write.csv(get(paste0('fish.id_', as.character(fish.ids[[i]]))), file = sub(paste0(start.day, '_day_coded.csv'), paste0(fish.ids[[i]], '_fish_coded.csv'), dayfile.loc, ignore.case = FALSE, fixed = T))
  }
  
  remove(list = ls(pattern = 'fish.id_'))
  remove(list = ls(pattern = '_2'))

}


# extract all individual fish from day files into seperate files for a specific time period

batch.fish.extract.recoded <- function(start.day, no.days) {
  
  files <- list.files(path = workingdir, pattern = '*.csv', all.files = FALSE, recursive = FALSE)
  day1 <- grep(paste0('^..............', start.day, '_day_recoded.csv'), files)
  end.day <- day1+(no.days-1)
  dayfile.loc <- files[[grep(paste0('^..............', start.day, '_day_recoded.csv'), files)]]
  
  dayfile <- read.csv(dayfile.loc, header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'character', 'character', 'POSIXct', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                            'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                            'double', 'double', 'double', 'double', 'double', 'double', 'double' 
  )) #read data into table
  
  #dayfile[,1] <- NULL
  
  fish.ids <- unique(dayfile$Period)
  
  for (i in 1:length(fish.ids)){
    assign(paste0('fish.id_', as.character(fish.ids[[i]])), dayfile[which(dayfile$Period == fish.ids[[i]]), ])
  }
  
  
  for (i in (day1+1):(end.day)) {
    dayfile2 <- read.csv(files[[i]], header = TRUE, sep = ",", colClasses = c('NULL', 'integer', 'character', 'character', 'POSIXct', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'character',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double',
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'character', 'character', 'character', 'character', 'character', 
                                                                              'character', 'character', 'double', 'double', 'double', 'double', 'double', 
                                                                              'double', 'double', 'double', 'double', 'double', 'double', 'double' 
    )) #read data into table
    #dayfile2[,1] <- NULL
    
    for (i in 1:length(fish.ids)){
      
      assign(paste0(as.character(fish.ids[[i]]), '_2'), dayfile2[which(dayfile2$Period == fish.ids[[i]]), ])
      assign(paste0('fish.id_', as.character(fish.ids[[i]])),  rbind(get(paste0('fish.id_', as.character(fish.ids[[i]]))), get(paste0(as.character(fish.ids[[i]]), '_2'))))
      
    }
    
    
  } 
  
  for (i in 1:length(fish.ids)){
    write.csv(get(paste0('fish.id_', as.character(fish.ids[[i]]))), file = sub(paste0(start.day, '_day_recoded.csv'), paste0(fish.ids[[i]], '_fish_recoded.csv'), dayfile.loc, ignore.case = FALSE, fixed = T))
  }
  
  remove(list = ls(pattern = 'fish.id_'))
  remove(list = ls(pattern = '_2'))
  
}
