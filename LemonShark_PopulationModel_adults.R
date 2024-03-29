
#This script runs a population model for lemon sharks in a nursery lagoon in Bimini, Bahamas. 
#This model is desribed in White et al 2014 "Modeling lemon shark population dynamics" https://biologydirect.biomedcentral.com/articles/10.1186/1745-6150-9-23
#Currently the script using a Poisson process to calculate litter sizes but this can be modified to use a litter size distribution from a genetic study (see below and paper)

#this code has not been optimized for speed

#Created by Easton R. White 
#Created: 17-Apr-2012
#Last edited: 14-Apr-2014
#First uploaded to GitHub on 14-Apr-2014

#Intial condition for Lemon shark population size
IC= c(30,30,10,15,15,5,5,3,3,3,3,3,2,2,2,2,2,2,1,1,1,1,2,2,2,2)

#set number of runs for model
no.runs= 1

#keep track of variance and mean of Juvenile population size over a series of runs with the model
J_var= matrix(0,nrow=1,ncol=no.runs)
J_mean= matrix(0,nrow=1,ncol=no.runs)


#Probablities for different litter sizes (see paper for details) based on genetic data
birthprob=c(0.02272727,0.14772727,0.113636,0.143939,0.0757575,0.1022727,0.06060606,0.0492424,0.09848484,0.0643939,0.04166666,0.034090909,0.02272727,0.00378787,0.0151515,0,0,0.0037878)


for (g in 1:(no.runs)){

	max.time = 50
	#set up matrix (Lemons) to track number of individuals in each age class over time and matrix (Stable_age) to track the age distribution through time
	Lemons = matrix(IC,nrow= 26,ncol=max.time)
	Stable_age =matrix(0,nrow=26,ncol=max.time)
	
	#initialize matrices
	Lemons[1:26,1] = IC
	Stable_age[1:26,1]=IC/sum(IC)
	
	#keep track of Juveniles, Subadults, and Adults
	J =  sum(Lemons[1:3,1])    #Juveniles and newborns in lagoon
	S =  sum(Lemons[4:12,1])   #subadults who have left the lagoon and cannot reproduce
	A =  sum(Lemons[13:26,1])  #adults who can reproduce
	
	#initialize parameters (these are described in the paper)
	b=6.087   #Number of offspring per female 8.3 from Feldheim 2002, 6.7 from 
	h=1   	  #hill coefficient
	k=100     #half saturation constant (Estimated from Gruber 2001)
	u=0.15    #adult mortality rate
	
	
		for (j in 2:(max.time)){
				Lemons[1,j]= sum(rpois(sum(Lemons[13:26,j-1])/4,b))  #use Poisson distribution to choose litter size
		 		#Lemons[1,j] =	sum(sample(1:18,sum(Lemons[13:26,j-1]/  4),replace=TRUE,prob=birthprob)) #use distribution of litter sizes estimated from genetic data
				Lemons[2,j] = Lemons[1,j-1] - rbinom (1, Lemons[1,j-1],(Lemons[1,j-1]^h)/(k+Lemons[1,j-1]^h))
				Lemons[3,j] = Lemons[2,j-1] - rbinom (1, Lemons[2,j-1],u)
				Lemons[4,j] = Lemons[3,j-1] - rbinom (1, Lemons[3,j-1], u)
					for (i in 5:25){
					    Lemons[i,j] = Lemons[i-1,j-1] - rbinom (1, Lemons[i-1,j-1], u)
					}
					Lemons[26,j] = Lemons[25,j-1] - rbinom (1, Lemons[25,j-1], 1)
		          J = c(J, sum(Lemons[1:3,j]))
			 	  S = c(S, sum(Lemons[4:12,j]))
			  	  A = c(A, sum(Lemons[13:26,j]))
		
		Stable_age[1:26,j]=(Lemons[1:26,j]/sum(Lemons[1:26,j]))*100

		}#end of time loop 


#call to randomly select 17 year chunks from each trial after accounting for 100 years of transition dynamics
Sequence=sample(100:(max.time), size=1, replace=TRUE) #15
J_var[g]= var(J[(Sequence-16):Sequence])   #15
J_mean[g]= mean(J[(Sequence-16):Sequence])


}#end of trial loop 

J_var = c(J_var)
J_mean= c(J_mean)

print("Juvenile_mean")
print(mean(J_mean))
print("Juvenile_variance")
print(mean(J_var))

plot(A[1:max.time],type="b", ylim=c(0, 50), ylab='Total adult population size (age 13-26)', xlab='Time (years)')
#points(J[1:max.time],type="b", col=g)

