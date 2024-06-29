pragma SPARK_Mode;

with SPARK.Text_IO; use SPARK.Text_IO;

package bus_control_system is
   
   maximum_speed :      constant :=100;
   maximumtemperature : constant :=200;

   type R_Status is (Activated, Deactivated);
   type R_Temp is range 0 .. 300;
   type R_Heat is (low, normal, high);
   type R_CRods is range 1 .. 5;
   type R_Power is range 0 .. 100;
   type R_Water is range 0 ..50;
   type R_Activity is range 0 ..250;
   
   type BusControlSystem is record
      status : R_Status;
      temperature : R_Temp;
      heat : R_Heat;
      crods : R_CRods;
      water : R_Water;
      radioactivity: R_Activity;
   end record;
   
   type ReactorOperation is record
      bussystem : BusControlSystem;
      power : R_Power;
      speed : Integer;
      speedlimit: Integer;
   end record;
   
   -- Global Variable Initialization
   
   control_system : BusControlSystem:=(status=> Activated, 
                              temperature=>R_Temp'First, 
                              heat=> normal,
                              crods=> R_CRods'Last,
                              water => R_Water'Last,
                              radioactivity => R_Activity'First);
   
   bus : ReactorOperation:=(bussystem=>control_system,
                            power => R_Power'First,
                            speed => 0,
                            speedlimit => 0);
   
   -- condition that is always true
   function Invariant return Boolean is
      (bus.bussystem.crods >= R_CRods'First);
      
   -- procedures for the system
   
   procedure reactorActive with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => Standard_Output, bus => (bus)),
     
     Pre => bus.bussystem.status = Deactivated,
     
     Post => bus.bussystem.status = Activated;
   
   procedure reactorDeactivate with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => bus.bussystem.status = Activated and then bus.speed = 0,
     
     Post => bus.bussystem.status = Deactivated;
   
   procedure insertCrods with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus),bus => (bus)),
                   
     Pre => Invariant and then bus.bussystem.crods < R_CRods'Last,
     
     Post => bus.bussystem.crods = bus.bussystem.crods'Old + 1;
   
   procedure removeCrods with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre =>  bus.bussystem.crods > R_CRods'Last,
     
     Post => bus.bussystem.crods = bus.bussystem.crods'Old - 1;
   
   procedure startReactor with
     
     Global => (In_Out => (bus)),
     Depends => (bus => (bus)),
     
     Pre => bus.bussystem.temperature < R_Temp'Last - 5
     and then bus.speed < maximum_speed
     and then bus.speed < bus.speedlimit
     and then bus.bussystem.status = Activated
     and then Invariant
     and then bus.bussystem.radioactivity < R_Activity'Last,
            
     Post => bus.bussystem.temperature > bus.bussystem.temperature'Old
     and then bus.power /= 0
     and then bus.bussystem.radioactivity = bus.bussystem.radioactivity'Old + 1;
   
   procedure startBus with
     
     Global => (In_Out => (bus)),
     Depends => (bus => (bus)),
     
     Pre =>bus.speed = 0
     and then Invariant
     and then bus.bussystem.status= Activated,
     
     Post =>bus.speed > 0;
   
   
      
   procedure setSpeedlimit with
     
     Global => (In_Out => (Standard_Output, bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => bus.speed >=0,
     
     Post => bus.speed >=0;
   
   
   procedure increaseBusspeed with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => Invariant
     and then bus.bussystem.status = Activated
     and then bus.speed < maximum_speed
     and then bus.speed < bus.speedlimit,
       
     Post => bus.speed = bus.speed'Old + 1;
   
   procedure isOverheated with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => Invariant
     and then bus.bussystem.temperature >= 200 
     and then bus.bussystem.status = Activated
     and then bus.bussystem.heat = normal,
       
     Post => bus.bussystem.heat = high;
   
   
   procedure supplyWater with
     
     Global => (In_Out => (Standard_Output, bus)),
     Depends => (Standard_Output => (Standard_Output,bus),bus => (bus)),
     
     Pre => Invariant 
     and then bus.speed > 0
     and then bus.bussystem.temperature >= maximumtemperature
     and then bus.bussystem.water >=5,
       
     Post => bus.bussystem.temperature = bus.bussystem.temperature'Old - 50
     and then bus.bussystem.water = bus.bussystem.water'Old -5;
   
   
   procedure stopBus with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => Standard_Output, bus => (bus)),
     
     Pre=> bus.speed >=0,
     
     Post => bus.speed = 0
     and then bus.power=0
     and then bus.bussystem.temperature = R_Temp'First
     and then bus.speedlimit = 0;
   
   procedure waterRefill with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => bus.speed = 0
     and then bus.bussystem.water < R_Water'Last,
       
     Post => bus.bussystem.water = R_Water'Last;
   
   procedure radioWaste with
     
     Global => (In_Out => (Standard_Output, bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => bus.bussystem.radioactivity = R_Activity'Last and then bus.speed>=0,
     
     Post => bus.speed = 0 
     and then bus.power = 0
     and then bus.bussystem.temperature = R_Temp'First
     and then bus.speedlimit = 0;
   
   procedure removeRadiowaste with
     
     Global => (In_Out => (Standard_Output,bus)),
     Depends => (Standard_Output => (Standard_Output,bus), bus => (bus)),
     
     Pre => bus.speed = 0,
     
     Post => bus.bussystem.radioactivity = R_Activity'First;
   

end bus_control_system;
