unit USendEmail;

interface

uses
  IdSMTP, IdSSLOpenSSL, IdMessage, IdText, IdAttachmentFile, IdExplicitTLSClientServerBase, System.SysUtils, FMX.Dialogs;

procedure SendEmail(const ANEXO: String);

implementation

const
  Porta = 465;
  Host  = '';
  Email = '';
  Destino = '';
  Senha = '';

procedure SendEmail(const ANEXO: String);
var
  IdSSLIOHandlerSocket: TIdSSLIOHandlerSocketOpenSSL;
  IdSMTP: TIdSMTP;
  IdMessage: TIdMessage;
  IdText: TIdText;
  sAnexo: string;
begin
  IdSSLIOHandlerSocket := TIdSSLIOHandlerSocketOpenSSL.Create(nil);
  IdSMTP := TIdSMTP.Create(nil);
  IdMessage := TIdMessage.Create(nil);

  try
    IdSSLIOHandlerSocket.SSLOptions.Method := sslvSSLv23;
    IdSSLIOHandlerSocket.SSLOptions.Mode := sslmClient;

    IdSMTP.IOHandler := IdSSLIOHandlerSocket;
    IdSMTP.UseTLS := utUseImplicitTLS;
    IdSMTP.AuthType := satDefault;
    IdSMTP.Port := Porta;
    IdSMTP.Host := Host;
    IdSMTP.Username := Email;
    IdSMTP.Password := Senha;

    IdMessage.From.Address := Email;
    IdMessage.From.Name := 'Deivid Costa';
    IdMessage.ReplyTo.EMailAddresses := IdMessage.From.Address;
    IdMessage.Recipients.Add.Text := Destino;
    IdMessage.Subject := 'Cadastro - Teste';
    IdMessage.Encoding := meMIME;

    IdText := TIdText.Create(IdMessage.MessageParts);
    IdText.Body.Add('Email XML referente dados do cadastro realizado.');
    IdText.ContentType := 'text/plain; charset=iso-8859-1';

    sAnexo := Anexo;
    if FileExists(sAnexo) then
    begin
      TIdAttachmentFile.Create(IdMessage.MessageParts, sAnexo);
    end;

    try
      IdSMTP.Connect;
      IdSMTP.Authenticate;
    except
      on E:Exception do
      begin
        ShowMessage('Erro ao autenticar email: ' + E.Message);
        Exit;
      end;
    end;

    try
      IdSMTP.Send(IdMessage);
    except
      On E:Exception do
      begin
        ShowMessage('Erro ao enviar email: ' + E.Message);
      end;
    end;
  finally
    IdSMTP.Disconnect;
    UnLoadOpenSSLLibrary;
    FreeAndNil(IdMessage);
    FreeAndNil(IdSSLIOHandlerSocket);
    FreeAndNil(IdSMTP);
  end;
end;

end.
