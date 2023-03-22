Run startupVehicleHVAC.m to get started. It will build the HVAC library, 
if necessary, and open the model.

This model can be simulated in two modes: predefined system inputs or 
manual system inputs. Click "Predefined" and "Manual" in the model 
description to switch between the two modes. For predefined system inputs, 
the control settings for the HVAC system is specified in Signal Builder 
block. For manual system inputs, the control settings can be adjusted 
during runt ime using the dashboard controls on the model.

This example models moist air flow in a vehicle heating, ventilation, and 
air conditioning (HVAC) system in Simscape. The vehicle cabin is 
represented as a volume of moist air exchanging heat with the external 
environment. The moist air flows through a recirculation flap, a blower, 
an evaporator, a blend door, and a heater before returning to the cabin. 
The recirculation flap selects flow intake from the cabin or from the 
external environment. The blender door diverts flow around the heater to 
control the temperature.

The example HVAC component library is built on a custom moist air domain 
using the Simscape(TM) language. The across variables are pressure, 
dry-bulb temperature, and water vapor mass fraction. The through variables 
are mixture mass flow rate, energy flow rate, and water vapor mass flow 
rate. The moist air is assumed to be a perfect gas. Additional moisture 
may be added to a moist air volume. When a moist air volume reaches 
saturation, liquid water condenses and is removed from the volume.

Copyright 2017 The MathWorks, Inc.