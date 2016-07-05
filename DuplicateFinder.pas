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
    ChkBoxHeader: TCheckBox;
    MmoDuplicateRezult: TMemo;
    ProgressBar: TProgressBar;
    grp1:TGroupBox;
    BtnExit: TBitBtn;
    ChkLstBoxFindCriteria: TCheckListBox;
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
    MniDuplicateBySize: TMenuItem;
    MniDuplicateByDate: TMenuItem;
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
    procedure MniDuplicateBySizeClick(Sender: TObject);
    procedure MniStopFindClick(Sender: TObject);
    procedure MniPlayPauseClick(Sender: TObject);
    procedure FormDestroy(Sender: TObject);
    procedure MniAboutClick(Sender: TObject);
    procedure MniDuplicateByDateClick(Sender: TObject);
  private
    { Private declarations }
    FCurDir: string;
    FPictureGlyph: TBitmap;
    FindThread: ThreadFinder;
    procedure ReceiverMemoSent(Sender: TObject; AddLine: String);
    procedure FMenuItmChkLstCheckUnchek(AObject: TMenuItem; BOject: TCheckListBox; CheckHeader: TCheckBox; NumItem: Integer);
    function  FGetFindCriteria: Integer;
 public
    { Public declarations }
    property FindCriteria: Integer read FGetFindCriteria;
    procedure ThreadOnTerminate(Sender: TObject);
 end;

var
  MainForm: TMainForm;

implementation

{$R *.dfm}

procedure TMainForm.BtnStartFindClick(Sender: TObject);
begin

  MmoDuplicateRezult.Lines.Clear;
  ProgressBar.Position := 0;
  //ShowMessage(IntToStr(FindCriteria));
  FindThread:=ThreadFinder.Create(DirectoryListBox1.Directory,FindCriteria);
  FindThread.OnTerminate := ThreadOnTerminate;
  FindThread.OnMemoSent :=  ReceiverMemoSent;
  FindThread.Resume;
  BtnStartFind.Enabled := False;
  BtnStopFind.Visible := True;
  BtnPlayPause.Visible := True;
  MniStopFind.Enabled := True;
  MniPlayPause.Enabled := True;
  stat1.Panels[2].Text := '�����...';
  FPictureGlyph := TBitmap.Create;
  FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_pause_blue.bmp');
  BtnPlayPause.Glyph := FPictureGlyph;

end;

procedure TMainForm.BtnStopFindClick(Sender: TObject);
begin
  FindThread.Terminate;
  MmoDuplicateRezult.Lines.Clear;
  ProgressBar.Visible := False;
  BtnStartFind.Enabled := True;
  BtnStopFind.Visible := False;
  BtnPlayPause.Visible := False;
  MniStopFind.Enabled := False;
  MniPlayPause.Enabled := False;
  stat1.Panels[2].Text := '�������';
  BtnPlayPause.Caption := '�������������';
  FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_pause_blue.bmp');
  BtnPlayPause.Glyph := FPictureGlyph;
  MniPlayPause.Caption := '�������������';
  MniPlayPause.Bitmap := FPictureGlyph;
end;

procedure TMainForm.BtnPlayPauseClick(Sender: TObject);
begin
  if FindThread.Suspended then
  begin
    FindThread.Resume;
    BtnPlayPause.Caption := '�������������';
    FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_pause_blue.bmp');
    BtnPlayPause.Glyph := FPictureGlyph;
    MniPlayPause.Caption := '�������������';
    MniPlayPause.Bitmap := FPictureGlyph;
  end
  else
  begin
    FindThread.Suspend;
    BtnPlayPause.Caption := '�����������  ';
    FPictureGlyph.LoadFromFile(FCurDir+'\icons\control_play_blue.bmp');
    BtnPlayPause.Glyph := FPictureGlyph;
    MniPlayPause.Caption := '�����������';
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
  if MessageDlg('������� ���������?',mtConfirmation, [mbOk, mbCancel], 0) = mrCancel then
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
  FMenuItmChkLstCheckUnchek(MniDuplicateOnName,ChkLstBoxFindCriteria,ChkBoxHeader,0 );
end;

procedure TMainForm.MniDuplicateBySizeClick(Sender: TObject);
begin
  FMenuItmChkLstCheckUnchek(MniDuplicateBySize,ChkLstBoxFindCriteria,ChkBoxHeader,1);
end;
procedure TMainForm.MniDuplicateByDateClick(Sender: TObject);
begin
  FMenuItmChkLstCheckUnchek(MniDuplicateByDate,ChkLstBoxFindCriteria,ChkBoxHeader,2);
end;

procedure TMainForm.MniDuplicateSelectAllClick(Sender: TObject);
begin
  if MniDuplicateSelectAll.Checked then
  begin
    MniDuplicateSelectAll.Checked := False;
    MniDuplicateOnName.Checked := False;
    MniDuplicateBySize.Checked := False;
    MniDuplicateByDate.Checked := False;
    ChkBoxHeader.Checked := False;
    ChkLstBoxFindCriteria.Checked[0] := False;
    ChkLstBoxFindCriteria.Checked[1] := False;
    ChkLstBoxFindCriteria.Checked[2] := False;
    MniDuplicateSelectAll.Caption := '������� ���';
  end
  else
  begin
    MniDuplicateSelectAll.Checked := True;
    MniDuplicateOnName.Checked := True;
    MniDuplicateBySize.Checked := True;
    MniDuplicateByDate.Checked := True;
    ChkBoxHeader.Checked := True;
    ChkLstBoxFindCriteria.Checked[0] := True;
    ChkLstBoxFindCriteria.Checked[1] := True;
    ChkLstBoxFindCriteria.Checked[2] := True;
    MniDuplicateSelectAll.Caption := '����� ���';
  end;
end;

procedure TMainForm.MniStopFindClick(Sender: TObject);
begin
  BtnStopFind.Click;
end;

procedure TMainForm.ReceiverMemoSent(Sender: TObject; AddLine: String);
begin
   MainForm.MmoDuplicateRezult.Lines.Add(AddLine);
end;

procedure TMainForm.MniPlayPauseClick(Sender: TObject);
begin
  BtnPlayPause.Click;
end;

procedure TMainForm.FMenuItmChkLstCheckUnchek(AObject: TMenuItem;
  BOject: TCheckListBox; CheckHeader: TCheckBox; NumItem: Integer);
begin
  if AObject.Checked = False then
  begin
    AObject.Checked := True;
    BOject.Checked[NumItem] := True;
    CheckHeader.Checked := True;
    case NumItem of
      0 : if (BOject.Checked[1])or(BOject.Checked[2]) then
            begin
              MniDuplicateSelectAll.Checked := True;
              MniDuplicateSelectAll.Caption := '����� ���';
            end;

      1:  if (BOject.Checked[0])or(BOject.Checked[2]) then
            begin
              MniDuplicateSelectAll.Checked := True;
              MniDuplicateSelectAll.Caption := '����� ���';
            end;
      2:  if (BOject.Checked[0])or(BOject.Checked[1]) then
            begin
              MniDuplicateSelectAll.Checked := True;
              MniDuplicateSelectAll.Caption := '����� ���';
            end;

    end;
  end

  else
  begin
    AObject.Checked := False;
    BOject.Checked[NumItem] := False;
   // ChkBoxHeader.Checked := False;
   case NumItem of
      0 : if not((BOject.Checked[1])or(BOject.Checked[2])) then
            begin
              CheckHeader.Checked := False;
              MniDuplicateSelectAll.Checked := False;
              MniDuplicateSelectAll.Caption := '������� ���';
            end;
      1:  if not((BOject.Checked[0])or(BOject.Checked[2])) then
            begin
              CheckHeader.Checked := False;
              MniDuplicateSelectAll.Checked := False;
              MniDuplicateSelectAll.Caption := '������� ���';
            end;
      2:  if not((BOject.Checked[0])or(BOject.Checked[1])) then
            begin
              CheckHeader.Checked := False;
              MniDuplicateSelectAll.Checked := False;
              MniDuplicateSelectAll.Caption := '������� ���';
            end;


    end;
  end;
end;

procedure TMainForm.FormDestroy(Sender: TObject);
begin
  FPictureGlyph.Free;
end;

procedure TMainForm.MniAboutClick(Sender: TObject);
begin
 MessageDlg('Duplicate Finder Modul'+#13#10+'Copyright (c)   BChinchik'+
  #13#10+'Developer:        Bogdan Chinchik'+#13#10+
  'E-mail   :           Bchinchik@ua.fm',mtCustom,[mbOK],0)
end;



function TMainForm.FGetFindCriteria: Integer;
begin
 if ChkLstBoxFindCriteria.Checked[0] and (not(ChkLstBoxFindCriteria.Checked[1])) and (not(ChkLstBoxFindCriteria.Checked[2]))  then Result := 1;
 if ChkLstBoxFindCriteria.Checked[1] and (not(ChkLstBoxFindCriteria.Checked[0])) and (not(ChkLstBoxFindCriteria.Checked[2]))  then Result := 2;
 if ChkLstBoxFindCriteria.Checked[2] and (not(ChkLstBoxFindCriteria.Checked[0])) and (not(ChkLstBoxFindCriteria.Checked[1]))  then Result := 3;
 if ChkLstBoxFindCriteria.Checked[0] and ((ChkLstBoxFindCriteria.Checked[1])) and (not(ChkLstBoxFindCriteria.Checked[2]))  then Result := 4;
 if ChkLstBoxFindCriteria.Checked[0] and (not(ChkLstBoxFindCriteria.Checked[1])) and ((ChkLstBoxFindCriteria.Checked[2]))  then Result := 5;
 if ChkLstBoxFindCriteria.Checked[1] and ((ChkLstBoxFindCriteria.Checked[2])) and (not(ChkLstBoxFindCriteria.Checked[0]))  then Result := 6;
 if ChkLstBoxFindCriteria.Checked[0] and ((ChkLstBoxFindCriteria.Checked[1])) and ((ChkLstBoxFindCriteria.Checked[2]))  then Result := 7;

end;



procedure TMainForm.ThreadOnTerminate(Sender: TObject);
begin
  MainForm.stat1.Panels[2].Text := '��������';
  MainForm.BtnStartFind.Enabled := True;
  MainForm.BtnStopFind.Visible := False;
  MainForm.BtnPlayPause.Visible := False;
  MainForm.MniStopFind.Enabled := False;
  MainForm.MniPlayPause.Enabled := False;
  MainForm.ProgressBar.Visible := False;

end;

end.
