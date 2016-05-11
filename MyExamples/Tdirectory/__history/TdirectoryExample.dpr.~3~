program TdirectoryExample;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.IOUtils,
  System.Types;

var
  Disks, Dirs, Files: TStringDynArray;
  I, J: Integer;
  F, F2: TextFile;
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
     Disks := TDirectory.GetLogicalDrives;
     for I := Low(Disks) to High(Disks) do
       Writeln(Disks[I]);
     Readln;
     Dirs := TDirectory.GetDirectories(Disks[0],'*',TSearchOption(1));
     Assign(F,'dir.txt');
     Rewrite(F);
     Assign(F2,'files.txt');
     Rewrite(F2);
     for I := Low(Dirs) to High(Dirs) do
       begin
        Writeln(f,Dirs[I]);
    //    Files := TDirectory.GetFiles(Dirs[I],'*');
     //     for J := Low(Files) to High(Files) do
     //      Writeln(f2,Files[J]);
       end;

     Close(F);
     Close(F2);
     Writeln('Готово!');
     Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
