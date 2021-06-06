unit View.Main;

interface

uses
  System.SysUtils, System.Types, System.UITypes, System.Classes, System.Variants, FMX.Types, FMX.Controls, FMX.Forms, FMX.Graphics, FMX.Dialogs, FMX.Effects,
  FMX.Objects, FMX.Layouts, FMX.Controls.Presentation, FMX.Edit, FMX.ListBox, FMX.Ani, Xml.xmldom, Xml.XMLIntf, IdBaseComponent, IdComponent, IdIOHandler,
  IdIOHandlerSocket, IdIOHandlerStack, IdSSL, IdSSLOpenSSL, Xml.Win.msxmldom, Xml.XMLDoc;

type
  TfrmMain = class(TForm)
    rectFundo: TRectangle;
    BlurEffFundo: TBlurEffect;
    lytFundo: TLayout;
    lytNome: TLayout;
    rectNome: TRectangle;
    edtNome: TEdit;
    StyleBook1: TStyleBook;
    lytDados1: TLayout;
    lytDoc: TLayout;
    rectDoc: TRectangle;
    edtDoc: TEdit;
    lytCPF: TLayout;
    rectCPF: TRectangle;
    edtCPF: TEdit;
    lytDados2: TLayout;
    lytEmail: TLayout;
    rectEmail: TRectangle;
    edtEmail: TEdit;
    lytTelefone: TLayout;
    rectTelefone: TRectangle;
    edtTelefone: TEdit;
    lytDados3: TLayout;
    lytCEP: TLayout;
    rectCEP: TRectangle;
    edtCEP: TEdit;
    lytLongradouro: TLayout;
    rectLongradouro: TRectangle;
    edtLogradouro: TEdit;
    lytNum: TLayout;
    rectNum: TRectangle;
    edtNum: TEdit;
    lytDados4: TLayout;
    lytComp: TLayout;
    recComp: TRectangle;
    edtComp: TEdit;
    lytBairro: TLayout;
    rectBairro: TRectangle;
    edtBairro: TEdit;
    lytDados5: TLayout;
    lytCidade: TLayout;
    rectCidade: TRectangle;
    edtCidade: TEdit;
    lytEstado: TLayout;
    recEstado: TRectangle;
    cbbEstado: TComboBox;
    lytPais: TLayout;
    recPais: TRectangle;
    cbbPais: TComboBox;
    recSalvar: TRectangle;
    txtSalvar: TText;
    ColorAnimation1: TColorAnimation;
    procedure FormCreate(Sender: TObject);
    procedure edtCEPKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
    procedure edtCPFTyping(Sender: TObject);
    procedure edtTelefoneTyping(Sender: TObject);
    procedure edtCEPTyping(Sender: TObject);
    procedure recSalvarClick(Sender: TObject);
    procedure edtCEPExit(Sender: TObject);
  private
    { Private declarations }
    procedure GetUF;
    procedure GetCountry;
    procedure FindCEP(const CEP: String);
    procedure CleanFields;
  public
    { Public declarations }
  end;

var
  frmMain: TfrmMain;

implementation

uses
  System.JSON, UFormat, USendEmail, UCEP;

{$R *.fmx}

{ TfrmMain }

procedure TfrmMain.CleanFields;
begin
  for var I := 0 to Pred(ComponentCount) do
  begin
    if Components[I].ClassType = TEdit then
      TEdit(Components[I]).Text := ''
    else if Components[I].ClassType = TComboBox then
      TComboBox(Components[I]).ItemIndex := -1
  end;
  if edtNome.CanFocus then
    edtNome.SetFocus;
end;

procedure TfrmMain.edtCEPExit(Sender: TObject);
begin
  if Trim(edtCEP.Text) <> '' then
    FindCEP(StringReplace(StringReplace(edtCEP.Text,'.','',[rfReplaceAll]),'-','',[rfReplaceAll]));
end;

procedure TfrmMain.edtCEPKeyDown(Sender: TObject; var Key: Word; var KeyChar: Char; Shift: TShiftState);
begin
  if Key = vkReturn then
    FindCEP(StringReplace(StringReplace(edtCEP.Text,'.','',[rfReplaceAll]),'-','',[rfReplaceAll]));
end;

procedure TfrmMain.edtCEPTyping(Sender: TObject);
begin
  Formatar(TEdit(Sender), TFormato.CEP);
end;

procedure TfrmMain.edtCPFTyping(Sender: TObject);
begin
  Formatar(TEdit(Sender), TFormato.CPF);
end;

procedure TfrmMain.edtTelefoneTyping(Sender: TObject);
begin
  Formatar(TEdit(Sender), TFormato.TelefoneFixo);
end;

procedure TfrmMain.FindCEP(const CEP: String);
var
  _CEP: TRecCEP;
begin
  _CEP := FindCEPVia(CEP);
  edtLogradouro.Text  := _CEP.Logradouro;
  edtBairro.Text      := _CEP.Bairro;
  edtCidade.Text      := _CEP.Localidade;
  cbbEstado.ItemIndex := cbbEstado.Items.IndexOf(_CEP.UF);
end;

procedure TfrmMain.FormCreate(Sender: TObject);
begin
  GetUF;
  GetCountry;
end;

procedure TfrmMain.GetCountry;
begin
  TThread.CreateAnonymousThread(procedure
  var
    JSONObj, JSONSubObj: TJSONObject;
    JSONArray: TJSONArray;
    JSONValue: TJSONValue;
    ArqJSON: TStringList;
  begin
    frmMain.cbbPais.Items.Clear;
    if not FileExists(ExtractFileDir(GetCurrentDir) + '\Paises.json') then
      Exit;
    ArqJSON := TStringList.Create;
    ArqJSON.LoadFromFile(ExtractFileDir(GetCurrentDir) + '\Paises.json');
    JSONObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ArqJSON.Text), 0) as TJSONObject;
    JSONValue := JSONObj.Get('Paises').JsonValue;
    JSONArray := JSONValue as TJSONArray;
    for var i := 0 to JSONArray.Size - 1 do
    begin
      JSONSubObj := (JSONArray.Get(i) as TJSONObject);
      JSONValue := JSONSubObj.Get(1).JsonValue;
      cbbPais.Items.Add(Utf8Decode(JSONValue.Value));
    end;
  end
  ).Start;
end;

procedure TfrmMain.GetUF;
begin
  TThread.CreateAnonymousThread(procedure
  var
    JSONObj, JSONSubObj: TJSONObject;
    JSONArray: TJSONArray;
    JSONValue: TJSONValue;
    ArqJSON: TStringList;
  begin
    frmMain.cbbEstado.Items.Clear;
    if not FileExists(ExtractFileDir(GetCurrentDir) + '\Estados.json') then
      Exit;
    ArqJSON := TStringList.Create;
    ArqJSON.LoadFromFile(ExtractFileDir(GetCurrentDir) + '\Estados.json');
    JSONObj := TJSONObject.ParseJSONValue(TEncoding.UTF8.GetBytes(ArqJSON.Text), 0) as TJSONObject;
    JSONValue := JSONObj.Get('UF').JsonValue;
    JSONArray := JSONValue as TJSONArray;
    for var i := 0 to JSONArray.Size - 1 do
    begin
      JSONSubObj := (JSONArray.Get(i) as TJSONObject);
      JSONValue := JSONSubObj.Get(1).JsonValue;
      cbbEstado.Items.Add(Utf8Decode(JSONValue.Value));
    end;
  end
  ).Start;
end;

procedure TfrmMain.recSalvarClick(Sender: TObject);
var
  ID: TGUID;
  XMLCadastro: TXMLDocument;
  NodeDados, NodeReg, NodeEnd: IXMLNode;
  I: Integer;
  ArqName: String;
begin
  CreateGUID(ID);
  XMLCadastro := TXMLDocument.Create(Self);
  try
    try
      XMLCadastro.Active := True;
      NodeDados := XMLCadastro.AddChild('PESSOA');
      NodeReg := NodeDados.AddChild('DADOS');
      NodeReg.ChildValues['ID'] := ID.ToString;
      NodeReg.ChildValues['NOME'] := edtNome.Text;
      NodeReg.ChildValues['DOCUMENTO'] := edtDoc.Text;
      NodeReg.ChildValues['CPF'] := edtCPF.Text;
      NodeReg.ChildValues['EMAIL'] := edtEmail.Text;
      NodeReg.ChildValues['TELEFONE'] := edtTelefone.Text;
      NodeReg.ChildValues['CEP'] := edtCEP.Text;
      NodeEnd := NodeDados.AddChild('ENDERECO');
      NodeEnd.ChildValues['LOGRADOURO'] := edtLogradouro.Text;
      NodeEnd.ChildValues['NUMERO'] := edtNum.Text;
      NodeEnd.ChildValues['COMPLEMENTO'] := edtComp.Text;
      NodeEnd.ChildValues['BAIRRO'] := edtBairro.Text;
      NodeEnd.ChildValues['CIDADE'] := edtCidade.Text;
      NodeEnd.ChildValues['UF'] := cbbEstado.Selected.Text;
      NodeEnd.ChildValues['PAIS'] := cbbPais.Selected.Text;
      ArqName := StringReplace(StringReplace(StringReplace(ID.ToString,'{','',[rfReplaceAll]),'}','',[rfReplaceAll]),'-','',[rfReplaceAll]);
      XMLCadastro.SaveToFile(ExtractFileDir(GetCurrentDir) + '\' + ArqName + '.xml');
      if FileExists(ExtractFileDir(GetCurrentDir) + '\' + ArqName + '.xml') then
      begin
        CleanFields;
        SendEmail(ArqName);
        ShowMessage('Registro salvo com sucesso!');
      end
      else
        ShowMessage('Não foi possível salvar os dados.')
    except on E: Exception do
      ShowMessage('Erro ao salvar Dados. Erro -> ' + E.Message);
    end;
  finally
    XMLCadastro.Free;
  end;
end;

end.
