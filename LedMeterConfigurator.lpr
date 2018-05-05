program LedMeterConfigurator;

{$mode objfpc}{$H+}

uses
  {$IFDEF UNIX}{$IFDEF UseCThreads}
  cthreads,
  {$ENDIF}{$ENDIF}
  Interfaces, // this includes the LCL widgetset
  Forms, MainDlg, PreviewDlg
  { you can add units after this };

{$R *.res}

begin
  RequireDerivedFormResource:=True;
  Application.Initialize;
  Application.CreateForm(TMainDialog, MainDialog);
  Application.CreateForm(TPreviewDialog, PreviewDialog);
  Application.Run;
end.

