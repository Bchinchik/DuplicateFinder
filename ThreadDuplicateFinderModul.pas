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
      OnMemoSent: TSentEvent;
      OnMemoSentR: TSentEventR;
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
   // ch: string;
begin

  DirList := TStringList.Create;
  //Rez := TFindRezult.Create;
  if (FStartFolder[Length(FStartFolder)]) = '\' then
     Delete(FStartFolder,(Length(FStartFolder)),1);
  //ShowMessage(FStartFolder[Length(FStartFolder)]);
  DirList.Add(FStartFolder);
  I := 0;
  ArrayLength := 1;
  FFileCounter := 0;
  //DRCount := DirList.Count - 1;
 while I <= DirList.Count - 1 do
  begin

    try
    if FindFirst(ExpandFileName(DirList[I] + '\*.*'),faAnyFile, SearchRec) = 0 then
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
          FRez.Path := DirList[I] + '\' + SearchRec.Name;
          FFileList.Add(FRez.FileName + ' | ID: ' + IntToStr(ArrayLength-1));
          //FFileList.Add(SearchRec.Name + '   |   ����:  ' +
          //DirList[I] +  SearchRec.Name);
         // FFileList.Add(Rez.AllString);
          // Trying to fill dynamic array :)
          SetLength(FMass,ArrayLength);
          FMass[ArrayLength-1] := FRez;
          //FMass[ArrayLength-1].FileName := Rez.FileName;
         // FMass[ArrayLength-1].Size := Rez.Size;
         // FMass[ArrayLength-1].TimeM := Rez.TimeM;
         // FMass[ArrayLength-1].Path := Rez.Path;
          Inc(ArrayLength);
          Inc(FFileCounter);
          ShellSynchronize(OnFileCountSent,IntToStr(FFileCounter));
          ShellSynchronize(OnPathScanSent,DirList[I]);
          //PathScaning := DirList[I];
          if FFindCriteria = 8 then
             ShellSynchronize(OnMemoSentR,FRez);
        end;

      end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
      Inc( I );
    end;
  end;

  DirList.Free;
  //Rez.Free;
  //SortFMassByName;
  //FFileList.Sort;
  //MainForm.MmoDuplicateRezult.Lines.AddStrings(FFileList);
  //ShowMessage('111');
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
  //if (FFindCriteria = 0) or Self.Terminated then
  // Break;
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
             ShellSynchronize(OnMemoSentR,FRez);
           repeat
            FRez := FMass[n];
            ShellSynchronize(OnMemoSentR,FRez);
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
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
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
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
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
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].FileName <> fmass[n].FileName)and(FMass[k].Size <> fmass[n].Size);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

      5:begin
          if (FMass[k].FileName = fmass[n].FileName)and(FMass[k].TimeM = fmass[n].TimeM) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].FileName <> fmass[n].FileName)and(FMass[k].TimeM <> fmass[n].TimeM);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
        end;

       6:begin
           if (FMass[k].TimeM = fmass[n].TimeM)and(FMass[k].Size = fmass[n].Size) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (FMass[k].TimeM <> fmass[n].TimeM)and(FMass[k].Size <> fmass[n].Size);
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
         end;

        7:begin
            if (((FMass[k].FileName = fmass[n].FileName)and(FMass[k].Size = fmass[n].Size))and(FMass[k].TimeM = fmass[n].TimeM)) then
           begin
             FRez := FMass[k];
             ShellSynchronize(OnMemoSentR,FRez);
            repeat
             FRez := FMass[n];
             ShellSynchronize(OnMemoSentR,FRez);
             if i = ListCount then Break;
             Inc(I);
             ShellSynchronize(OnProgressSent,IntToStr(I));
             PosNext := AnsiPos(Sub,FFileList[I + 1]);
             n := StrToInt(Copy(FFileList[I+1],PosNext+5,Length(FFileList[I+1])-PosNext+5));
            until (((FMass[k].FileName <> fmass[n].FileName)or(FMass[k].Size <> fmass[n].Size))or(FMass[k].TimeM <> fmass[n].TimeM));
           end;
          Inc(I);
          ShellSynchronize(OnProgressSent,IntToStr(I));
          end;
   end;





  end;
{if FFindCriteria = 1 then
  begin
    FDuplIter := 0;
    J := 1;
    ProgressMax := FFileList.Count - 1;

    while FDuplIter < FFileList.Count - 1 do
    if Self.Terminated then
      Break
    else
    begin
      SubStrPosFirst := AnsiPos(SubStr,FFileList[FDuplIter]);
      SubStrPosNext := AnsiPos(SubStr,FFileList[FDuplIter + 1]);
      CmprStrFist := Copy(FFileList[FDuplIter],1,SubStrPosFirst - 1);
      CmprStrNext := Copy(FFileList[FDuplIter + 1],1,SubStrPosNext - 1);
      //First string = Next string = Duplicate
      if AnsiCompareText(CmprStrFist,CmprStrNext) = 0 then
      begin
        FBufStrMemoAdd := FFileList[FDuplIter];
        ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

        FBufStrMemoAdd := FFileList[FDuplIter + 1];
        ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

        J := FDuplIter + 2;
        CmprStrFist := Copy(FFileList[FDuplIter],1,SubStrPosFirst - 1);
        CmprStrNext := Copy(FFileList[J],1,SubStrPosNext - 1);
        while AnsiCompareText(CmprStrFist,CmprStrNext) = 0 do
        //Matches more than one
        begin
          FBufStrMemoAdd := FFileList[J];
          ShellSynchronize(OnMemoSent,FBufStrMemoAdd);
          Inc( J );
          ProgressCur := J;
          CmprStrFist := Copy(FFileList[FDuplIter],1,SubStrPosFirst - 1);
          CmprStrNext := Copy(FFileList[J],1,SubStrPosNext - 1);
        end;
          FBufStrMemoAdd := '____________________________________________________________________________________________________';
          ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

          ShellSynchronize(OnProgressSent,IntToStr(FDuplIter));
      end
      else
          ShellSynchronize(OnProgressSent,IntToStr(FDuplIter));

        if FDuplIter < J then
           FDuplIter := J
        else
          begin
           Inc( FDuplIter );

           //Inc(ProgressCur);
           //b:=IntToStr(FDuplIter);
          end;
    end;
  end
  else
  begin
    FBufStrMemoAdd := '����� ������ �� ������� ��������.';
    ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

  end;
 // AFCStopFlag := True;}
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
