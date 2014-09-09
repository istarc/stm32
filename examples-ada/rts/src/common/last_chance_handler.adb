procedure Last_Chance_Handler
  (Source_Location : System.Address; Line : Integer) is
   pragma Unreferenced (Source_Location, Line);
begin
   --  TODO: Add in code to dump the info to serial/screen which
   --  is obviously board specific.
   loop
      null;
   end loop;
end Last_Chance_Handler;
