one_five <- c(1, 2, 3, 4, 5) # creates a vector by concatonating the values
one_five # prints to console the vector
class(one_five) #tells us what data type it is

one_five_short <- 1:5 #creates a vector that is one to five inclusive
one_five_short # prints the vector to console

one_five <- c(1, 2, "three", 4, 5) #creates another vector

one_five #prints to console
class(one_five) #tells us the data type

# individual elements
class(2000) #numeric
class(NA) #logical
class("apple") #character

# vectors
results <- c(F, T, T, F)
class(results) #logical
class(c(19, 21, 25, 30)) #numeric
class(c('Hello', 'world')) #character

class(2000) == "numeric" # checks if the datatype is numeric and returns true of false

