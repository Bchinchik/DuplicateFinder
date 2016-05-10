program RecordLikeClass;

{$APPTYPE CONSOLE}

{$R *.res}

uses
  System.SysUtils,
  System.DateUtils;

type TStudent = record
  private
    function FGetAge: string;
  public
    SName, FName: string[20];
    BDate: TDateTime;
    property Age: string read FGetAge;
end;
function TStudent.FGetAge: string;
begin
  Result := IntToStr(YearsBetween(Now,BDate));
end;
var
  Test: TStudent;
  StringDate: string=('27.02.1984');
begin
  try
    { TODO -oUser -cConsole Main : Insert code here }
    //Readln(Test.SName);
    //Readln(Test.FName);
    //Readln(StringDate);
    Test.BDate := StrToDate(StringDate);
    Writeln('Óðà!!! ',Test.Age);
    Readln;
  except
    on E: Exception do
      Writeln(E.ClassName, ': ', E.Message);
  end;
end.
