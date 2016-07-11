{------------------------------------------------------------}
{        Thread Duplicate Finder Modul                       }
{       Copyright (c)        BChinchik                       }
{                                                            }
{       Developer:     Bogdan Chinchik                       }
{       E-mail   :     Bchinchik@ua.fm                       }
{------------------------------------------------------------}
unit ThreadDuplicateFinderModul;

interface

uses
  Classes, SysUtils, Masks, StdCtrls, Dialogs;

type

  TFindRezult = record
    private
      function FGetAllString: string;
      function FGetTimeMDateStr: string;
    public
      FileName: string;
      Path: string;
      Size: Integer;
      TimeM: Integer;
      property AllString: string read FGetAllString;
      property TimeMDateStr: string  read FGetTimeMDateStr;
  end;
    TSentEvent = procedure (Sender: TObject; AddLine: string) of object;
    TSentEventR = procedure (Sender: TObject; Add: TFindRezult) of object;
  ThreadFinder = class(TThread)
    private
      FFileList: TStringList;
      FStartFolder: string;
      FFindCriteria : Integer;
      FFileCounter: Integer;
      FFindMask: string;
      FMass: array of TFindRezult;
      FRez: TFindRezult;
      procedure GetDirFilesList;
      procedure GetDuplicateFiles;
      procedure SortFMassByName;
      procedure ShellSynchronize(AObject: TSentEvent  ; BufStr: string);overload;
      procedure ShellSynchronize(AObject: TSentEventR  ; Buf: TFindRezult);overload;
    protected
      procedure Execute; override;
    public
      ProgressMax: Integer;
      ProgressCur: Integer;
      //StartFlag: Boolean;
      OnPathScanSent: TSentEvent;
      //OnMemoSent: TSentEvent;
      OnGridSentR: TSentEventR;
      OnProgressSent: TSentEvent;
      OnFileCountSent: TSentEvent;
      constructor Create(StartFolder: string; FindCriteria: Integer; FindMask: string);
 end;

implementation
 uses
 DuplicateFinder;
{ ThreadFinder }
constructor ThreadFinder.Create;
begin
  inherited Create(True);
  FreeOnTerminate := True;
  Self.Priority := tpNormal;
  FStartFolder := StartFolder;
  FFindCriteria := FindCriteria;
  FFindMask := FindMask;
end;

procedure ThreadFinder.GetDirFilesList;
  var
    SearchRec: TSearchRec;
    DirList: TStringList;
    I: Integer;
    ArrayLength: Integer;

begin
  DirList := TStringList.Create;

  if (FStartFolder[Length(FStartFolder)]) = '\' then
     Delete(FStartFolder,(Length(FStartFolder)),1);
  DirList.Add(FStartFolder);
  I := 0;
  ArrayLength := 1;
  FFileCounter := 0;

 while I <= DirList.Count - 1 do
  begin

    try
    if FindFirst(ExpandFileName(DirList[I] + '\*'),faAnyFile, SearchRec) = 0 then
      repeat
      if Self.Terminated then
        Break
      else
      if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name[1] <> '.') then
      begin
        DirList.Add(ExpandFileName(DirList[I] + '\' + SearchRec.Name));
      end
      else
      if (SearchRec.Name[1] <> '.') then
      begin
        if MatchesMask(SearchRec.Name,FFindMask) then
        begin
          FRez.FileName := SearchRec.Name;
          FRez.Size := SearchRec.Size;
          FRez.TimeM := SearchRec.Time;
          FRez.Path := DirList[I]+ '\';
          case FFindCriteria of
             1,4,5,7:FFileList.Add(FRez.FileName + ' | ID: ' + IntToStr(ArrayLength-1));
             2:FFileList.Add(IntToStr(FRez.Size) + ' | ID: ' + IntToStr(ArrayLength-1));
             3:FFileList.Add(IntToStr(FRez.TimeM) + ' | ID: ' + IntToStr(ArrayLength-1));
             6:FFileList.Add(IntToStr(FRez.Size) + ' | ID: ' + IntToStr(ArrayLength-1));
          end;
          //  dynamic array
          SetLength(FMass,ArrayLength);
          FMass[ArrayLength-1] := FRez;
          Inc(ArrayLength);
          Inc(FFileCounter);
          ShellSynchronize(OnFileCountSent,IntToStr(FFileCounter));
          ShellSynchronize(OnPathScanSent,DirList[I]);
          if FFindCriteria = 8 then
             ShellSynchronize(OnGridSentR,FRez);
        end;

      end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
      Inc( I );
    end;
  end;

  DirList.Free;

end;


procedure ThreadFinder.ShellSynchronize(AObject: TSentEvent; BufStr: string);
begin
  if Assigned(AObject) then
       Synchronize(procedure
                     begin
                      AObject(Self,BufStr);
                     end);
end;

procedure ThreadFinder.Execute;
begin

  FFileList := TStringList.Create;
  GetDirFilesList;
  GetDuplicateFiles;
  FFileList.Free;

end;


procedure ThreadFinder.GetDuplicateFiles;
  const
    Sub: string='| ID: ';
  var
    I,k,n,ListCount, PosFirst, PosNext: Integer;

begin

  I := 0;
  FFileList.Sort;
  ListCount := FFileList.Count - 2;
  ProgressMax := ListCount;
  while I <= ListCount do
  if Self.Terminated then Break
  else

  begin
    PosFirst := AnsiPos(Sub,FFileList[I]);
    PosNext := AnsiPos(Sub,FFileList[I + 1]);
    k := StrToInt(Copy(FFileList[I],PosFirst+5,Length(FFileList[I])-PosFirst+5));
    n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));

   case FFindCriteria of
     8: Break;
     1: begin
          if FMass[k].FileName = fmass[n].FileName then
          begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
           repeat
            FRez := FMass[n];
            ShellSynchronize(OnGridSentR,FRez);
            if i = ListCount then Break;
            Inc(I);
            ShellSynchronize(OnProgressSent,IntToStr(I));
            PosNext := AnsiPos(Sub,FFileList[I + 1]);
            n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
           until ((FMass[k].FileName <> fmass[n].FileName));
          end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

      2:begin
           if FMass[k].Size = fmass[n].Size then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until ((FMass[k].Size <> fmass[n].Size));
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

      3:begin
          if FMass[k].TimeM = fmass[n].TimeM then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until ((FMass[k].TimeM <> fmass[n].TimeM));
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

      4:begin
          if (FMass[k].FileName = fmass[n].FileName)and(FMass[k].Size = fmass[n].Size) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].FileName <> fmass[n].FileName)or(FMass[k].Size <> fmass[n].Size);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

      5:begin
          if (FMass[k].FileName = fmass[n].FileName)and(FMass[k].TimeM = fmass[n].TimeM) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].FileName <> fmass[n].FileName)or(FMass[k].TimeM <> fmass[n].TimeM);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

       6:begin
           if (FMass[k].TimeM = fmass[n].TimeM)and(FMass[k].Size = fmass[n].Size) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].TimeM <> fmass[n].TimeM)or(FMass[k].Size <> fmass[n].Size);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
         end;

        7:begin
            if (((FMass[k].FileName = fmass[n].FileName)and(FMass[k].Size = fmass[n].Size))and(FMass[k].TimeM = fmass[n].TimeM)) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnGridSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnGridSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].FileName <> fmass[n].FileName)or(FMass[k].Size <> fmass[n].Size)or(FMass[k].TimeM <> fmass[n].TimeM);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
          end;
   end;
  end;

 end;


procedure ThreadFinder.ShellSynchronize(AObject: TSentEventR; Buf: TFindRezult);
begin
  if Assigned(AObject) then
       Synchronize(procedure
                     begin
                      AObject(Self,Buf);
                     end);
end;

procedure ThreadFinder.SortFMassByName;
 var
  i,j,s2,s3: Integer;
  s1,s4: string;
begin
  for I := 0 to High(FMass)-1 do
    for j := i+1 to High(FMass) do
      if j<>i then
        if FMass[I].FileName > fmass[j].FileName then

        begin
         s1 := FMass[I].FileName;
         s2 := FMass[I].Size;
         s3 := FMass[I].TimeM;
         s4 := FMass[I].Path;
         FMass[I].FileName := FMass[j].FileName;
         FMass[I].Size := FMass[j].Size;
         FMass[I].TimeM := FMass[j].TimeM;
         FMass[I].Path := FMass[j].Path;
         FMass[j].FileName := s1;
         FMass[j].Size := s2;
         FMass[j].TimeM := s3;
         FMass[j].Path := s4;
        end;

end;



{ TFindRezult }

function TFindRezult.FGetAllString: string;
  var
    DateTime:TDateTime;
begin
  DateTime:=FileDateToDateTime(TimeM);
  Result := 'Name:'+FileName+' |'+' Size:'+IntToStr(Size)+' B |'
  +' Date:'+DateTimeToStr(DateTime)+' | Path:'+Path;
end;

function TFindRezult.FGetTimeMDateStr: string;
var
    DateTime:TDateTime;
begin
  DateTime:=FileDateToDateTime(TimeM);
  Result := DateTimeToStr(DateTime);
end;

end.
