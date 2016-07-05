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
  TMemoSentEvent = procedure (Sender: TObject; AddLine: string) of object;
  TLabelSentEvent = procedure (Sender: TObject; AddCount: string) of object;
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
     // procedure AddLinesMemo2;
  protected
      procedure Execute; override;
  public
      OnMemoSent: TMemoSentEvent;
      OnLabelSent: TLabelSentEvent;
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
        if MatchesMask(SearchRec.Name,MainForm.EdtFindMask.Text) then
        begin
          FSearchStrLiRez.Add(SearchRec.Name + '   |   ����:  ' +
          DirList[I] + '\' + SearchRec.Name);
          if not MainForm.ChkBoxHeader.Checked then
          begin
            FBufStrMemoAdd := DirList[I] + '\' + SearchRec.Name;

            if Assigned(OnMemoSent) then
               Synchronize(procedure
                            begin
                             OnMemoSent(Self,FBufStrMemoAdd);
                            end);
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

procedure ThreadFinder.Execute;
begin

  FSearchStrLiRez := TStringList.Create;
  GetDirFilesList;
  FSearchStrLiRez.Sort;
  GetDuplicateFiles;
  FSearchStrLiRez.Free;

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
    if Assigned(OnMemoSent) then
       Synchronize(procedure
                     begin
                      OnMemoSent(Self,FBufStrMemoAdd);
                     end);

    FDuplIter := 0;
    J := 1;
    MainForm.ProgressBar.Max := FSearchStrLiRez.Count - 1;
    while FDuplIter < FSearchStrLiRez.Count - 2 do
    if Self.Terminated then
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
        if Assigned(OnMemoSent) then
           Synchronize(procedure
                        begin
                          OnMemoSent(Self,FBufStrMemoAdd);
                        end);

        FBufStrMemoAdd := FSearchStrLiRez[FDuplIter + 1];

        if Assigned(OnMemoSent) then
           Synchronize(procedure
                         begin
                           OnMemoSent(Self,FBufStrMemoAdd);
                         end);
        J := FDuplIter + 2;
        CmprStrFist := Copy(FSearchStrLiRez[FDuplIter],1,SubStrPosFirst - 1);
        CmprStrNext := Copy(FSearchStrLiRez[J],1,SubStrPosNext - 1);
        while AnsiCompareText(CmprStrFist,CmprStrNext) = 0 do
        //Matches more than one
        begin
          FBufStrMemoAdd := FSearchStrLiRez[J];
          if Assigned(OnMemoSent) then
             Synchronize(procedure
                           begin
                            OnMemoSent(Self,FBufStrMemoAdd);
                           end);

          Inc( J );
          CmprStrFist := Copy(FSearchStrLiRez[FDuplIter],1,SubStrPosFirst - 1);
          CmprStrNext := Copy(FSearchStrLiRez[J],1,SubStrPosNext - 1);
        end;
          FBufStrMemoAdd := '____________________________________________________________________________________________________';

          if Assigned(OnMemoSent) then
             Synchronize(procedure
                          begin
                            OnMemoSent(Self,FBufStrMemoAdd);
                          end);
          Synchronize(SetProgressBar);
      end
      else
        Synchronize(SetProgressBar);

        if FDuplIter < J then
           FDuplIter := J
        else
           Inc( FDuplIter );
    end;
  end
  else
  begin
    FBufStrMemoAdd := '����� ������ �� ������� ��������.';
    if Assigned(OnMemoSent) then
       Synchronize(procedure
                 begin
                   OnMemoSent(Self,FBufStrMemoAdd);
                 end);

  end;
end;


end.
