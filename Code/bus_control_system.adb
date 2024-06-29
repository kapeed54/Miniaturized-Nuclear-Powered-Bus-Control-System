pragma SPARK_Mode;

with DA_IO_Wrapper;  use DA_IO_Wrapper; 

package body bus_control_system is

   procedure reactorActive is
   begin
      bus.bussystem.status := Activated;
      DA_Put_Line("Status of Reactor:" & bus.bussystem.status'Image);
   end reactorActive;
   
   procedure reactorDeactivate is
   begin
      if (bus.bussystem.status = Activated and then bus.speed = 0) then
         bus.bussystem.status := Deactivated;
        DA_Put_Line("Status of Reactor:" & bus.bussystem.status'Image);
      end if;
   end reactorDeactivate;
   
   procedure insertCrods is
   begin
      if (bus.bussystem.crods < R_CRods'Last) then
         bus.bussystem.crods:= bus.bussystem.crods + 1;
         DA_Put_Line("Control Rod has been added to the reactor . Available Control Rods :"& bus.bussystem.crods'Image);
      end if;
   end insertCrods;
   
   procedure removeCrods is
   begin
      if (bus.bussystem.crods > R_CRods'First) then
         bus.bussystem.crods:= bus.bussystem.crods - 1;
         DA_Put_Line("Control Rod has been removed from the reactor. Available Control Rods :"& bus.bussystem.crods'Image);
      end if;
   end removeCrods;
   
   procedure startReactor is
   begin 
      if (bus.bussystem.temperature < R_Temp'Last - 5 and then
         bus.bussystem.radioactivity < R_Activity'Last) then
         bus.bussystem.radioactivity := bus.bussystem.radioactivity + 1;
         if (bus.bussystem.crods = 5) then
            bus.power := R_Power'Last;
            bus.bussystem.temperature := bus.bussystem.temperature + 5;
         elsif (bus.bussystem.crods = 4) then
            bus.power := (R_Power'Last * 80/100);
            bus.bussystem.temperature := bus.bussystem.temperature + 4;
         elsif (bus.bussystem.crods = 3) then
            bus.power := (R_Power'Last * 60/100);
            bus.bussystem.temperature := bus.bussystem.temperature + 3;
         elsif (bus.bussystem.crods = 2) then
            bus.power := (R_Power'Last * 40/100);
            bus.bussystem.temperature := bus.bussystem.temperature + 2;
         elsif (bus.bussystem.crods = 1) then
            bus.power := (R_Power'Last * 20/100);
            bus.bussystem.temperature := bus.bussystem.temperature + 1;
         end if;
      end if;
   end startReactor;
   
   procedure startBus is 
   begin
      if (Invariant and then bus.bussystem.status = Activated) then
         bus.speed := 1;
      end if;
   end startBus;
   
            
   procedure setSpeedlimit is
   begin
      bus.speedlimit := Integer(bus.power);
      if (bus.speedlimit <= 0) then
         stopBus;
      end if;
   end setSpeedlimit;
   
   procedure increaseBusspeed is
      begin
      if (bus.speed < maximum_speed 
          and then bus.speed < bus.speedlimit 
          and then bus.bussystem.status = Activated) then
         bus.speed := bus.speed + 1;
      else
         DA_Put_Line("Bus has reached its maximum speed limit");
      end if;
   end increaseBusspeed;

   
   procedure isOverheated is
      begin
      if (bus.bussystem.temperature >= maximumtemperature) then
         bus.bussystem.heat := high;
         DA_Put_Line("Reactor system is overheating, supply water. Heat Status: "&bus.bussystem.heat'Image);
      end if;
   end isOverheated;
   
   procedure supplyWater is
      begin
      if (bus.bussystem.water > R_Water'First + 1 and then
          bus.bussystem.temperature >= maximumtemperature) then
         bus.bussystem.water := bus.bussystem.water - 5;
         bus.bussystem.temperature := bus.bussystem.temperature - 50;
        DA_Put_Line("Supplying water to the reactor.");
         DA_Put_Line("Remaining Water Amount: "&bus.bussystem.water'Image);
      elsif (bus.bussystem.water = 0 and then bus.bussystem.temperature >= maximumtemperature) then
         stopBus;
         DA_Put_Line(" WARNING !!! ");
         DA_Put_Line("There is no water supply available. System is overheating.");
         DA_Put_Line("Stopping the bus");
      end if;

   end supplyWater;
   
   procedure stopBus is
   begin
      bus.speed := 0;
      bus.speedlimit :=0;
      bus.power := 0;
      bus.bussystem.temperature:= R_Temp'First;
      DA_Put_Line("Bus Stopped");
   end stopBus;
   

   procedure waterRefill is
      begin
      if (bus.speed = 0) then
         bus.bussystem.water := R_Water'Last;
         DA_Put_Line("Water System is Refilled: "&bus.bussystem.water'Image);
      end if;
   end waterRefill;
   
   procedure radioWaste is
   begin
      if (bus.bussystem.radioactivity = R_Activity'Last and then bus.speed>=0) then
         DA_Put_Line("Radio Active waste reached maximum amount");
         DA_Put_Line("Bus is STOPPING");
         DA_Put_Line("Remove waste to continue journey");
         stopBus;
      end if;
   end radioWaste;
   
   procedure removeRadiowaste is
   begin
      if (bus.speed = 0) then
         bus.bussystem.radioactivity := R_Activity'First;
         DA_Put_Line("Radio Active waste has been removed :" & bus.bussystem.radioactivity'Image);
      end if;
   end removeradiowaste;
   
   
end bus_control_system;
