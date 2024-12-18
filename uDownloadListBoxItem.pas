unit uDownloadListBoxItem;

interface

uses
  System.UITypes, System.Classes, System.Types, System.SysUtils, FMX.ListBox,
  FMX.Objects, FMX.StdCtrls, FMX.Ani, FMX.Types, FMX.Effects, FMX.Layouts,
  FMX.Graphics, Skia.FMX, FMX.TabControl, System.IOUtils, FMX.ImgList, MMSystem,
  DosCommand, FMX.Forms;

type
  TYTProgress = record
    downloadedBytes: Int64;
    totalBytes: Int64;
    speed: Double;
    eta: Int64;
    etaFormatted: string;
  end;

type
  TDownloadMediaType = (mtMP3, mtMP4, mtFLV, mtMOV, mtFLAC, mtOGG);

type
  TDownloadListBoxItem = class(TListBoxItem)
  private
    FBackGround: TRectangle;
    FControlLayout: TLayout;
    FIcon: TImage;
    FlblVideoTitle: TLabel;
    FpbProgress: TProgressBar;
    FlblProgressText: TLabel;
    FbtnCancel: TSpeedButton;
    FdosCMD: TDosCommand;
    FLog: TStringList;
    // Link
    FDownloadLink: string;
    //dir: string;
    FDownloadMediaType: TDownloadMediaType;
    procedure BackgroundClicked(Sender: TObject);
    procedure OnMouseHover(Sender: TObject);
    procedure OnMouseHoverLeave(Sender: TObject);
  private
    { Private Methods }
    function ParseProgress(const Data: string): TYTProgress;
    function ParseInfo(const Data: string): string;
    function ParseInfo2(const Data: string): string;
  private
    { Property Methods Gets }
    function GetDownloadLink: string;
    function GetDownloadMediaType: TDownloadMediaType;
  private
    { Property Methods Sets }
    procedure SetDownloadLink(const Value: string);
    procedure SetDownloadMediaType(const Value: TDownloadMediaType);
  private
    { DosCommand Events }
    procedure OnNewLine(ASender: TObject; const ANewLine: string; AOutputType:
      TOutputType);
    procedure OnTerminate(Sender: TObject);
  private
    {Private Const}
    const
      TEMPLATE_PROGRESS =
        '[yt-dlp] | %(progress.downloaded_bytes)s | %(progress.total_bytes)s | %(progress.speed)s | %(progress.eta)s | %(progress._eta_str)s';
      { Other Events }
    procedure OnCancelClicked(Sender: TObject);
  public
    procedure AfterConstruction; override;
    procedure StartDownload;
    procedure StartDownload2;
  published
    property DownloadLink: string read GetDownloadLink write SetDownloadLink;
    property DownloadMediaType: TDownloadMediaType read GetDownloadMediaType
      write SetDownloadMediaType;
  end;

implementation

uses
  uCommonFunctions, ufrmMain, unit1;

{ TDownloadListBoxItem }

procedure TDownloadListBoxItem.AfterConstruction;
begin
  inherited;

  { Build Item }
  Self.Padding.Left := 5;
  Self.Padding.Top := 2.5;
  Self.Padding.Right := 5;
  Self.Padding.Bottom := 2.5;
  Self.CanFocus := False;
  Self.DisableFocusEffect := True;
  Self.Selectable := False;
  Self.Height := 50;

  // Background
  FBackGround := TRectangle.Create(Self);
  FBackGround.Parent := Self;
  FBackGround.Fill.Color := $FF1F222A;
  FBackGround.Align := TAlignLayout.Client;
  FBackGround.Sides := [];
  FBackGround.XRadius := 5;
  FBackGround.YRadius := 5;
  FBackGround.HitTest := True;
  FBackGround.OnClick := BackgroundClicked;
  FBackGround.OnMouseEnter := OnMouseHover;
  FBackGround.OnMouseLeave := OnMouseHoverLeave;
  FBackGround.Stroke.Color := $00;
  FBackGround.Name := 'FBackGround';

  // Controls Layout
  FControlLayout := TLayout.Create(FBackGround);
  FControlLayout.Parent := FBackGround;
  FControlLayout.Align := TAlignLayout.Contents;
  FControlLayout.Padding.Top := 5;
  FControlLayout.Padding.Right := 5;
  FControlLayout.Padding.Bottom := 5;
  FControlLayout.Padding.Left := 5;

  // Icon
  FIcon := TImage.Create(FControlLayout);
  FIcon.Parent := FControlLayout;
  FIcon.HitTest := False;
  FIcon.Align := TAlignLayout.MostLeft;
  FIcon.Width := FIcon.Height;
  var resStream := TResourceStream.Create(HInstance, 'img_download', RT_RCDATA);
  try
    FIcon.Bitmap.LoadFromStream(resStream);
  finally
    resStream.Free;
  end;

  // Video Title
  FlblVideoTitle := TLabel.Create(FControlLayout);
  FlblVideoTitle.Parent := FControlLayout;
  FlblVideoTitle.AutoSize := True;
  FlblVideoTitle.TextSettings.WordWrap := True;
  FlblVideoTitle.Align := TAlignLayout.Client;
  FlblVideoTitle.Margins.Left := 5;
  FlblVideoTitle.Margins.Right := 5;
  FlblVideoTitle.Text := 'Video Title / Audio Title' + sLineBreak + 'New line';
  FlblVideoTitle.Font.Style := [TFontStyle.fsBold];
  FlblVideoTitle.StyledSettings := [TStyledSetting.Family,
    TStyledSetting.FontColor];

  // Progress Bar
  FpbProgress := TProgressBar.Create(FControlLayout);
  FpbProgress.Parent := FControlLayout;
  FpbProgress.Align := TAlignLayout.Right;
  FpbProgress.Width := 400;
  FpbProgress.HitTest := False;
  FpbProgress.Margins.Top := 5;
  FpbProgress.Margins.Right := 5;
  FpbProgress.Margins.Bottom := 5;
  FpbProgress.Min := 0;
  FpbProgress.Max := 100;
  FpbProgress.Value := 50;

  // Progress Text
  FlblProgressText := TLabel.Create(FpbProgress);
  FlblProgressText.Parent := FpbProgress;
  FlblProgressText.Align := TAlignLayout.Contents;
  FlblProgressText.Text := '10MB / 50MB   32mb/s   ETA: 00:30';
  FlblProgressText.StyledSettings := [TStyledSetting.Family,
    TStyledSetting.FontColor];
  FlblProgressText.TextSettings.HorzAlign := TTextAlign.Center;

  // Cancel Button
  FbtnCancel := TSpeedButton.Create(FControlLayout);
  FbtnCancel.Parent := FControlLayout;
  FbtnCancel.OnClick := OnCancelClicked;
  FbtnCancel.Align := TAlignLayout.MostRight;
  FbtnCancel.Width := FbtnCancel.Height;
  FbtnCancel.StyleLookup := 'stoptoolbuttonbordered';
  FbtnCancel.ShowHint := true;
  FbtnCancel.Hint := 'Cancelar Descarga';

  // DosCommand
  FdosCMD := TDosCommand.Create(Self);
  FdosCMD.OnNewLine := OnNewLine;
  FdosCMD.OnTerminated := OnTerminate;

  // Logs
  FLog := TStringList.Create;
end;

procedure TDownloadListBoxItem.BackgroundClicked(Sender: TObject);
begin
  // Handle on click events
  if Assigned(Self.OnClick) then
    Self.OnClick(Self)
  else if Assigned(Self.ListBox.OnItemClick) then
    Self.ListBox.OnItemClick(Self.ListBox, Self);
end;

function TDownloadListBoxItem.GetDownloadLink: string;
begin
  Result := FDownloadLink;
end;

function TDownloadListBoxItem.GetDownloadMediaType: TDownloadMediaType;
begin
  Result := FDownloadMediaType;
end;

procedure TDownloadListBoxItem.OnCancelClicked(Sender: TObject);
begin
  // Stop dosCommand if running
  if FdosCMD.IsRunning then
    FdosCMD.Stop;

  FlblProgressText.Text := 'Deteniendo...';

  while FdosCMD.IsRunning do
    Application.ProcessMessages;

  // Clear bitmap from memory
  FIcon.Bitmap := nil;

  // Delete the listbox item
  FreeAndNil(Self);
  PlaySound('notify', hInstance, SND_RESOURCE or SND_ASYNC);
  frmmain.Edit3.Text := '';
  frmmain.btnDownloadMP4.Enabled := False;
end;

procedure TDownloadListBoxItem.OnMouseHover(Sender: TObject);
begin
  // Hover background color
  FBackGround.Fill.Color := TAlphaColorRec.Darkred;
end;

procedure TDownloadListBoxItem.OnMouseHoverLeave(Sender: TObject);
begin
  // Default background color
  FBackGround.Fill.Color := $FF1F222A;
end;

procedure TDownloadListBoxItem.OnNewLine(ASender: TObject; const ANewLine:
  string; AOutputType: TOutputType);
begin
  // Check if FLog is created
  if not Assigned(FLog) then
    Exit;

  // Check if entire line
  if not (AOutputType = TOutputType.otEntireLine) then
    Exit;

  // Info
  if ANewLine.StartsWith('[title-info]') then
  begin
    FlblVideoTitle.Text := ParseInfo(ANewLine);
    frmmain.Memo1.Lines.Add(ParseInfo2(ANewLine));
    //frmmain.ListBox1.Items.Add(ParseInfo(ANewLine));
  end;

  // Check if progress result
  if ANewLine.StartsWith('[yt-dlp]') then
  begin
    var progress := ParseProgress(ANewLine.Trim);
    FpbProgress.Max := progress.totalBytes;
    FpbProgress.Value := progress.downloadedBytes;

    var dlValueFormatted := ConvertBytes(progress.downloadedBytes);
    var dlMaxFormatted := ConvertBytes(progress.totalBytes);

    FlblProgressText.Text := Format('%s / %s', [dlValueFormatted,
        dlMaxFormatted]);
  end
  else
  begin
    FLog.Add(ANewLine);
    FlblProgressText.Text := ANewLine;
  end;
end;

procedure TDownloadListBoxItem.OnTerminate(Sender: TObject);
var
  noombre: string;
begin
  noombre := FlblVideoTitle.Text + '.' + frmmain.edit2.Text;
  FLog.Add('[Terminated]');
  FlblProgressText.Text := 'Terminado';
  //flog.SaveToFile('log.txt');
  {if frmmain.Timer2.Enabled = false then
  begin
    frmmain.Timer2.Enabled := true;
  end;}
  if fileExists(frmmain.edit1.Text + '\' + noombre) then
  begin
    //RenameFile(frmmain.edit1.Text + '\' + noombre, frmmain.edit1.Text + '\' + FlblVideoTitle.Text + '-1.' + frmmain.edit2.Text);
    PlaySound('tada', hInstance, SND_RESOURCE or SND_ASYNC);
    FreeAndNil(Self);
    frmmain.Edit2.Text := '';
    frmmain.Edit3.Text := '';
    frmmain.Edit4.Text := '';
    frmmain.btndownloadmp4.Enabled := false;
    {if frmMain.Timer2.Enabled = true then
    begin
      frmMain.Timer2.Enabled := false;
    end;}
  end;
end;

function TDownloadListBoxItem.ParseInfo(const Data: string): string;
begin
  Result := Data.Replace('[title-info]', '').Trim;
end;

function TDownloadListBoxItem.ParseInfo2(const Data: string): string;
begin
  //Result := Data.Replace('[title-info]', '').Trim;
  Result := Data;
end;

function TDownloadListBoxItem.ParseProgress(const Data: string): TYTProgress;
var
  fs: TFormatSettings;
begin
  // Avoid regional conflicts
  fs.DecimalSeparator := '.';

  var sl := TStringList.Create;
  try
    // Split the data
    sl.StrictDelimiter := True;
    sl.Delimiter := '|';
    sl.DelimitedText := Data;

    // Dummy vars
  var
    downloadedBytes: Int64;
  var
    totalBytes: Int64;
  var
    speed: Double;
  var
    eta: Int64;

    // Checks for strings before converting

    // Downloaded Bytes
    if not TryStrToInt64(sl[1].Trim, downloadedBytes) then
      sl[1] := '0';

    // Total Bytes
    if not TryStrToInt64(sl[2].Trim, totalBytes) then
      sl[2] := '0';

    // Speed
    if not TryStrToFloat(sl[3].Trim, speed, fs) then
      sl[3] := '0';

    // ETA seconds
    if not TryStrToInt64(sl[4].Trim, eta) then
      sl[4] := '0';

    // Result
    Result.downloadedBytes := sl[1].Trim.ToInt64;
    Result.totalBytes := sl[2].Trim.ToInt64;
    Result.speed := StrToFloat(sl[3].Trim, fs);
    Result.eta := sl[4].Trim.ToInt64;
    Result.etaFormatted := sl[5].Trim;
  finally
    sl.Free;
  end;
end;

procedure TDownloadListBoxItem.SetDownloadLink(const Value: string);
begin
  FDownloadLink := Value;
end;

procedure TDownloadListBoxItem.SetDownloadMediaType(const Value:
  TDownloadMediaType);
begin
  FDownloadMediaType := Value;
end;

procedure TDownloadListBoxItem.StartDownload;
begin
  FlblVideoTitle.Text := '';
  FlblProgressText.Text := '';
  FpbProgress.Value := 0;

  // Check if download link is empty
  if FDownloadLink.Trim.IsEmpty then
    Exit;

  // Get Info
  FlblVideoTitle.Text := 'Getting Info...';
  FdosCMD.CommandLine :=
    '.\yt-dlp.exe --print filename -o "[title-info] %(title)s" "' + FDownloadLink
    +
    '"';
  FdosCMD.Execute;

  while FdosCMD.IsRunning do

    Application.ProcessMessages;

  // Download URL
  // Set Command Line
  //FdosCMD.CommandLine := '.\yt-dlp.exe --progress-template "' + TEMPLATE_PROGRESS + '" "' + FDownloadLink + '" -P "' + frmmain.ComboBox1.Selected.Text + '" -o %(title)s.%(ext)s';
  FdosCMD.CommandLine := '.\yt-dlp.exe --progress-template "' +
    TEMPLATE_PROGRESS
    + '" "' + FDownloadLink + '" -P "' + frmmain.Edit1.Text +
    '" -o %(title)s.%(ext)s';

  // MP4
  {if FDownloadMediaType = TDownloadMediaType.mtMP4 then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video mp4';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtMOV then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video mov';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtFLV then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video flv';
  end;}

  // MP3
  if FDownloadMediaType = TDownloadMediaType.mtMP3 then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format mp3';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtFLAC then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format flac';

  end
  else if FDownloadMediaType = TDownloadMediaType.mtOGG then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format ogg';
  end;
  frmmain.Edit3.Text := FlblVideoTitle.Text + '.' +
    form1.ComboBox1.Selected.Text;
  FdosCMD.Execute;
end;

procedure TDownloadListBoxItem.StartDownload2;
begin
  FlblVideoTitle.Text := '';
  FlblProgressText.Text := '';
  FpbProgress.Value := 0;

  // Check if download link is empty
  if FDownloadLink.Trim.IsEmpty then
    Exit;

  // Get Info
  FlblVideoTitle.Text := 'Getting Info...';
  FdosCMD.CommandLine :=
    '.\yt-dlp.exe --print filename -o "[title-info] %(title)s" "' + FDownloadLink
    +
    '"';
  FdosCMD.Execute;

  while FdosCMD.IsRunning do

    Application.ProcessMessages;

  // Download URL
  // Set Command Line
  //FdosCMD.CommandLine := '.\yt-dlp.exe --progress-template "' + TEMPLATE_PROGRESS + '" "' + FDownloadLink + '" -P "' + frmmain.ComboBox1.Selected.Text + '" -o %(title)s.%(ext)s';
  FdosCMD.CommandLine := '.\yt-dlp.exe --progress-template "' +
    TEMPLATE_PROGRESS
    + '" "' + FDownloadLink + '" -P "' + frmmain.Edit1.Text +
    '" -o %(title)s.%(ext)s -S "res:' + frmmain.Edit4.Text + ',fps"';

  // MP4
  if FDownloadMediaType = TDownloadMediaType.mtMP4 then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video mp4';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtMOV then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video mov';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtFLV then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine + ' --recode-video flv';
  end;

  // MP3
  {if FDownloadMediaType = TDownloadMediaType.mtMP3 then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format mp3';
  end
  else if FDownloadMediaType = TDownloadMediaType.mtFLAC then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format flac';

  end
  else if FDownloadMediaType = TDownloadMediaType.mtOGG then
  begin
    FdosCMD.CommandLine := FdosCMD.CommandLine +
      ' --extract-audio --audio-format ogg';
  end;}
  frmmain.Edit3.Text := FlblVideoTitle.Text + '.' +
    form1.ComboBox1.Selected.Text;
  FdosCMD.Execute;
end;

end.

