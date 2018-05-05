unit PreviewDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls,
  Controls.LedMeter;

type

  { TPreviewDialog }

  TPreviewDialog = class(TForm)
    Label12: TLabel;
    PanelPreview: TPanel;
    procedure FormCreate(Sender: TObject);
  private
    LedMeter :TLedMeter;
  public

  end;

var
  PreviewDialog: TPreviewDialog;

implementation

uses
  MainDlg;

{$R *.lfm}

{ TPreviewDialog }

procedure TPreviewDialog.FormCreate(Sender: TObject);
begin
  LedMeter := MainDialog.LedMeter;
  LedMeter.Parent := PanelPreview;
  LedMeter.Align := alClient;
  LedMeter.Visible := true;
end;

end.

