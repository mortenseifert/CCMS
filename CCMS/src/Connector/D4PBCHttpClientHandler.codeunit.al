namespace D4P.CCMS.Connector;

using System.RestClient;

codeunit 62033 D4PBCHttpClientHandler implements "Http Client Handler"
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        DebugMode: Boolean;
        DebugMsg: Label 'DEBUG - %1:\%2', Comment = '%1 = Action, %2 = Response body';

    procedure SetDebugMode(NewDebugMode: Boolean)
    begin
        DebugMode := NewDebugMode;
    end;

    procedure Send(CurrHttpClientInstance: HttpClient; HttpRequestMessage: Codeunit "Http Request Message"; var HttpResponseMessage: Codeunit "Http Response Message") Success: Boolean
    var
        RequestMessage: HttpRequestMessage;
        ResponseMessage: HttpResponseMessage;
    begin
        RequestMessage := HttpRequestMessage.GetHttpRequestMessage();
        Success := CurrHttpClientInstance.Send(RequestMessage, ResponseMessage);
        HttpResponseMessage.SetResponseMessage(ResponseMessage);

        if DebugMode then
            Message(DebugMsg, HttpRequestMessage.GetHttpMethod() + ' ' + HttpRequestMessage.GetRequestUri(), HttpResponseMessage.GetContent().AsText());
    end;
}
