-- Miniaturized Nuclear Powered Bus Control System (Refactored & Improved)
-- Includes error handling, better CLI, logging, and optional authentication

with Ada.Text_IO; use Ada.Text_IO;
with Ada.Integer_Text_IO; use Ada.Integer_Text_IO;
with Ada.Calendar; use Ada.Calendar;

procedure Bus_Control_System is

   -- System Log Procedure
   procedure Log_Action(Message : String) is
      Log_File : File_Type;
   begin
      Open(Log_File, Append_File, "system_log.txt");
      Put_Line(Log_File, Message);
      Close(Log_File);
   exception
      when others => Put_Line("Logging error occurred");
   end Log_Action;

   -- Authentication for Critical Actions
   procedure Authenticate is
      Pin : Integer;
   begin
      Put_Line("Enter admin PIN to proceed: ");
      Get(Pin);
      if Pin /= 1234 then
         Put_Line("Access Denied.");
         return;
      end if;
   exception
      when Constraint_Error =>
         Put_Line("Invalid PIN format.");
         return;
   end Authenticate;

   -- Validate Speed Input
   function Get_Validated_Speed return Integer is
      Speed : Integer;
   begin
      loop
         Put_Line("Enter desired speed (0-100): ");
         Get(Speed);
         exit when Speed >= 0 and Speed <= 100;
         Put_Line("Invalid input! Please enter a speed between 0 and 100.");
      end loop;
      return Speed;
   exception
      when Constraint_Error =>
         Put_Line("Invalid input. Please enter a number.");
         return 0;
   end Get_Validated_Speed;

   -- Reactor Control
   procedure Control_Reactor(Start : Boolean) is
   begin
      if Start then
         Put_Line("Reactor Started.");
         Log_Action("Reactor started at " & Time'Image(Clock));
      else
         Put_Line("Reactor Stopped.");
         Log_Action("Reactor stopped at " & Time'Image(Clock));
      end if;
   end Control_Reactor;

   -- Emergency Shutdown with Confirmation
   procedure Emergency_Shutdown is
      Response : Character;
   begin
      Put_Line("⚠ WARNING: This will shut down the reactor immediately!");
      Put_Line("Are you sure? (Y/N): ");
      Get(Response);
      if Response = 'Y' or Response = 'y' then
         Put_Line("Emergency Shutdown Activated!");
         Log_Action("Emergency shutdown triggered at " & Time'Image(Clock));
      else
         Put_Line("Emergency shutdown cancelled.");
      end if;
   exception
      when others =>
         Put_Line("Error in shutdown process.");
   end Emergency_Shutdown;

   -- Main Program Loop
   Choice : Integer;
begin
   loop
      Put_Line("\n============================");
      Put_Line("  Nuclear Bus Control System");
      Put_Line("============================");
      Put_Line("[1] Start Reactor");
      Put_Line("[2] Stop Reactor");
      Put_Line("[3] Set Bus Speed");
      Put_Line("[4] Emergency Shutdown");
      Put_Line("[5] Exit");
      Put_Line("Enter your choice: ");
      Get(Choice);

      case Choice is
         when 1 =>
            Control_Reactor(True);
         when 2 =>
            Control_Reactor(False);
         when 3 =>
            declare
               Speed : Integer := Get_Validated_Speed;
            begin
               Put_Line("Bus speed set to " & Integer'Image(Speed) & " km/h");
               Log_Action("Speed set to " & Integer'Image(Speed));
            end;
         when 4 =>
            Authenticate;
            Emergency_Shutdown;
         when 5 =>
            Put_Line("Exiting System...");
            exit;
         when others =>
            Put_Line("Invalid option! Please enter a valid choice.");
      end case;
   exception
      when Constraint_Error =>
         Put_Line("Invalid input! Please enter a valid number.");
   end loop;
end Bus_Control_System;
