unit MainDlg;

{$mode objfpc}{$H+}

interface

uses
  Classes, SysUtils, FileUtil, Forms, Controls, Graphics, Dialogs, ExtCtrls, StdCtrls, Controls.LedMeter;

type

  { TMainDialog }

  TMainDialog = class(TForm)
    CheckBoxHorizontal: TCheckBox;
    PanelLm1: TPanel;
    procedure CheckBoxHorizontalClick(Sender: TObject);
    procedure FormCreate(Sender: TObject);
  private
    lm :TLedMeter;
    procedure Changed;
  public

  end;

var
  MainDialog: TMainDialog;

implementation

{$R *.lfm}

{ TMainDialog }

procedure TMainDialog.FormCreate(Sender: TObject);
begin
  lm := TLedMeter.Create(self);
  lm.Parent := PanelLm1;
  lm.Visible := true;
  Changed;
end;

procedure TMainDialog.CheckBoxHorizontalClick(Sender: TObject);
begin
  Changed;
end;

procedure TMainDialog.Changed;
begin
  if CheckBoxHorizontal.Checked then begin
    lm.Orientation := loHorizontal;
    lm.Align := alClient;
    lm.Height := 100;
  end else begin
    lm.Orientation := loVertical;
    lm.Align := alClient;
    lm.Width := 100;
  end;
  lm.GapSize := 4;
  lm.SegmentSize := 0;
  lm.BarCount := 10;
  lm.Min := 0;
end;

end.

