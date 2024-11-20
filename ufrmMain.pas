unit ufrmMain;

interface

uses
  Windows, System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, udmStyles, FMX.Layouts, FMX.ListBox, FMX.Edit,
  Skia,
  Skia.FMX, uDownloadListBoxItem, Vcl.ClipBrd, StrUtils, FMX.TreeView, MMSystem,
  DosCommand, FMX.Objects, Messages, ShlObj, inifiles, FMX.Memo.Types,
  FMX.ScrollBox, FMX.Memo, unit1, ShellApi, TLHelp32;

type
  TfrmMain = class(TForm)
    statMain: TStatusBar;
    tlbMain: TToolBar;
    lytAppVersion: TLayout;
    lblAppVersionValue: TLabel;
    lblAppVersionHeader: TLabel;
    lblDownloadsHeader: TLabel;
    lstDownloads: TListBox;
    lblURLHeader: TLabel;
    edtURL: TEdit;
    btnClearURL: TClearEditButton;
    btnDownloadMP4: TButton;
    btnDownloadMP3: TButton;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Edit1: TEdit;
    Timer1: TTimer;
    Label2: TLabel;
    ComboBox2: TComboBox;
    Label3: TLabel;
    ComboBox3: TComboBox;
    Label4: TLabel;
    Label5: TLabel;
    Edit2: TEdit;
    Timer2: TTimer;
    Edit3: TEdit;
    OpenDialog1: TOpenDialog;
    Button1: TButton;
    Image1: TImage;
    Memo1: TMemo;
    Label6: TLabel;
    Edit4: TEdit;
    CornerButton1: TCornerButton;
    Memo2: TMemo;
    procedure btnDownloadMP3Click(Sender: TObject);
    procedure btnDownloadMP4Click(Sender: TObject);
    procedure OnAppVersionResized(Sender: TObject);
    procedure FormCreate(Sender: TObject);
    procedure ComboBox1Click(Sender: TObject);
    procedure ComboBox1Change(Sender: TObject);
    procedure Timer1Timer(Sender: TObject);
    procedure ComboBox2Change(Sender: TObject);
    procedure ComboBox3Change(Sender: TObject);
    procedure Timer2Timer(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Image1Click(Sender: TObject);
    procedure Edit1Change(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
    procedure Memo1Change(Sender: TObject);
    procedure CornerButton1Click(Sender: TObject);
    procedure btnClearURLClick(Sender: TObject);
  private
    FdosCMD2: TDosCommand;
    FlblVideoTitle: TLabel;
    FlblProgressText: TLabel;
  private
    function ParseInfo3(const Data: string): string;
    {procedure OnNewLine2(ASender: TObject; const ANewLine: string; AOutputType:
      TOutputType);}
    { Private declarations }
  public
    procedure OnNewLine2(ASender: TObject; const ANewLine: string; AOutputType:
      TOutputType);
    { Public declarations }
  end;

type
  ListRes = array of string;

var
  frmMain: TfrmMain;
  extension: string;
  lastdirec: string;
  lastreso: string;
  lastext: string;
  //indexReso : integer;
  indexReso: string;
  indexExt: string;
  resolucion: string;

implementation

//uses unit1;
{$R *.fmx}
// {$R resources.res}
{$R 'resources.res' 'resources.RC'}

function procrunning: Boolean;
var
  Proceso: TProcessEntry32;
  ProcessHandle: THandle;
  Sproceso: Boolean;
  Nproceso: string;
begin
  Result := False;
  Proceso.dwSize := SizeOf(TProcessEntry32);
  ProcessHandle := CreateToolHelp32Snapshot(TH32CS_SNAPPROCESS, 0);
  if Process32First(ProcessHandle, Proceso) then
  begin
    Nproceso := string(Proceso.szExeFile);
    repeat Sproceso := Process32Next(ProcessHandle, Proceso);
      Nproceso := string(Proceso.szExeFile);
      //if Nproceso = 'C:\Program Files (x86)\Delphi7SE\Projects\RedGifs\Project1.exe' then
      if Nproceso = 'Project1.exe' then
        Result := True;
    until not Sproceso;
  end;
  CloseHandle(ProcessHandle);
end;

procedure TfrmMain.OnNewLine2(ASender: TObject; const ANewLine:
  string; AOutputType: TOutputType);
var
  position, position1, position2, y, i: integer;
  x: TCaretPosition;
  //ListRes: array of string;
  //ListReso: ListRes;
  //resol: TStrings;
  //sl: TStringList;
  S, s1, s2: string;
begin
  //memo2.Lines.Add(anewline);
  //SetLength(ListReso, 3);
  //if (AnsiContainsStr(ANewLine, '480p, mp4_dash')) or
    //(AnsiContainsStr(ANewLine, '720p, mp4_dash')) or
    //(AnsiContainsStr(ANewLine, 'avc1.4D401E')) or
    //(AnsiContainsStr(ANewLine, 'avc1.4D401F')) or
    //(AnsiContainsStr(ANewLine, 'avc1.640028')) or
    //(AnsiContainsStr(ANewLine, '1080p, mp4_dash')) then
  try
    if (AnsiContainsStr(ANewLine, '480p, mp4_dash')) then
    begin
      position := AnsiPos('480p, mp4_dash', ANewLine);
      s := copy(anewline, 0, position);
      if AnsiContainsStr(s, 'x480') then
      begin
        position2 := ansipos('x480', s);
        s2 := copy(s, 15, position2 - 11);
      end
      else if AnsiContainsStr(s, '480x') then
      begin
        position2 := ansipos('480x', s);
        s2 := copy(s, 11, position2 - 8);
      end
      else if AnsiContainsStr(s, 'x1080') then
      begin
        position2 := ansipos('x1080', s);
        s2 := copy(s, 15, position2 - 10);
      end;
      //position2 := ansipos('x480', s);
      //s2 := copy(s, 15, position2 - 11);
      if memo1.Lines.IndexOf(s2) = -1 then
        memo1.Lines.Add(s2);
    end
    else if (AnsiContainsStr(ANewLine, '360p, mp4_dash')) then
    begin
      position := AnsiPos('360p, mp4_dash', ANewLine);
      s := copy(anewline, 0, position);
      if AnsiContainsStr(s, '360x') then
      begin
        position2 := ansipos('360x', s);
        s2 := copy(s, 11, position2 - 8);
      end
      else // if AnsiContainsStr(s, '360x') then
      begin
        position2 := ansipos('x', s);
        s2 := copy(s, 15, position2 - 8);
      end;
      //position2 := ansipos('360x', s);
      //s2 := copy(s, 11, position2 - 8);
      if memo1.Lines.IndexOf(s2) = -1 then
        memo1.Lines.Add(s2);
    end
    else if (AnsiContainsStr(ANewLine, '720p, mp4_dash')) then
    begin
      position := AnsiPos('720p, mp4_dash', ANewLine);
      s := copy(anewline, 0, position);
      position2 := ansipos('x720', s);
      s2 := copy(s, 15, position2 - 11);
      s1 := StringReplace(s2, 'x', '', [rfReplaceAll, rfIgnoreCase]);
      if memo1.Lines.IndexOf(s2) = -1 then
      begin
        if memo1.Lines.IndexOf(s1) = -1 then
          memo1.Lines.Add(s1);
      end;
    end
    else if (AnsiContainsStr(ANewLine, '1080p, mp4_dash')) then
    begin
      position := AnsiPos('1080p, mp4_dash', ANewLine);
      s := copy(anewline, 0, position);
      position2 := ansipos('x1080', s);
      s2 := copy(s, 16, position2 - 11);
      if memo1.Lines.IndexOf(s2) = -1 then
        memo1.Lines.Add(s2);
    end
    else if (AnsiContainsStr(ANewLine, '2160p, mp4_dash')) then
    begin
      position := AnsiPos('2160p, mp4_dash', ANewLine);
      s := copy(anewline, 0, position);
      position2 := ansipos('x1080', s);
      //s2 := copy(s, 16, position2 - 11);
      s2 := '4K';
      if memo1.Lines.IndexOf(s2) = -1 then
        memo1.Lines.Add(s2);
    end;
  finally

    if memo1.Text <> '' then
    begin
      if btndownloadmp4.Enabled = false then
      begin
        btndownloadmp4.Enabled := true;
      end;
    end
    else
    begin
      if btndownloadmp4.Enabled = true then
      begin
        btndownloadmp4.Enabled := false;
      end;
    end;
  end;
end;

function TfrmMain.ParseInfo3(const Data: string): string;
begin
  Result := Data.Replace('[title-info]', '').Trim;
  //Result := Data;
end;

// Funcion para listar unidades
procedure GetDrives;
var
  C: Char;
begin
  for C := 'A' to 'Z' do
    if GetDriveType(PChar(C + ':\')) <> DRIVE_NO_ROOT_DIR then
      frmMain.ComboBox1.Items.Add(C + ':\');
end;

// funcion para listar carpetas
procedure ListFolder(Dir: string; Salida: TStrings);
var
  sr: TSearchRec;
begin
  if FindFirst(Dir + '\*.*', faAnyFile, sr) = 0 then
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if (sr.Attr and faDirectory) <> 0 then
        begin
          Application.ProcessMessages; // <<=======<<
          // Para añadir la carpeta actual
          Salida.Add(Dir + sr.Name);
          // Para añadir subcarpetas
          // ListFolder(Dir + '\' + sr.Name, Salida);
        end;
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
end;

// funcion para listar carpetas
procedure ListFolder2(Dir: string; Salida: TStrings);
var
  sr: TSearchRec;
begin
  if FindFirst(Dir + '\*.*', faAnyFile, sr) = 0 then
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if (sr.Attr and faDirectory) <> 0 then
        begin
          Application.ProcessMessages; // <<=======<<
          // Para añadir la carpeta actual
          Salida.Add(sr.Name);
          // Para añadir subcarpetas
          // ListFolder(Dir +  sr.Name, Salida);
        end;
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
end;

// funcion para listar carpetas
procedure ListFolder3(Dir: string; Salida: TStrings);
var
  sr: TSearchRec;
begin
  if FindFirst(Dir + '\*.*', faAnyFile, sr) = 0 then
    repeat
      if (sr.Name <> '.') and (sr.Name <> '..') then
      begin
        if (sr.Attr and faDirectory) <> 0 then
        begin
          Application.ProcessMessages; // <<=======<<
          // Para añadir la carpeta actual
          Salida.Add(Dir + '\' + sr.Name);
          // Para añadir subcarpetas
          ListFolder3(Dir + '\' + sr.Name, Salida);
        end;
      end;
    until FindNext(sr) <> 0;
  FindClose(sr);
end;

// function cargadir: string;
// var
// Lista: TStringList;
// begin
// Lista := TStringList.Create;
// ListFolder('E:\Imagenes\Private', Lista);
// //ListFolder(frmmain.ComboBox1.Items.Text, Lista);
// frmmain.combobox1.Items.AddStrings(lista);
// //ListBox2.Items:=Lista;
// Lista.Free;
// end;

procedure TfrmMain.btnClearURLClick(Sender: TObject);
begin
  if edturl.Text <> '' then
  begin
    if btndownloadmp4.Enabled then
    begin
      btndownloadmp4.Enabled := false;
    end;
  end;
end;

procedure TfrmMain.btnDownloadMP3Click(Sender: TObject);
begin
  if (Edit1.Text <> '') and (edtURL.Text <> '') then
  begin
    // const estension = 'Audio';
    extension := 'Audio';
    Form1 := TForm1.Create(Application);
    Form1.Nickname := extension;

    Form1.Show;

    // DownloadMedia(edtURL.Text.Trim, TDownloadMediaType.mtMP4);
    // DownloadMedia(edtURL.Text.Trim, TDownloadMediaType.mtMP3);
  end
  else if (Edit1.Text = '') and (edtURL.Text <> '') then
  begin
    showmessage('Debe definir ruta destino');
  end
  else if (Edit1.Text <> '') and (edtURL.Text = '') then
  begin
    showmessage('Debe definir una url valida');
  end
  else
  begin
    showmessage('Debe definir ruta destino');
  end;

end;

procedure TfrmMain.btnDownloadMP4Click(Sender: TObject);
var
  Lista: TStringList;
begin
  if (Edit1.Text <> '') and (edtURL.Text <> '') then
  begin
    // const estension = 'Video';
    // Form1.Nickname := aUsername;
    Lista := TStringList.Create;
    extension := 'Video';

    Form1 := TForm1.Create(Application);
    Form1.Nickname := extension;
    Form1.Show;

    // DownloadMedia(edtURL.Text.Trim, TDownloadMediaType.mtMP4);
  end
  else if (Edit1.Text = '') and (edtURL.Text <> '') then
  begin
    showmessage('Debe definir ruta destino');
  end
  else if (Edit1.Text <> '') and (edtURL.Text = '') then
  begin
    showmessage('Debe definir una url valida');
  end
  else
  begin
    showmessage('Debe definir ruta destino');
  end;

end;

procedure TfrmMain.ComboBox1Change(Sender: TObject);
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  ListFolder2(frmMain.ComboBox1.Selected.Text, Lista);
  ComboBox2.Items.AddStrings(Lista);
  Lista.Free;
end;

procedure TfrmMain.ComboBox1Click(Sender: TObject);
begin
  // edit1.Text := combobox1.Items.Text;
end;

procedure TfrmMain.ComboBox2Change(Sender: TObject);
var
  Lista: TStringList;
begin
  Lista := TStringList.Create;
  ListFolder3(frmMain.ComboBox1.Selected.Text +
    frmMain.ComboBox2.Selected.Text, Lista);
  ComboBox3.Items.AddStrings(Lista);
  Lista.Free;
end;

procedure TfrmMain.ComboBox3Change(Sender: TObject);
begin
  Edit1.Text := ComboBox3.Selected.Text;
end;

procedure TfrmMain.CornerButton1Click(Sender: TObject);
var
  x, Allcomp: integer;
begin
  AllComp := frmMain.ComponentCount;
  //memo2.Clear;
  if memo1.Visible = false then
  begin
    memo1.Visible := true;
  end
  else
  begin
    memo1.Visible := False;
  end;
  memo1.Lines.Clear;
  for x := 0 to allcomp - 1 do
    if (frmMain.Components[x] is Ttimer) then
    begin
      if Ttimer(frmMain.Components[x]).Enabled = true then
      begin
        //edit1.Text := 'activos';
        memo1.Lines.Add('activos: ' + frmMain.Components[x].name);
        Ttimer(frmMain.Components[x]).Enabled := false;
      end
      else
      begin
        //edit1.Text := 'parados';
        memo1.Lines.Add('parados: ' + frmMain.Components[x].name);
      end;
    end;
end;

procedure TfrmMain.Edit1Change(Sender: TObject);
begin
  if Edit1.Text = '' then
  begin
    Image1.Bitmap.LoadFromFile
      ('E:\Datos de usuario\Documents\Embarcadero\Studio\Projects\YouTube\Resources\open.ico');
    Button1.Hint := 'Limpiar Directorio';
    Image1.Hint := 'Limpiar Directorio';
  end
  else
  begin
    Button1.Hint := 'Seleccionar Directorio';
    Image1.Hint := 'Limpiar Directorio';
  end;
end;

// procedure TfrmMain.DownloadMedia(const URL: string; const MediaType:
// TDownloadMediaType);
// begin
// var aItem := TDownloadListBoxItem.Create(lstDownloads);
// aItem.DownloadLink := URL;
// aItem.DownloadMediaType := MediaType;
// lstDownloads.AddObject(aItem);
// aItem.StartDownload;
// edtURL.Text := '';
// end;

procedure TfrmMain.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  with tinifile.Create(changefileext(paramstr(0), '.INI')) do
    try
      writeString('DIRECTORIO', 'lastdir', Edit1.Text);
    finally
      Free;
    end;
end;

procedure TfrmMain.FormCreate(Sender: TObject);

begin
  edtURL.Text := ParamStr(1);
  if (memo1.Visible = true) then
  begin
    memo1.Visible := false;
  end;
  if (memo2.Visible = true) then
  begin
    memo2.Visible := false;
  end;
  if fileexists(changefileext(paramstr(0), '.INI')) then
  begin
    with tinifile.Create(changefileext(paramstr(0), '.INI')) do
      try
        lastdirec := readString('DIRECTORIO', 'lastdir', '');
        //lastreso := readString('RESOLUCION ' + extension, 'lastres', '');
        //indexReso := readString('RESOLUCION ' + extension, 'index', '');
        //lastext := readString('FORMATO ' + extension, 'lastext', '');
        //indexExt := readString('FORMATO ' + extension, 'index', '');
      finally
        Free;
      end;
    if (edturl.Text = '') and (memo1.Text = '') then
    begin
      btndownloadmp4.Enabled := false;
    end
    else if edturl.Text <> '' then
    begin
      btndownloadmp4.Enabled := true;
    end;
  end;

  GetDrives;
  // cargadir;
  if Timer1.Enabled = false then
  begin
    Timer1.Enabled := true;
  end;
  Button1.Hint := 'Seleccionar Directorio';
  Image1.Hint := 'Seleccionar Directorio';
end;

procedure TfrmMain.Button1Click(Sender: TObject);
var
  chosenDirectory: string;
begin
  if Edit1.Text = '' then
  begin
    // if SelectDirectory('Seleccione un Directorio', GetCurrentDir,
    if SelectDirectory('Seleccione un Directorio', lastdirec, chosenDirectory)
      then
    begin
      Edit1.Text := chosenDirectory;
      // image1.MultiResBitmap.Bitmaps[1].Assign(nil);
      Image1.Bitmap.LoadFromFile
        ('E:\Datos de usuario\Documents\Embarcadero\Studio\Projects\YouTube\Resources\open2.ico');
      Button1.Hint := 'Limpiar Directorio';
      Image1.Hint := 'Limpiar Directorio';
    end;
  end
  else
  begin
    Edit1.Text := '';
    Image1.Bitmap.LoadFromFile
      ('E:\Datos de usuario\Documents\Embarcadero\Studio\Projects\YouTube\Resources\open.ico');
    Button1.Hint := 'Seleccionar Directorio';
    Image1.Hint := 'Seleccionar Directorio';
  end;
end;

procedure TfrmMain.Image1Click(Sender: TObject);
var
  chosenDirectory: string;
begin
  if Edit1.Text = '' then
  begin
    // if SelectDirectory('Seleccione un Directorio', GetCurrentDir,
    if SelectDirectory('Seleccione un Directorio', lastdirec, chosenDirectory)
      then
    begin
      Edit1.Text := chosenDirectory;
      // image1.MultiResBitmap.Bitmaps[1].Assign(nil);
      Image1.Bitmap.LoadFromFile
        ('E:\Datos de usuario\Documents\Embarcadero\Studio\Projects\YouTube\Resources\open2.ico');
      Button1.Hint := 'Limpiar Directorio';
      Image1.Hint := 'Limpiar Directorio';
    end;
  end
  else
  begin
    Edit1.Text := '';
    Image1.Bitmap.LoadFromFile
      ('E:\Datos de usuario\Documents\Embarcadero\Studio\Projects\YouTube\Resources\open.ico');
    Button1.Hint := 'Seleccionar Directorio';
    Image1.Hint := 'Seleccionar Directorio';
  end;
end;

procedure TfrmMain.Memo1Change(Sender: TObject);
begin
  {  if memo1.Text <> '' then
    begin
      if btndownloadmp4.Enabled = false then
      begin
        btndownloadmp4.Enabled := true;
      end;
    end
    else
    begin
      if btndownloadmp4.Enabled = true then
      begin
        btndownloadmp4.Enabled := false;
      end;
    end; }
end;

procedure TfrmMain.OnAppVersionResized(Sender: TObject);
begin
  lytAppVersion.Width := lblAppVersionValue.Width + lblAppVersionHeader.Width +
    lblAppVersionHeader.Margins.Right;
end;

procedure TfrmMain.Timer1Timer(Sender: TObject);
var
  RecText: string;
  proceso: string;
  Mutex: THandle;
begin
  {FdosCMD2 := TDosCommand.Create(Self);
  FdosCMD2.OnNewLine := OnNewLine2; }
  proceso := 'C:\Program Files (x86)\Delphi7SE\Projects\RedGifs\Project1.exe';
  Mutex := CreateMutex(nil, FALSE, pchar(proceso));

  {if GetLastError = 0 then
  begin
  RecText := Clipboard.AsText;
    ShellExecute(0, 'open', pchar(Proceso), nil, nil, SW_HIDE);
  end;

  if Mutex <> 0 then
  begin

    CloseHandle(Mutex);
  end; }
  if procrunning = false then
  begin
    RecText := Clipboard.AsText;
  end
  else
  begin
    edtURL.Text := ParamStr(1);
  end;

  //RecText := Clipboard.AsText;
  if (AnsiContainsStr(RecText, 'pornhub.com')) or
    (AnsiContainsStr(RecText, 'redgifs.com')) or
    (AnsiContainsStr(RecText, 'xvideos.com')) or
    (AnsiContainsStr(RecText, 'youtube.com')) or
    (AnsiContainsStr(RecText, 'youtu.be')) or
    (AnsiContainsStr(RecText, 'twitter.com')) or
    (AnsiContainsStr(RecText, 'video.twimg.com')) or
    (AnsiContainsStr(RecText, 'reddit.com')) or
    (AnsiContainsStr(RecText, 'https://')) and (RecText <> edtURL.Text) then
  begin
    try
      //if edtURL.Text <> ParamStr(1) then
      //begin

      if RecText <> edtURL.Text then
      begin
        edtURL.Text := RecText;
        //edtURL.Text := ParamStr(1);
        if (AnsiContainsStr(RecText, 'youtube.com')) or (AnsiContainsStr(RecText, 'youtu.be')) then
        begin
          if timer2.Enabled = False then
          begin
            timer2.Enabled := True;
          end;
        end
        else
        begin
          btndownloadmp4.Enabled := true;
        end;

        {FdosCMD2.CommandLine :=
          '.\yt-dlp.exe --print filename -o "[title-info] %(title)s" "' + rectext
          +
          '" -F';
        FdosCMD2.Execute;}
        PlaySound('chimes', hInstance, SND_RESOURCE or SND_ASYNC);
      end;
      //end;
    finally
      //PlaySound('chimes', hInstance, SND_RESOURCE or SND_ASYNC);
      Clipboard.Clear;
    end;
  end;
end;

procedure TfrmMain.Timer2Timer(Sender: TObject);
begin
  if timer2.Enabled = True then
  begin
    try
      memo1.Lines.Clear;
      FdosCMD2 := TDosCommand.Create(Self);
      FdosCMD2.OnNewLine := OnNewLine2;
      FdosCMD2.CommandLine :=
        '.\yt-dlp.exe --print filename -o "[title-info] %(title)s" "' +
        edtURL.Text
        +
        '" -F';
      FdosCMD2.Execute;
    finally
      timer2.Enabled := False;
    end;
  end;

  {if fileexists(Edit1.Text + '\' + Edit3.Text) then
  begin
    PlaySound('notify', hInstance, SND_RESOURCE or SND_ASYNC);
    if frmMain.Timer2.Enabled = true then
    begin
      frmMain.Timer2.Enabled := false;
    end;
  end;}
end;

end.

