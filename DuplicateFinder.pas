{------------------------------------------------------------}
{               Duplicate Finder Modul                       }
{       Copyright (c)        BChinchik                       }
{                                                            }
{       Developer:     Bogdan Chinchik                       }
{       E-mail   :     Bchinchik@ua.fm                       }
{------------------------------------------------------------}
//test remote commit to repository
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
    ChkBoxHeader: TCheckBox;
    MmoDuplicateRezult: TMemo;
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
    MniDuplicateByContent: TMenuItem;
    MniSeparator2: TMenuItem;
    MniDuplicateSelectAll: TMenuItem;
    MniSeparator1: TMenuItem;
    lbl1: TLabel;
    ChkReadOnly: TCheckBox;
    ChkHidden: TCheckBox;
    ChkSystem: TCheckBox;
    ChkArchive: TCheckBox;
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
    procedure MniDuplicateByContentClick(Sender: TObject);
    procedure MniStopFindClick(Sender: TObject);
    procedure MniPlayPauseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);


  private
    { Private declarations }
    FCurDir: string;
    FPictureGlyph: TBitmap;
    procedure MenuItmChkLstCheckUnchek(AObject: TMenuItem; BOject: TCheckListBox; NumItem: Integer);
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

  MmoDuplicateRezult.Lines.Clear;
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
  MenuItmChkLstCheckUnchek(MniDuplicateOnName,ChkLstBoxFileAttribute,0 );
end;

procedure TMainForm.MniDuplicateByContentClick(Sender: TObject);
begin
  MenuItmChkLstCheckUnchek(MniDuplicateByContent,ChkLstBoxFileAttribute,1);
end;

procedure TMainForm.MniDuplicateSelectAllClick(Sender: TObject);
begin
  if MniDuplicateSelectAll.Checked then
  begin
    MniDuplicateSelectAll.Checked := False;
    MniDuplicateOnName.Checked := False;
    MniDuplicateByContent.Checked := False;
    ChkBoxHeader.Checked := False;
    ChkLstBoxFileAttribute.Checked[0] := False;
    ChkLstBoxFileAttribute.Checked[1] := False;
    MniDuplicateSelectAll.Caption := 'Выбрать все';
  end
  else
  begin
    MniDuplicateSelectAll.Checked := True;
    MniDuplicateOnName.Checked := True;
    MniDuplicateByContent.Checked := True;
    ChkBoxHeader.Checked := True;
    ChkLstBoxFileAttribute.Checked[0] := True;
    ChkLstBoxFileAttribute.Checked[1] := True;
    MniDuplicateSelectAll.Caption := 'Снять все';
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

procedure TMainForm.MenuItmChkLstCheckUnchek(AObject: TMenuItem;
  BOject: TCheckListBox; NumItem: Integer);
begin
  if AObject.Checked = False then
  begin
    AObject.Checked := True;
    BOject.Checked[NumItem] := True;

    case NumItem of
      0 : begin
            if BOject.Checked[NumItem] = True then
            ChkBoxHeader.Checked := True;
            if BOject.Checked[1] then
            MniDuplicateSelectAll.Click;
          end;
      1:  begin
            if BOject.Checked[NumItem] = True then
            ChkBoxHeader.Checked := True;
            if BOject.Checked[0] then
            MniDuplicateSelectAll.Click;
          end;
    end;
  end
  else
  begin
    AObject.Checked := False;
    BOject.Checked[NumItem] := False;
    ChkBoxHeader.Checked := False;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FPictureGlyph.Free;
end;

end.
