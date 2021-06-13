# customer-restriction

This is a VHDL project written in Quartus Prime Lite and ModelSim Altera.
It is implemented in a Altera Cyclone IV EP4CE622C8 FPGA Board.

Its purpose is to count the number of people inside a store. 
Every time a customer leaves or enters the amount of customers decreases or increases accordingly. 
The store has a limit of customers specified in file CustomerRestrictions.vhd. 
As long as the number of customers are lower than the limit a led is turned on (green led).
When the limit is met the first led turns off and another led is turned on (red led) to signify that no more customers can enter the premises. 
Two seven segment displays display the number of people allowed to enter. 
This number is calculated by subtracting the limit from the amount of customers already inside.

Since this project is implemented in the specified FPGA Board and no sensors can be used, buttons 1 and 2 of the FPGA Board are used as sensors.
Button's 1 high signifies a customer entering and button's 2 high signifies one leaving.
Reset button resets the amount of customers inside to 0.
