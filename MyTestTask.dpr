program MyTestTask;

uses
  Forms,
  DuplicateFinder in 'DuplicateFinder.pas' {MainForm},
  ThreadDuplicateFinderModul in 'ThreadDuplicateFinderModul.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TMainForm, MainForm);
  Application.Run;
end.
