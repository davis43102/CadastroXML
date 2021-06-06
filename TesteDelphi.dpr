program TesteDelphi;

uses
  System.StartUpCopy,
  FMX.Forms,
  View.Main in 'View\View.Main.pas' {frmMain},
  uFormat in 'Commons\uFormat.pas',
  USendEmail in 'Commons\USendEmail.pas',
  UCEP in 'Commons\UCEP.pas';

{$R *.res}

begin
  Application.Initialize;
  Application.CreateForm(TfrmMain, frmMain);
  Application.Run;
end.
