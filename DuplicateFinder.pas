{------------------------------------------------------------}
{               Duplicate Finder Modul                       }
{       Copyright (c)        BChinchik                       }
{                                                            }
{       Developer:     Bogdan Chinchik                       }
{       E-mail   :     Bchinchik@ua.fm                       }
{------------------------------------------------------------}

unit DuplicateFinder;

interface

uses
  Windows, Messages, SysUtils, Variants, Classes, Graphics, Controls, Forms,
  Dialogs, StdCtrls, Buttons, FileCtrl, CheckLst, ComCtrls, Masks, ExtCtrls,
  StrUtils, ThreadDuplicateFinderModul, ActnList, ToolWin, ActnMan, ActnCtrls,
  ActnMenus, ImgList, XPStyleActnCtrls, Menus;

type
  TMainForm = class(TForm)
    BtnStartFind: TBitBtn;
    BtnStopFind: TBitBtn;
    BtnPlayPause: TBitBtn;
    Label1: TLabel;
    Label2: TLabel;
    EdtFindMask: TEdit;
    Label3: TLabel;
    DirectoryListBox1: TDirectoryListBox;
    FileListBox1: TFileListBox;
    DriveComboBox1: TDriveComboBox;
    Label4: TLabel;
    stat1: TStatusBar;
    mmo1: TMemo;
    ChkBoxHeader: TCheckBox;
    mmo2: TMemo;
    ProgressBar: TProgressBar;
    grp1:TGroupBox;
    BtnExit: TBitBtn;
    ChkLstBoxFileAttribute: TCheckListBox;
    MainMenu: TMainMenu;
    MniMenu: TMenuItem;
    MniStartFind: TMenuItem;
    MniHelp: TMenuItem;
    MniAbout: TMenuItem;
    MniDuplicateFinder: TMenuItem;
    MniStopFind: TMenuItem;
    MniPlayPause: TMenuItem;
    MniExit: TMenuItem;
    MniDuplicateOnName: TMenuItem;
    MniDuplicateReadOnly: TMenuItem;
    MniDuplicateHidden: TMenuItem;
    MniDuplicateSystem: TMenuItem;
    MniDuplicateArchive: TMenuItem;
    MniSeparator2: TMenuItem;
    MniDuplicateSelectAll: TMenuItem;
    MniSeparator1: TMenuItem;
    procedure BtnStartFindClick(Sender: TObject);
    procedure BtnStopFindClick(Sender: TObject);
    procedure BtnPlayPauseClick(Sender: TObject);
    procedure FormShow(Sender: TObject);
    procedure DirectoryListBox1Change(Sender: TObject);
    procedure BtnExitClick(Sender: TObject);
    procedure FormKeyDown(Sender: TObject; var Key: Word;
      Shift: TShiftState);
    procedure FormCloseQuery(Sender: TObject; var CanClose: Boolean);
    procedure MniExitClick(Sender: TObject);
    procedure MniStartFindClick(Sender: TObject);
    procedure MniDuplicateOnNameClick(Sender: TObject);
    procedure MniDuplicateSelectAllClick(Sender: TObject);
    procedure MniDuplicateReadOnlyClick(Sender: TObject);
    procedure MniDuplicateHiddenClick(Sender: TObject);
    procedure MniDuplicateSystemClick(Sender: TObject);
    procedure MniDuplicateArchiveClick(Sender: TObject);
    procedure MniStopFindClick(Sender: TObject);
    procedure MniPlayPauseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);


  private
    { Private declarations }
    FCurDir: string;
    FPictureGlyph: TBitmap;
    function test_check(Aobject: TCheckListBox; ACheck: Boolean): Boolean ;
  public
    { Public declarations }
  end;

var
  MainForm: TMainForm;
  FindThread: ThreadFinder;

implementation

{$R *.dfm}

procedure TMainForm.BtnStartFindClick(Sender: TObject);
begin
  mmo1.Lines.Clear;
  mmo2.Lines.Clear;
  ProgressBar.Position := 0;
  FindThread:=ThreadFinder.Create;
  BtnStartFind.Enabled := False;
  BtnStopFind.Visible := True;
  BtnPlayPause.Visible := True;
  MniStopFind.Enabled := True;
  MniPlayPause.Enabled := True;
  stat1.Panels[2].Text := 'Ждите...';
  FPictureGlyph := TBitmap.Create;
  FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_pause_blue.bmp');
  BtnPlayPause.Glyph := FPictureGlyph;

end;

procedure TMainForm.BtnStopFindClick(Sender: TObject);
begin
  FindThread.Terminate;
  BtnStartFind.Enabled := True;
  BtnStopFind.Visible := False;
  BtnPlayPause.Visible := False;
  MniStopFind.Enabled := False;
  MniPlayPause.Enabled := False;
  stat1.Panels[2].Text := 'Отменен';

end;

procedure TMainForm.BtnPlayPauseClick(Sender: TObject);
begin
  if FindThread.Suspended then
  begin
    FindThread.Resume;
    BtnPlayPause.Caption := 'Приостановить';
    FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_pause_blue.bmp');
    BtnPlayPause.Glyph := FPictureGlyph;
    MniPlayPause.Caption := 'Приостановить';
    MniPlayPause.Bitmap := FPictureGlyph;
  end
  else
  begin
    FindThread.Suspend;
    BtnPlayPause.Caption := 'Возобновить  ';
    FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_play_blue.bmp');
    BtnPlayPause.Glyph := FPictureGlyph;
    MniPlayPause.Caption := 'Возобновить';
    MniPlayPause.Bitmap := FPictureGlyph;
  end;
end;

procedure TMainForm.FormShow(Sender: TObject);
begin
  Label4.Caption := DirectoryListBox1.Directory;
  stat1.Panels[0].Text := DirectoryListBox1.Directory;
  FCurDir := GetCurrentDir;
end;

procedure TMainForm.DirectoryListBox1Change(Sender: TObject);
begin
  Label4.Caption := DirectoryListBox1.Directory;
  stat1.Panels[0].Text := DirectoryListBox1.Directory;
end;

procedure TMainForm.BtnExitClick(Sender: TObject);
begin
  Close;
end;

procedure TMainForm.FormKeyDown(Sender: TObject; var Key: Word;
  Shift: TShiftState);
begin
  if Key=VK_ESCAPE then
    Close;
end;

procedure TMainForm.FormCloseQuery(Sender: TObject;
  var CanClose: Boolean);
begin
  if MessageDlg('Закрыть программу?',mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
  CanClose := False;
end;

procedure TMainForm.MniExitClick(Sender: TObject);
begin
  BtnExit.Click;
end;

procedure TMainForm.MniStartFindClick(Sender: TObject);
begin
  BtnStartFind.Click;
end;

procedure TMainForm.MniDuplicateOnNameClick(Sender: TObject);
begin
  if MniDuplicateOnName.Checked then
  begin
    MniDuplicateOnName.Checked := False;
    ChkLstBoxFileAttribute.Checked[0] := False;
      if ((ChkLstBoxFileAttribute.Checked[1] = False)
        and(ChkLstBoxFileAttribute.Checked[2] = False)
        and(ChkLstBoxFileAttribute.Checked[3] = False)
        and(ChkLstBoxFileAttribute.Checked[4] = False))
      then
         ChkBoxHeader.Checked := False;
  end
  else
  begin
    MniDuplicateOnName.Checked := True;
    ChkLstBoxFileAttribute.Checked[0] := True;
    ChkBoxHeader.Checked := True;
  end;
end;

procedure TMainForm.MniDuplicateSelectAllClick(Sender: TObject);
begin
  if MniDuplicateSelectAll.Checked then
  begin
    MniDuplicateSelectAll.Checked := False;
    MniDuplicateOnName.Checked := False;
    MniDuplicateReadOnly.Checked := False;
    MniDuplicateHidden.Checked := False;
    MniDuplicateSystem.Checked := False;
    MniDuplicateArchive.Checked := False;
    ChkBoxHeader.Checked := False;
    ChkLstBoxFileAttribute.Checked[0] := False;
    ChkLstBoxFileAttribute.Checked[1] := False;
    ChkLstBoxFileAttribute.Checked[2] := False;
    ChkLstBoxFileAttribute.Checked[3] := False;
    ChkLstBoxFileAttribute.Checked[4] := False;
    MniDuplicateSelectAll.Caption := 'Выбрать все';
  end
  else
  begin
    MniDuplicateSelectAll.Checked := True;
    MniDuplicateOnName.Checked := True;
    MniDuplicateReadOnly.Checked := True;
    MniDuplicateHidden.Checked := True;
    MniDuplicateSystem.Checked := True;
    MniDuplicateArchive.Checked := True;
    ChkBoxHeader.Checked := True;
    ChkLstBoxFileAttribute.Checked[0] := True;
    ChkLstBoxFileAttribute.Checked[1] := True;
    ChkLstBoxFileAttribute.Checked[2] := True;
    ChkLstBoxFileAttribute.Checked[3] := True;
    ChkLstBoxFileAttribute.Checked[4] := True;
    MniDuplicateSelectAll.Caption := 'Снять все';
  end;
end;

procedure TMainForm.MniDuplicateReadOnlyClick(Sender: TObject);
begin
  if MniDuplicateReadOnly.Checked then
  begin
    MniDuplicateReadOnly.Checked := False;
    ChkLstBoxFileAttribute.Checked[1] := False;
    if ((ChkLstBoxFileAttribute.Checked[0] = False)
      and(ChkLstBoxFileAttribute.Checked[2] = False)
      and(ChkLstBoxFileAttribute.Checked[3] = False)
      and(ChkLstBoxFileAttribute.Checked[4] = False))
    then
      ChkBoxHeader.Checked := False;
  end
  else
  begin
    MniDuplicateReadOnly.Checked := True;
    ChkLstBoxFileAttribute.Checked[1] := True;
    ChkBoxHeader.Checked := True;
  end;
end;

procedure TMainForm.MniDuplicateHiddenClick(Sender: TObject);
begin
  if MniDuplicateHidden.Checked then
  begin
   MniDuplicateHidden.Checked := False;
   ChkLstBoxFileAttribute.Checked[2] := False;
    if ((ChkLstBoxFileAttribute.Checked[0] = False)
      and(ChkLstBoxFileAttribute.Checked[1] = False)
      and(ChkLstBoxFileAttribute.Checked[3] = False)
      and(ChkLstBoxFileAttribute.Checked[4] = False))
    then
      ChkBoxHeader.Checked := False;
  end
  else
  begin
    MniDuplicateHidden.Checked := True;
    ChkLstBoxFileAttribute.Checked[2] := True;
    ChkBoxHeader.Checked := True;
  end;
end;

procedure TMainForm.MniDuplicateSystemClick(Sender: TObject);
begin
  if MniDuplicateSystem.Checked then
  begin
    MniDuplicateSystem.Checked := False;
    ChkLstBoxFileAttribute.Checked[3] := False;
    if ((ChkLstBoxFileAttribute.Checked[0] = False)
      and(ChkLstBoxFileAttribute.Checked[1] = False)
      and(ChkLstBoxFileAttribute.Checked[2] = False)
      and(ChkLstBoxFileAttribute.Checked[4] = False))
    then
      ChkBoxHeader.Checked := False;
  end
  else
  begin
    MniDuplicateSystem.Checked := True;
    ChkLstBoxFileAttribute.Checked[3] := True;
    ChkBoxHeader.Checked := True;
  end;
end;

procedure TMainForm.MniDuplicateArchiveClick(Sender: TObject);
begin
  if MniDuplicateArchive.Checked then
  begin
    MniDuplicateArchive.Checked := False;
    ChkLstBoxFileAttribute.Checked[4] := False;
    if ((ChkLstBoxFileAttribute.Checked[0] = False)
      and(ChkLstBoxFileAttribute.Checked[1] = False)
      and(ChkLstBoxFileAttribute.Checked[2] = False)
      and(ChkLstBoxFileAttribute.Checked[3] = False))
    then
      ChkBoxHeader.Checked := False;
    end
  else
  begin
    MniDuplicateArchive.Checked := True;
    ChkLstBoxFileAttribute.Checked[4] := True;
    ChkBoxHeader.Checked := True;
  end;
end;

procedure TMainForm.MniStopFindClick(Sender: TObject);
begin
  BtnStopFind.Click;
end;

procedure TMainForm.MniPlayPauseClick(Sender: TObject);
begin
  BtnPlayPause.Click;

end;

function TMainForm.test_check(Aobject: TCheckListBox;
  ACheck: Boolean): Boolean;
begin
  Aobject.Checked[4] := False;
  Aobject.Checked[4] := False;
    if ((ChkLstBoxFileAttribute.Checked[0] = False)
      and(ChkLstBoxFileAttribute.Checked[1] = False)
      and(ChkLstBoxFileAttribute.Checked[2] = False)
      and(ChkLstBoxFileAttribute.Checked[3] = False))
    then
      ChkBoxHeader.Checked := False;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FPictureGlyph.Free;
end;



end.
