# WVD scaling scripts

### New_scale_allpeak.ps1 
This script scales RDHSs up and down durning all hours of the day. 

### Newscale_Peak_off_Peak.ps1
This script sets a minium number of RDHS to be on durning the peak hours and only scales up from there. Durning off peak hours the script will scale up and down based on number of users on the system. You must add the varable "PeakMinRDSH" to you logic app. This defines how many RDHS you want on durning peak hours.  
