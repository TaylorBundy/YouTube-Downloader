unit Unit1;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes,
  System.Variants,
  FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.StdCtrls,
  FMX.Controls.Presentation, FMX.ListBox, FMX.Edit, FMX.Objects,
  uDownloadListBoxItem, StrUtils, udmStyles, DosCommand, inifiles;

type
  TForm1 = class(TForm)
    Panel1: TPanel;
    Label1: TLabel;
    ComboBox1: TComboBox;
    Button1: TButton;
    Image1: TImage;
    Label2: TLabel;
    Image2: TImage;
    Button2: TButton;
    Label3: TLabel;
    ComboBox2: TComboBox;
    procedure FormCreate(Sender: TObject);
    procedure Button1Click(Sender: TObject);
    procedure Button2Click(Sender: TObject);
    procedure FormClose(Sender: TObject; var Action: TCloseAction);
  private
    FdosCMD2: TDosCommand;
    FUserName: string;
    procedure DownloadMedia(const URL: string; const MediaType:
      TDownloadMediaType);

    procedure SetNickName(const Value: string);
    function GetNickName: string;

    { Private declarations }
  public
    //constructor Create(AOwner: TComponent;
     //const extension: string);
    property NickName: string read GetNickName write SetNickName;
    //procedure TForm.PassUserName(const estension: string);
    //begin
      //Caption := 'You can now chat: ' + aUsername;
    //end;
    { Public declarations }
  end;

  // constructor Tform1.Create(AOwner: TComponent; const extension: string);
  //begin
  //  inherited Create(AOwner);
  //  FUserName := extension;
  //end;
type
  TData = array of string;

var
  Form1: TForm1;
  //extension: string;

implementation

uses ufrmMain;

{$R *.fmx}

procedure Tform1.DownloadMedia(const URL: string; const MediaType:
  TDownloadMediaType);
begin
  var aItem := TDownloadListBoxItem.Create(frmMain.lstDownloads);
  aItem.DownloadLink := URL;
  aItem.DownloadMediaType := MediaType;
  frmMain.lstDownloads.AddObject(aItem);
  if AnsiContainsStr(label1.Text, 'Audio') then
  begin
    aItem.StartDownload;
  end
  else if AnsiContainsStr(label1.Text, 'Video') then
  begin
    aItem.StartDownload2;
  end;
  //aItem.StartDownload;
  frmMain.edtURL.Text := '';
end;

procedure TForm1.SetNickName(const Value: string);
begin
  FUsername := Value;
end;

function TForm1.GetNickName: string;
begin
  Result := FUsername;
end;

procedure TForm1.Button1Click(Sender: TObject);
begin
  if AnsiContainsStr(label1.Text, 'Audio') then
  begin
    if combobox1.Selected.Text = 'Mp3' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtMP3);
    end;
    if combobox1.Selected.Text = 'Flac' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtFLAC);
    end;
    if combobox1.Selected.Text = 'Ogg' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtOGG);
    end;
  end
  else if AnsiContainsStr(label1.Text, 'Video') then
  begin
    if combobox1.Selected.Text = 'Mp4' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtMP4);
    end;
    if combobox1.Selected.Text = 'Flv' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtFLV);
    end;
    if combobox1.Selected.Text = 'Mov' then
    begin
      DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtMOV);
    end;
    //DownloadMedia(frmMain.edtURL.Text.Trim, TDownloadMediaType.mtMP4);
  end;
  {if frmmain.Timer2.Enabled = false then
  begin
    frmmain.Timer2.Enabled := true;
  end;}
  Form1.Close;
end;

procedure TForm1.Button2Click(Sender: TObject);
begin
  form1.Close;
end;

procedure TForm1.FormClose(Sender: TObject; var Action: TCloseAction);
begin
  if frmmain.Visible = false then
  begin
    frmmain.Visible := true;
    frmmain.Edit2.Text := combobox1.Selected.Text;
    if combobox2.Visible then
    begin
      frmmain.Edit4.Text := combobox2.Selected.Text;
    end;
  end;

  with tinifile.Create(changefileext(paramstr(0), '.INI')) do
    try
      if extension = 'Audio' then
      begin
        writeString('FORMATO ' + extension, 'lastext', combobox1.Selected.Text);
        writeString('FORMATO ' + extension, 'index',
          inttostr(combobox1.items.indexof(combobox1.Selected.Text)));
      end
      else if extension = 'Video' then
      begin
        writeString('RESOLUCION ' + extension, 'lastres',
          combobox2.Selected.Text);
        writeString('RESOLUCION ' + extension, 'index',
          inttostr(combobox2.items.indexof(combobox2.Selected.Text)));
        writeString('FORMATO ' + extension, 'lastext', combobox1.Selected.Text);
        writeString('FORMATO ' + extension, 'index',
          inttostr(combobox1.items.indexof(combobox1.Selected.Text)));
      end;

      //writeString('RESOLUCION', 'index', combobox2.Items[combobox2.ItemIndex]);
      //writeString('RESOLUCION', 'index', combobox2.Items[combobox2.ItemIndex]);

      //combobox2.items.indexof(combobox2.Selected.Text)
    finally
      Free;
    end;
end;

procedure TForm1.FormCreate(Sender: TObject);
var
  ListHint: array of string;
  ListHint2: array of string;
  i, a: integer;
begin
  //FdosCMD2 := TDosCommand.Create(Self);
  //FdosCMD2.OnNewLine := OnNewLine2;

  if fileexists(changefileext(paramstr(0), '.INI')) then
    begin
      with tinifile.Create(changefileext(paramstr(0), '.INI')) do
        try
          //lastdirec := readString('DIRECTORIO', 'lastdir', '');
          lastreso := readString('RESOLUCION ' + extension, 'lastres', '');
          indexReso := readString('RESOLUCION ' + extension, 'index', '');
          lastext := readString('FORMATO ' + extension, 'lastext', '');
          indexExt := readString('FORMATO ' + extension, 'index', '');
        finally
          Free;
        end;
    end;

  if frmmain.Visible = true then
  begin
    frmmain.Hide;
  end;

  label1.Text := 'Seleccione Formato de "' + Extension + '" a Convertir:';
  if Extension = 'Audio' then
  begin
    SetLength(ListHint, 3);
    ListHint[0] := 'Mp3';
    ListHint[1] := 'Ogg';
    ListHint[2] := 'Flac';
    combobox1.Items.AddStrings(ListHint);
    combobox1.ItemIndex := 0;
    combobox2.Visible := False;
    label3.Visible := False;

    {if (AnsiContainsStr(frmmain.edtURL.Text, 'youtube.com')) then
    begin
      for i := 0 to frmmain.Memo1.Lines.Count - 1 do
      begin
        combobox2.Items.Add(frmmain.Memo1.Lines[i]);
      end;
    end
    else
    begin
      combobox2.Items.AddStrings(ListHint2);
    end;}

    //combobox2.Items.AddStrings(ListHint2);

    //combobox1.ItemIndex := 0;
    //combobox2.ItemIndex := 0;
    {if fileexists(changefileext(paramstr(0), '.INI')) then
    begin
      with tinifile.Create(changefileext(paramstr(0), '.INI')) do
        try
          //lastdirec := readString('DIRECTORIO', 'lastdir', '');
          lastreso := readString('RESOLUCION ' + extension, 'lastres', '');
          indexReso := readString('RESOLUCION ' + extension, 'index', '');
          lastext := readString('FORMATO ' + extension, 'lastext', '');
          indexExt := readString('FORMATO ' + extension, 'index', '');
        finally
          Free;
        end;}

      for a := 0 to combobox1.Items.Count - 1 do
      begin
        if combobox1.Items[a] = lastext then
        begin
          combobox1.ItemIndex := strtoint(indexext);
        end
        else
        begin
          combobox1.ItemIndex := 0;
        end;
      end;
      {for a := 0 to combobox2.Items.Count - 1 do
      begin
        if combobox2.Items[a] = lastreso then
        begin
          combobox2.ItemIndex := strtoint(indexreso);
        end
        else
        begin
          combobox2.ItemIndex := 0;
        end;
      end;}
    //end;
  end
  else if Extension = 'Video' then
  begin
    SetLength(ListHint, 3);
    SetLength(ListHint2, 3);
    //SetLength(Data, 3);
    ListHint[0] := 'Mp4';
    ListHint[1] := 'Flv';
    ListHint[2] := 'Mov';
    ListHint2[0] := '480';
    ListHint2[1] := '720';
    ListHint2[2] := '1080';
    combobox1.Items.AddStrings(ListHint);
    if (AnsiContainsStr(frmmain.edtURL.Text, 'youtube.com')) or (AnsiContainsStr(frmmain.edtURL.Text, 'youtu.be')) then
    begin
      for i := 0 to frmmain.Memo1.Lines.Count - 1 do
      begin
        combobox2.Items.Add(frmmain.Memo1.Lines[i]);
      end;
    end
    else
    begin
      combobox2.Items.AddStrings(ListHint2);
    end;
    //combobox2.Items.AddStrings(ListHint2);

    //combobox1.ItemIndex := 0;
    //combobox2.ItemIndex := 0;
    {if fileexists(changefileext(paramstr(0), '.INI')) then
    begin
      with tinifile.Create(changefileext(paramstr(0), '.INI')) do
        try
          //lastdirec := readString('DIRECTORIO', 'lastdir', '');
          lastreso := readString('RESOLUCION ' + extension, 'lastres', '');
          indexReso := readString('RESOLUCION ' + extension, 'index', '');
          lastext := readString('FORMATO ' + extension, 'lastext', '');
          indexExt := readString('FORMATO ' + extension, 'index', '');
        finally
          Free;
        end;}

      for a := 0 to combobox1.Items.Count - 1 do
      begin
        if combobox1.Items[a] = lastext then
        begin
          combobox1.ItemIndex := strtoint(indexext);
        end
        else
        begin
          combobox1.ItemIndex := 0;
        end;
      end;
      for a := 0 to combobox2.Items.Count - 1 do
      begin
        if combobox2.Items[a] = lastreso then
        begin
          combobox2.ItemIndex := strtoint(indexreso);
        end
        else
        begin
          combobox2.ItemIndex := 0;
        end;
      end;
    //end;
  end;
end;

end.

