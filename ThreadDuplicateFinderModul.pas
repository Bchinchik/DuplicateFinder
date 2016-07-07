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
  TSentEvent = procedure (Sender: TObject; AddLine: string) of object;
  ThreadFinder = class(TThread)
    private
      FDuplIter: Integer;
      FDirSearchPath: string;
      FBufStrMemoAdd: string;
      FFileList: TStringList;
      FStartFolder: string;

      FFindCriteria : Integer;
      FFindMask: string;
      procedure GetDirFilesList;
      procedure GetDuplicateFiles;
     // procedure SetProgressBar;
      procedure ShellSynchronize(AObject: TSentEvent  ; BufStr: string);
    protected
      procedure Execute; override;
    public
      AllFileCounter: Integer;
      ProgressMax: Integer;
      ProgressCur: Integer;
      StartFlag: Boolean;
            a,b:string;
    //  AFCStopFlag: Boolean;
      PathScaning: string;
      OnMemoSent: TSentEvent;
      OnLabelCountSent: TSentEvent;
      constructor Create(StartFolder: string; FindCriteria: Integer; FindMask: string);
 end;

implementation

//uses
//  DuplicateFinder;

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

begin

  DirList := TStringList.Create;
  DirList.Add(FStartFolder);
  I := 0;
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
          FFileList.Add(SearchRec.Name + '   |   Путь:  ' +
          DirList[I] + '\' + SearchRec.Name);
          if FFindCriteria = 8 then
          begin
            FBufStrMemoAdd := DirList[I] + '\' + SearchRec.Name;
            ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

          end;
          Inc( AllFileCounter );
          PathScaning := DirList[I];

        end;

      end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
      Inc( I );
    end;
  end;
  DirList.Free;
 // AFCStopFlag := True;
end;

{procedure ThreadFinder.SetProgressBar;
begin
  with MainForm.ProgressBar do
  begin
    if Visible = False then
    Visible := True;
    Position := FDuplIter;
  end;
end;}

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
  FFileList.Sort;
  GetDuplicateFiles;
  FFileList.Free;

end;


procedure ThreadFinder.GetDuplicateFiles;
  const
    SubStr: string='   |';
  var
    J, SubStrPosFirst, SubStrPosNext: Integer;
    CmprStrFist, CmprStrNext: string;
begin
  if FFindCriteria = 1 then
  begin
    FDuplIter := 0;
    J := 1;
    ProgressCur := FDuplIter;
    ProgressMax := FFileList.Count - 1;
    StartFlag := True;
    a:=IntToStr(FFileList.Count - 1);
    //MainForm.ProgressBar.Max := FFileList.Count - 1;
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

         // Synchronize(SetProgressBar);
      end;
      //else
       // Synchronize(SetProgressBar);

        if FDuplIter < J then
           FDuplIter := J
        else
          begin
           Inc( FDuplIter );
           Inc(ProgressCur);
           b:=IntToStr(FDuplIter);
          end;
    end;
  end
  else
  begin
    FBufStrMemoAdd := 'Поиск Файлов по шаблону завершен.';
    ShellSynchronize(OnMemoSent,FBufStrMemoAdd);

  end;
 // AFCStopFlag := True;
end;


end.
