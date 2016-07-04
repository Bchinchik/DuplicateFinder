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
  ThreadFinder = class(TThread)
  private
      FCountFile: Integer;
      FDuplIter: Integer;
      FDirSearchPath: string;
      FBufStrMemoAdd: string;
      FSearchStrLiRez: TStringList;
      FStartFolder: string;
      FFindCriteria : Integer;
      procedure GetDirFilesList;
      procedure GetDuplicateFiles;
      procedure SetLabelCountFile;
      procedure SetLabelPath;
      procedure SetProgressBar;
      procedure AddLinesMemo2;
      procedure SuccessExecuteEnd;

  protected
      procedure Execute; override;
      procedure tt; virtual; 
  public
      constructor Create(Param1: string; Param2: Integer);

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
  FStartFolder := Param1;
  FFindCriteria := Param2;
  //tt;
  Resume;

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
      if FindThread.Terminated then
        Break
      else
      if ((SearchRec.Attr and faDirectory) <> 0) and (SearchRec.Name[1] <> '.') then
      begin
        DirList.Add(ExpandFileName(DirList[I] + '\' + SearchRec.Name));
      end
      else
      if (SearchRec.Name[1] <> '.') then
      begin
        if MatchesMask(SearchRec.Name,MainForm.EdtFindMask.Text) then
        begin
          FSearchStrLiRez.Add(SearchRec.Name + '   |   ����:  ' +
          DirList[I] + '\' + SearchRec.Name);
          if not MainForm.ChkBoxHeader.Checked then
          begin
            FBufStrMemoAdd := DirList[I] + '\' + SearchRec.Name;
            Synchronize(AddLinesMemo2);
          end;
          Inc( FCountFile );
          FDirSearchPath := DirList[I];
          Synchronize(SetLabelCountFile);
        end;

        Synchronize(SetLabelPath);
      end;
      until FindNext(SearchRec) <> 0;
    finally
      FindClose(SearchRec);
      Inc( I );
    end;
  end;
  DirList.Free;
end;

procedure ThreadFinder.SetLabelCountFile;
begin
  MainForm.stat1.Panels[1].Text := IntToStr(FCountFile);
end;

procedure ThreadFinder.SetLabelPath;
begin
  MainForm.stat1.Panels[0].Text := FDirSearchPath;
end;

procedure ThreadFinder.SetProgressBar;
begin
  with MainForm.ProgressBar do
  begin
    if Visible = False then
    Visible := True;
    Position := FDuplIter;
  end;
end;

procedure ThreadFinder.AddLinesMemo2;
begin
  MainForm.MmoDuplicateRezult.Lines.Add(FBufStrMemoAdd);
end;

procedure ThreadFinder.Execute;
begin
  Synchronize(tt);
  FSearchStrLiRez := TStringList.Create;
  GetDirFilesList;
  FSearchStrLiRez.Sort;
  GetDuplicateFiles;
  FSearchStrLiRez.Free;
  Synchronize(SuccessExecuteEnd);
end;


procedure ThreadFinder.GetDuplicateFiles;
  const
    SubStr: string='   |';
  var
    J,SubStrPosFirst,SubStrPosNext: Integer;
    CmprStrFist, CmprStrNext: string;
begin
  if FFindCriteria = 1 then
  begin
    FBufStrMemoAdd := '���������� � ������������ ������ ��������� ������, ���������...';
    Synchronize(AddLinesMemo2);
    FDuplIter := 0;
    J := 1;
    MainForm.ProgressBar.Max := FSearchStrLiRez.Count - 1;
    while FDuplIter < FSearchStrLiRez.Count - 1 do
    if FindThread.Terminated then
      Break
    else
    begin
      SubStrPosFirst := AnsiPos(SubStr,FSearchStrLiRez[FDuplIter]);
      SubStrPosNext := AnsiPos(SubStr,FSearchStrLiRez[FDuplIter + 1]);
      CmprStrFist := Copy(FSearchStrLiRez[FDuplIter],1,SubStrPosFirst - 1);
      CmprStrNext := Copy(FSearchStrLiRez[FDuplIter + 1],1,SubStrPosNext - 1);
      //First string = Next string = Duplicate
      if AnsiCompareText(CmprStrFist,CmprStrNext) = 0 then
      begin
        FBufStrMemoAdd := FSearchStrLiRez[FDuplIter];
        Synchronize(AddLinesMemo2);
        FBufStrMemoAdd := FSearchStrLiRez[FDuplIter + 1];
        Synchronize(AddLinesMemo2);
        J := FDuplIter + 2;
        CmprStrFist := Copy(FSearchStrLiRez[FDuplIter],1,SubStrPosFirst - 1);
        CmprStrNext := Copy(FSearchStrLiRez[j],1,SubStrPosNext - 1);
        while AnsiCompareText(CmprStrFist,CmprStrNext) = 0 do
        //Matches more than one
        begin
          FBufStrMemoAdd := FSearchStrLiRez[J];
          Synchronize(AddLinesMemo2);
          Inc( J );
          CmprStrFist := Copy(FSearchStrLiRez[FDuplIter],1,SubStrPosFirst - 1);
          CmprStrNext := Copy(FSearchStrLiRez[j],1,SubStrPosNext - 1);
        end;
          FBufStrMemoAdd := '____________________________________________________________________________________________________';
          Synchronize(AddLinesMemo2);
          Synchronize(SetProgressBar);
      end
      else
        Synchronize(SetProgressBar);
     //   if FDuplicateIterator = 0 then
     //      FDuplicateIterator := 1
     //   else
     //   if J = 1 then
     //      Inc( FDuplicateIterator )
     //   else
        if FDuplIter < J then
           FDuplIter := J
        else
           Inc( FDuplIter );
    end;
  end
  else
  begin
    FBufStrMemoAdd := '����� ������ �� ������� ��������.';
    Synchronize(AddLinesMemo2);
  end;
end;

procedure ThreadFinder.SuccessExecuteEnd;
begin
  MainForm.stat1.Panels[2].Text := '��������';
  MainForm.BtnStartFind.Enabled := True;
  MainForm.BtnStopFind.Visible := False;
  MainForm.BtnPlayPause.Visible := False;
  MainForm.MniStopFind.Enabled := False;
  MainForm.MniPlayPause.Enabled := False;
  MainForm.ProgressBar.Visible := False;
end;




procedure ThreadFinder.tt;
begin
      ShowMessage('////////////////');
end;

end.
