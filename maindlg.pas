unit MainDlg;

{$mode objfpc}{$H+}

interface

uses
  LCLType, Classes, SysUtils, FileUtil, SynEdit, SynHighlighterPas, Forms, Controls, Graphics, Dialogs, ExtCtrls,
  StdCtrls, ComCtrls, Controls.LedMeter, Types, Clipbrd;

type

  { TMainDialog }

  TMainDialog = class(TForm)
    ButtonCopy: TButton;
    ButtonSimpleScheme: TButton;
    ButtonSoundScheme: TButton;
    ButtonRainbowScheme: TButton;
    ButtonSinus: TButton;
    ButtonRamp: TButton;
    ButtonAddColorNode: TButton;
    ButtonDelColorNode: TButton;
    CheckBoxAutoZero: TCheckBox;
    ColorDialog: TColorDialog;
    EditAutoZeroInterval: TEdit;
    EditCode: TSynEdit;
    EditLevel: TEdit;
    EditMinLevel: TEdit;
    EditColorNodeLevel: TEdit;
    EditBarcount: TEdit;
    EditSegmentSize: TEdit;
    EditGapSize: TEdit;
    GroupBoxBars: TGroupBox;
    GroupBoxCode: TGroupBox;
    GroupBoxLevel: TGroupBox;
    GroupBoxStyle: TGroupBox;
    GroupBoxColorNodes: TGroupBox;
    GroupBoxOrientation: TGroupBox;
    Label1: TLabel;
    Label10: TLabel;
    Label11: TLabel;
    Label2: TLabel;
    Label3: TLabel;
    Label4: TLabel;
    Label5: TLabel;
    Label6: TLabel;
    Label7: TLabel;
    Label8: TLabel;
    ListBoxColorNodes: TListBox;
    PanelColorOn: TPanel;
    PanelColorOff: TPanel;
    PanelControls: TPanel;
    PascalSyntax: TSynPasSyn;
    RadioButtonHorizontal: TRadioButton;
    RadioButtonBiDirectional: TRadioButton;
    RadioButtonVertical: TRadioButton;
    RadioButtonNormal: TRadioButton;
    procedure Button1Click(Sender: TObject);
    procedure ButtonCopyClick(Sender: TObject);
    procedure ButtonRainbowSchemeClick(Sender: TObject);
    procedure ButtonSimpleSchemeClick(Sender: TObject);
    procedure ButtonSinusClick(Sender: TObject);
    procedure ButtonAddColorNodeClick(Sender: TObject);
    procedure ButtonDelColorNodeClick(Sender: TObject);
    procedure ButtonRampClick(Sender: TObject);
    procedure ButtonSoundSchemeClick(Sender: TObject);
    procedure CheckBoxAutoZeroClick(Sender: TObject);
    procedure CheckBoxHorizontalClick(Sender: TObject);
    procedure EditAutoZeroIntervalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditBarcountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditGapSizeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditLevelChange(Sender: TObject);
    procedure EditColorNodeLevelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditMinLevelChange(Sender: TObject);
    procedure EditMinLevelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure EditSegmentSizeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
    procedure FormCreate(Sender: TObject);
    procedure ListBoxColorNodesClick(Sender: TObject);
    procedure ListBoxColorNodesDrawItem(Control: TWinControl; Index: Integer; ARect: TRect; State: TOwnerDrawState);
    procedure PanelColorOnClick(Sender: TObject);
    procedure RadioButtonNormalClick(Sender: TObject);
    procedure RadioButtonVerticalClick(Sender: TObject);
  private
    procedure ObjectToDialog;
    function LevelToString(AValue :single) :string;
    procedure OnObjectChanged(Sender :TObject);
    procedure OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
    procedure OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
  public
    LedMeter :TLedMeter;
  end;

var
  MainDialog: TMainDialog;

implementation

{$R *.lfm}

const
  CODETEMPLATE =
    'with LedMeter do begin' + #13#10 +
    '  BarCount           := %BARCOUNT%;' + #13#10 +
    '  MinLevel           := %MINLEVEL%;' + #13#10 +
    '  SegmentSize        := %SEGMENTSIZE%;' + #13#10 +
    '  GapSize            := %GAPSIZE%;' + #13#10 +
    '  Style              := %STYLE%;' + #13#10 +
    '  Orientation        := %ORIENTATION%;' + #13#10 +
    '  AutoZero           := %AUTOZERO%;' + #13#10 +
    '  AutoZeroInterval   := %AUTOZEROINTERVAL%;' + #13#10 +
    '  ColorNodes.Clear;' + #13#10 +
    '%COLORNODES%' +
    'end;' + #13#10;

function BuildCode(Control :TLedMeter): string;
var
  Code :string;
  Frag :string;
  CodeFormatSettings :TFormatSettings;
  i :integer;

  procedure ReplaceFloat(const Variable :string; Value :single);
  begin
    Code := StringReplace(Code, Variable, Format('%.2f', [Value], CodeFormatSettings), []);
  end;

  procedure ReplaceInteger(const Variable :string; Value :integer);
  begin
    Code := StringReplace(Code, Variable, Format('%d', [Value]), []);
  end;

  procedure ReplaceBoolean(const Variable :string; Value :boolean);
  const
    FALSETRUE :array[boolean] of string = ('false', 'true');
  begin
    Code := StringReplace(Code, Variable, FALSETRUE[Value], []);
  end;

  procedure ReplaceStyle(const Variable :string; Value :TLedMeter.TStyle);
  const
    STYLES :array[TLedMeter.TStyle] of string = ('lsNormal', 'lsiDirectional');
  begin
    Code := StringReplace(Code, Variable, STYLES[Value], []);
  end;

  procedure ReplaceOrientation(const Variable :string; Value :TLedMeter.TOrientation);
  const
    ORIENTATIONS :array[TLedMeter.TOrientation] of string = ('loVertical', 'loHorizontal');
  begin
    Code := StringReplace(Code, Variable, ORIENTATIONS[Value], []);
  end;

begin
  CodeFormatSettings := DefaultFormatSettings;
  CodeFormatSettings.DecimalSeparator := '.';

  Code := CODETEMPLATE;
  ReplaceInteger('%BARCOUNT%', Control.BarCount);
  ReplaceFloat('%MINLEVEL%', Control.MinLevel);
  ReplaceInteger('%SEGMENTSIZE%', Control.SegmentSize);
  ReplaceInteger('%GAPSIZE%', Control.GapSize);
  ReplaceStyle('%STYLE%', Control.Style);
  ReplaceOrientation('%ORIENTATION%', Control.Orientation);
  ReplaceBoolean('%AUTOZERO%', Control.AutoZero);
  ReplaceInteger('%AUTOZEROINTERVAL%', Control.AutoZeroInterval);

  Frag := '';
  for i:=0 to Control.ColorNodes.Count-1 do begin
    Frag := Frag + '  with ColorNodes.Add as TColorNode do begin' + #13#10 +
      Format('    OnColor := $%6.6x;'+#13#10+'    OffColor := $%6.6x;'+#13#10+'    Level := %.2f;'+#13#10,
        [Control.ColorNodes[i].OnColor, Control.ColorNodes[i].OffColor, Control.ColorNodes[i].Level], CodeFormatSettings) +
      '  end;' + #13#10;
  end;
  Code := StringReplace(Code, '%COLORNODES%', Frag, []);

  result := Code;

end;

{ TMainDialog }

procedure TMainDialog.FormCreate(Sender: TObject);
begin
  LedMeter := TLedMeter.Create(self);
  LedMeter.Align := alClient;
  LedMeter.OnChange := @OnObjectChanged;
  LedMeter.BorderSpacing.Around := 10;
  LedMeter.OnMouseDown := @OnMouseDown;
  LedMeter.OnMouseMove := @OnMouseMove;
  ObjectToDialog;
end;

procedure TMainDialog.ListBoxColorNodesClick(Sender: TObject);
var
  i :integer;
begin
  i := ListBoxColorNodes.ItemIndex;
  EditColorNodeLevel.Text := LevelToString(LedMeter.ColorNodes[i].Level);
  PanelColorOn.Color := LedMeter.ColorNodes[i].OnColor;
  PanelColorOff.Color := LedMeter.ColorNodes[i].OffColor;
end;

procedure TMainDialog.ListBoxColorNodesDrawItem(Control: TWinControl; Index: Integer; ARect: TRect;
  State: TOwnerDrawState);
var
  ts :TTextStyle;
begin
  with ListBoxColorNodes.Canvas do begin
//    Brush.Color := ListBoxColorNodes.Color;
    FillRect(ARect);
    ts.Alignment := taLeftJustify;
    ts.Layout := tlCenter;
    ts.Clipping := false;
    ts.EndEllipsis := false;
    ts.ExpandTabs := false;
    ts.Opaque := false;
    ts.RightToLeft := false;
    ts.ShowPrefix := false;
    ts.SingleLine := false;
    ts.SystemFont := false;
    ts.Wordbreak := false;
    TextRect(ARect, 2, 0, LevelToString(LedMeter.ColorNodes[Index].Level), ts);
    Pen.Color := clAqua;
    Pen.Mode := pmNot;
    Pen.Style := psDot;
    FrameRect(ARect);
    ARect.Left := ARect.Right - 2*ARect.Height;
    InflateRect(ARect, -2, -2);
    Brush.Color := LedMeter.ColorNodes[Index].OnColor;
    FillRect(ARect);
  end;
end;

procedure TMainDialog.PanelColorOnClick(Sender: TObject);
var
  i :integer;
begin
  i := ListBoxColorNodes.ItemIndex;
  if i<>-1 then begin
    ColorDialog.Color := LedMeter.ColorNodes[i].OnColor;
    if ColorDialog.Execute then begin
      LedMeter.ColorNodes[i].OnColor := ColorDialog.Color;
    end;
  end;
end;

procedure TMainDialog.RadioButtonNormalClick(Sender: TObject);
begin
  if RadioButtonNormal.Checked then
    LedMeter.Style := lsNormal
  else
    LedMeter.Style := lsBidirectional;
end;

procedure TMainDialog.RadioButtonVerticalClick(Sender: TObject);
begin
  if RadioButtonVertical.Checked then
    LedMeter.Orientation := loVertical
  else
    LedMeter.Orientation := loHorizontal;
end;

procedure TMainDialog.CheckBoxHorizontalClick(Sender: TObject);
begin
end;

procedure TMainDialog.EditAutoZeroIntervalKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    Key := 0;
    LedMeter.AutoZeroInterval := StrToInt(EditAutoZeroInterval.Text);
  end;
end;

procedure TMainDialog.ButtonAddColorNodeClick(Sender: TObject);
begin
  with LedMeter.ColorNodes.Add as TColorNode do begin
    Level := LedMeter.ColorNodes[LedMeter.ColorNodes.Count-2].Level + 10.0;
    Color := clRed;
    ListBoxColorNodes.ItemIndex := LedMeter.ColorNodes.Count-1;
    ListBoxColorNodesClick(nil);
  end;
end;

procedure TMainDialog.ButtonDelColorNodeClick(Sender: TObject);
var
  i :integer;
begin
  if (LedMeter.ColorNodes.Count>1) then begin
    i := ListBoxColorNodes.ItemIndex;
    if i=-1 then i := LedMeter.ColorNodes.Count-1;
    LedMeter.ColorNodes.Items[i].Free;
  end;
end;

procedure TMainDialog.ButtonRampClick(Sender: TObject);
var
  i :integer;
begin
  for i:=0 to LedMeter.BarCount-1 do
    LedMeter.Levels[i] := LedMeter.MinLevel + (LedMeter.BarCount-i)*LedMeter.Range/LedMeter.BarCount;
end;

procedure TMainDialog.ButtonSoundSchemeClick(Sender: TObject);
begin
  LedMeter.SetColorScheme(lcsSound);
end;

procedure TMainDialog.CheckBoxAutoZeroClick(Sender: TObject);
begin
  LedMeter.AutoZero := CheckBoxAutoZero.Checked;
end;

procedure TMainDialog.ButtonSinusClick(Sender: TObject);
var
  i :integer;
begin
  if LedMeter.Style=lsNormal then
    for i:=0 to LedMeter.BarCount-1 do
      LedMeter.Levels[i] := LedMeter.MinLevel+LedMeter.Range/2.0+sin(2*PI*i/LedMeter.BarCount)*LedMeter.Range/2.0
  else
    for i:=0 to LedMeter.BarCount-1 do
      LedMeter.Levels[i] := sin(2*PI*i/LedMeter.BarCount)*LedMeter.Range/2.0;
end;

procedure TMainDialog.ButtonSimpleSchemeClick(Sender: TObject);
begin
  LedMeter.SetColorScheme(lcsSimple);
end;

procedure TMainDialog.ButtonRainbowSchemeClick(Sender: TObject);
begin
  LedMeter.SetColorScheme(lcsRainbow);
end;

procedure TMainDialog.Button1Click(Sender: TObject);
begin

end;

procedure TMainDialog.ButtonCopyClick(Sender: TObject);
begin
  Clipboard.AsText := EditCode.Lines.Text;
end;

procedure TMainDialog.EditBarcountKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    Key := 0;
    LedMeter.BarCount := StrToInt(EditBarCount.Text);
  end;
end;

procedure TMainDialog.EditGapSizeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    Key := 0;
    LedMeter.GapSize := StrToInt(EditGapSize.Text);
  end;
end;

procedure TMainDialog.EditLevelChange(Sender: TObject);
begin
end;

procedure TMainDialog.EditColorNodeLevelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
var
  f :single;
begin
  if Key=VK_RETURN then begin
    Key := 0;
    if TryStrToFloat(EditColorNodeLevel.Text, f) and (ListBoxColorNodes.ItemIndex<>-1) then begin
      LedMeter.ColorNodes[ListBoxColorNodes.ItemIndex].Level := f;
    end;
  end;
end;

procedure TMainDialog.EditMinLevelChange(Sender: TObject);
begin
end;

procedure TMainDialog.EditMinLevelKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    Key := 0;
    LedMeter.MinLevel := StrToFloat(EditMinLevel.Text);
  end;
end;

procedure TMainDialog.EditSegmentSizeKeyDown(Sender: TObject; var Key: Word; Shift: TShiftState);
begin
  if Key=VK_RETURN then begin
    Key := 0;
    LedMeter.SegmentSize := StrToInt(EditSegmentSize.Text);
  end;
end;

procedure TMainDialog.ObjectToDialog;
var
  i, ItemIndex :integer;
begin
  with LedMeter do begin
    EditBarCount.Text := IntToStr(BarCount);
    RadioButtonHorizontal.Checked := Orientation = loHorizontal;
    RadioButtonVertical.Checked := Orientation = loVertical;
    ItemIndex := ListBoxColorNodes.ItemIndex;
    ListBoxColorNodes.Items.Clear;
    for i:=0 to ColorNodes.Count-1 do
      ListBoxColorNodes.Items.Add(LevelToString(ColorNodes[i].Level));
    if ItemIndex>=ListBoxColorNodes.Items.Count then begin
      ItemIndex := ListBoxColorNodes.Items.Count-1;
    end;
    if ItemIndex<>-1 then begin
      PanelColorOn.Color := LedMeter.ColorNodes[ItemIndex].OnColor;
      PanelColorOff.Color := LedMeter.ColorNodes[ItemIndex].OffColor;
    end else begin
      PanelColorOn.Color := clBtnFace;
      PanelColorOff.Color := clBtnFace;
    end;
    EditMinLevel.Text := LevelToString(MinLevel);
    EditSegmentSize.Text := IntToStr(SegmentSize);
    EditGapSize.Text := IntToStr(GapSize);
    RadioButtonNormal.Checked := Style = lsNormal;
    RadioButtonBiDirectional.Checked := Style = lsBiDirectional;
    EditLevel.Text := LevelToString(LedMeter.Level);
    CheckBoxAutoZero.Checked := AutoZero;
    EditAutoZeroInterval.Text := IntToStr(LedMeter.AutoZeroInterval);
    EditCode.Text := BuildCode(LedMeter);
  end;


end;

function TMainDialog.LevelToString(AValue: single): string;
begin
  result := Format('%.2f', [AValue]);
end;

procedure TMainDialog.OnObjectChanged(Sender: TObject);
begin
  ObjectToDialog;
end;

procedure TMainDialog.OnMouseDown(Sender: TObject; Button: TMouseButton; Shift: TShiftState; X, Y: Integer);
var
  Row, Col :integer;
  Level :single;
begin
  if LedMeter.ItemAt(X, Y, Col, Row, Level) then begin
    LedMeter.Levels[Col] := Level;
  end;
end;

procedure TMainDialog.OnMouseMove(Sender: TObject; Shift: TShiftState; X, Y: Integer);
begin
  if Shift=[ssLeft] then
    OnMouseDown(Sender, mbLeft, Shift, X, Y);
end;

end.

