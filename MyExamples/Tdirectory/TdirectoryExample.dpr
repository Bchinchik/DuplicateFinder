program TdirectoryExample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  System.Types, System.Classes;

var
  Disks, Dirs, Files: TStringDynArray;
  I, J: Integer;
  F, F2, CompareFile: TextFile;
  List1, List2, List3: TStringList;
  t: string;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
     Disks := TDirectory.GetLogicalDrives;
     for I := Low(Disks) to High(Disks) do
       Writeln(Disks[I]);
     Readln;
     Writeln('Starting...');
     //Dirs := TDirectory.GetDirectories(Disks[0],'*',TSearchOption(1));
     //Assign(F,'test.txt');
    // Reset(f);
    // Assign(CompareFile,'rez.txt');
    // Rewrite(CompareFile);
     Assign(F2,'files.txt');
     Rewrite(F2);
    // for I := Low(Dirs) to High(Dirs) do
       begin
      //  Writeln(f,Dirs[I]);
        Files := TDirectory.GetFiles('e:\','*',TSearchOption(1));
          for J := Low(Files) to High(Files) do
           Writeln(f2,Files[J]);
           begin

           end;
       end;
     List1:= TStringList.Create;
     List2:= TStringList.Create;
     List3:= TStringList.Create;
     List2.LoadFromFile('test.txt');
     List1.LoadFromFile('files.txt');
     for i := 0 to List1.Count -1 do
      begin
        if List2.IndexOf(List1[I]) = -1 then
           List3.Add(List1[I]);
      end;
     List3.SaveToFile('rez.txt');
     List1.Free;
          List2.Free;
               List3.Free;
     Writeln('Готово!');
     Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
