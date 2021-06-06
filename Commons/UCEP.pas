unit UCEP;

interface

type
  TRecCEP = record
    CEP: String;
    Logradouro: String;
    Bairro: String;
    Localidade: String;
    UF: String;
  end;

function FindCEPVia(CEP: String): TRecCEP;

implementation

uses
  System.JSON, REST.Client;

function FindCEPVia(CEP: String): TRecCEP;
var
  obj: TJSONObject;
  RESTClient1: TRESTClient;
  RESTRequest1: TRESTRequest;
  RESTResponse1: TRESTResponse;
begin
  RESTClient1 := TRESTClient.Create(nil);
  RESTRequest1 := TRESTRequest.Create(nil);
  RESTResponse1 := TRESTResponse.Create(nil);
  RESTRequest1.Client := RESTClient1;
  RESTRequest1.Response := RESTResponse1;
  RESTClient1.BaseURL := 'viacep.com.br/ws/' + CEP + '/json/';
  RESTRequest1.Execute;
  obj := RESTResponse1.JSONValue as TJSONObject;
  try
    Result.CEP          := CEP;
    Result.Logradouro   := obj.Values['logradouro'].Value;
    Result.Bairro       := obj.Values['bairro'].Value;
    Result.Localidade   := obj.Values['localidade'].Value;
    Result.UF           := obj.Values['uf'].Value;
  finally
    obj.Free;
  end;
end;

end.
