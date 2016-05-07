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
  Classes, SysUtils, Masks;

type
  ThreadFinder = class(TThread)
  private
      FCountFile: Integer;
      FDuplicateIterator: Integer;
      FDirectorySearchString: string;
      FBufStrMemoAdd: string;
      FSearchStringListRezult: TStringList;
      procedure GetDirFilesList(StartFolder: string);
      procedure GetDuplicateFiles;
      procedure SetLabelCountFile;
      procedure SetLabelPath;
      procedure SetProgressBar;
      procedure AddLinesMemo2;

  protected
      procedure Execute; override;
  public
      constructor Create; overload;
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
  Resume;
end;

procedure ThreadFinder.GetDirFilesList(StartFolder: string);
  var
    SearchRec: TSearchRec;
    DirList: TStringList;
    I: Integer;
begin
  DirList := TStringList.Create;
  DirList.Add(Startfolder);
  I := 0;
  while I <= DirList.Count - 1 do
  begin

    try
    if FindFirst(ExpandFileName(DirList[I] + '\*.*'), faAnyFile, SearchRec) = 0 then
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
          FSearchStringListRezult.Add(SearchRec.Name + '   |   Путь:  ' +
          DirList[I] + '\' + SearchRec.Name);
          if not MainForm.ChkBoxHeader.Checked then
          begin
            FBufStrMemoAdd := DirList[I] + '\' + SearchRec.Name;
            Synchronize(AddLinesMemo2);
          end;
          Inc( FCountFile );
          FDirectorySearchString := DirList[I];
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
  MainForm.stat1.Panels[0].Text := FDirectorySearchString;
end;

procedure ThreadFinder.SetProgressBar;
begin
  with MainForm.ProgressBar do
  begin
    if Visible = False then
    Visible := True;
    Position := FDuplicateIterator;
  end;
end;

procedure ThreadFinder.AddLinesMemo2;
begin
  MainForm.MmoDuplicateRezult.Lines.Add(FBufStrMemoAdd);
end;

procedure ThreadFinder.Execute;
begin
  FSearchStringListRezult := TStringList.Create;
  GetDirFilesList(MainForm.DirectoryListBox1.Directory);
  if FindThread.Terminated then
  FindThread.Free;
  FSearchStringListRezult.Sort;
  GetDuplicateFiles;
  FSearchStringListRezult.Free;
  MainForm.stat1.Panels[2].Text := 'Завершен';
  MainForm.BtnStartFind.Enabled := True;
  MainForm.BtnStopFind.Visible := False;
  MainForm.BtnPlayPause.Visible := False;
  MainForm.MniStopFind.Enabled := False;
  MainForm.MniPlayPause.Enabled := False;
  MainForm.ProgressBar.Visible := False;
end;


procedure ThreadFinder.GetDuplicateFiles;
  const
    SubStr: string='   |';
  var
    J,InPosFirst,InPosNext: Integer;
    CompareStrFist, CompareStrNext: string;
begin
  if MainForm.ChkBoxHeader.Checked then
  begin
    FBufStrMemoAdd := 'Сортировка и визуализация списка найденных файлов, подождите...';
    Synchronize(AddLinesMemo2);
    FDuplicateIterator := 0;
    J := 1;
    MainForm.ProgressBar.Max := FSearchStringListRezult.Count - 1;
    while FDuplicateIterator < FSearchStringListRezult.Count - 1 do
    if FindThread.Terminated then
      Break
    else
    begin
      InPosFirst := AnsiPos(SubStr,FSearchStringListRezult[FDuplicateIterator]);
      InPosNext := AnsiPos(SubStr,FSearchStringListRezult[FDuplicateIterator + 1]);
      CompareStrFist := Copy(FSearchStringListRezult[FDuplicateIterator],1,InPosFirst - 1);
      CompareStrNext := Copy(FSearchStringListRezult[FDuplicateIterator + 1],1,InPosNext - 1);
      //First string = Next string = Duplicate
      if AnsiCompareText(CompareStrFist,CompareStrNext) = 0 then
      begin
        FBufStrMemoAdd := FSearchStringListRezult[FDuplicateIterator];
        Synchronize(AddLinesMemo2);
        FBufStrMemoAdd := FSearchStringListRezult[FDuplicateIterator + 1];
        Synchronize(AddLinesMemo2);
        J := FDuplicateIterator + 2;
        CompareStrFist := Copy(FSearchStringListRezult[FDuplicateIterator],1,InPosFirst - 1);
        CompareStrNext := Copy(FSearchStringListRezult[j],1,InPosNext - 1);
        while AnsiCompareText(CompareStrFist,CompareStrNext) = 0 do
        //Matches more than one
        begin
          FBufStrMemoAdd := FSearchStringListRezult[J];
          Synchronize(AddLinesMemo2);
          Inc( J );
          CompareStrFist := Copy(FSearchStringListRezult[FDuplicateIterator],1,InPosFirst - 1);
          CompareStrNext := Copy(FSearchStringListRezult[j],1,InPosNext - 1);
        end;
          FBufStrMemoAdd := '____________________________________________________________________________________________________';
          Synchronize(AddLinesMemo2);
          Synchronize(SetProgressBar);
      end
      else
        Synchronize(SetProgressBar);
        if FDuplicateIterator = 0 then
           FDuplicateIterator := 1
        else
        if J = 1 then
           Inc( FDuplicateIterator )
        else
        if FDuplicateIterator < J then
           FDuplicateIterator := J
        else
           Inc( FDuplicateIterator );
    end;
  end
  else
  begin
    FBufStrMemoAdd := 'Поиск Файлов по шаблону завершен.';
    Synchronize(AddLinesMemo2);
  end;
end;

end.
