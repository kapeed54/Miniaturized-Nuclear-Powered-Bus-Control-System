with bus_control_system; use bus_control_system;

with SPARK.Text_IO; use  SPARK.Text_IO;


procedure Main is

   user_input : String (1 .. 1);

   procedure bus_console is
   begin
      Put_Line ("__________________________________");
      Put_Line ("");
      Put_Line ("      C Y C L O P S  B U S        ");
      Put_Line ("");
      Put_Line ("   C O N T R O L   S Y S T E M    ");
      Put_Line ("__________________________________");

   end bus_console;

   procedure control_menu is
   begin
      Put_Line ("********************************************");
      Put_Line ("");
      Put_Line("                   MENU                      ");
      Put_Line ("");
      Put_Line(" 1 - See current status of bus and reactor");
      Put_Line(" 2 - Activate/Deactivate Reactor");
      Put_Line(" 3 - Manage control rods");
      Put_Line(" 4 - Start/Stop Bus");
      Put_Line(" 5 - Manage Water Supply");
      Put_Line(" 6 - Manage Radio active waste");
      Put_Line(" r - Go Back To Main Menu");
      Put_Line(" e - Exit Menu");
      Put_Line ("");
      Put_Line(" ********************************************");

   end control_menu;


   procedure systemStatus is
   begin
      Put_Line("");
      Put_Line(" SYSTEM STATUS");
      Put_Line("");
      Put_Line(" Power : " & bus.power'Image);
      Put_Line(" Speed : "& bus.speed'Image);
      Put_Line(" Reactor Status : "& bus.bussystem.status'Image);
      Put_Line(" Control Rods Status : "& bus.bussystem.crods'Image);
      Put_Line(" Water System Status : "& bus.bussystem.water'Image);
      Put_Line(" Temperature of Reacture : "& bus.bussystem.temperature'Image);
      Put_Line(" System Heat Status : "& bus.bussystem.heat'Image);
      Put_Line(" Radio active Waste Status: "& bus.bussystem.radioactivity'Image);
      Put_Line("");

   end systemStatus;



   task ControlSystem;
   task Journey;
   task HeatStatus;
   task WasteStatus;

   task body ControlSystem is
   begin
      bus_console;
      control_menu;
      loop
         Put_Line("");
         Put("Press number from menu to perform operation :  ");
         Get(user_input);

         if (user_input = "1") then systemStatus;
         elsif (user_input = "2") then
            if(bus.bussystem.status = Activated and then bus.speed = 0) then
               reactorDeactivate;
            else reactorActive;
            end if;
         elsif (user_input = "3") then
            Put_Line("type a to add control rod");
            Put_Line("type b to remove control rod");
            Get (user_input);
            if (user_input = "a") then
               if(bus.bussystem.crods < R_CRods'Last) then insertCrods;
               else Put_Line("Already have maximum Control Rods");
               end if;

            elsif (user_input = "b") then
               if(bus.bussystem.crods > R_CRods'First) then removeCrods;
               else Put_Line("Not enough Control Rod available to remove");
               end if;
            end if;
         elsif (user_input = "4") then
            if bus.speed > 0 then stopBus;
            elsif (bus.bussystem.status = Activated) then startBus;
            else Put_Line("Reactor is not activated. Activate to start the bus.");
            end if;
         elsif (user_input = "5") then
            if (bus.speed = 0) then waterRefill;
            else Put_Line("Bus is moving : Cannot refill water. Press 4 to stop the bus");
            end if;
         elsif (user_input = "6") then removeRadiowaste;
         elsif (user_input = "r") then control_menu;
         elsif (user_input = "e") then abort Journey; exit;
         else abort Journey; exit;
         end if;
      end loop;
   end ControlSystem;

   task body Journey is
   begin
      loop
         if (bus.speed > 0) then
            startReactor;
            setSpeedlimit;
            increaseBusspeed;
            Put_Line ("Max Bus Speed :" & bus.speedlimit'Image
                      & " Speed : "& bus.speed'Image
                      & "  Temperature of Reactor : " & bus.bussystem.temperature'Image
                      & "  Radioactive Waste : " & bus.bussystem.radioactivity'Image
                      & "   System Heating : " & bus.bussystem.heat'Image);
         end if;
         delay 0.2;
      end loop;
   end Journey;

   task body HeatStatus is
   begin
      loop
         if (bus.speed > 0 and then bus.bussystem.temperature >= 200) then
            isOverheated;
            supplyWater;
         end if;
         delay 0.2;
      end loop;
   end HeatStatus;

   task body WasteStatus is
   begin
      loop
         if (bus.speed > 0) then
            radioWaste;
         end if;
         delay 0.2;
      end loop;
   end WasteStatus;

begin
   --  Insert code here.
   null;
end Main;
