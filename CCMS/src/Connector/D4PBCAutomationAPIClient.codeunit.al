namespace D4P.CCMS.Connector;

using D4P.CCMS.Environment;
using D4P.CCMS.Tenant;
using System.RestClient;

codeunit 62037 D4PBCAutomationAPIClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AutomRestClientFactory: Codeunit D4PBCAutomRestClientFactory;
        RestClient: Codeunit "Rest Client";
        CurrentTenantId: Guid;
        EnvironmentName: Text[100];
        IsInitialized: Boolean;
        NotInitializedErr: Label 'Automation API Client is not initialized. Call SetTenant before making API requests.';

    procedure SetContext(BCTenant: Record "D4P BC Tenant"; BCEnvironment: Record "D4P BC Environment")
    begin
        if IsInitialized and (CurrentTenantId = BCTenant."Tenant ID") and (EnvironmentName = BCEnvironment.Name) then
            exit;

        EnvironmentName := BCEnvironment.Name;
        CurrentTenantId := BCTenant."Tenant ID";
        RestClient := AutomRestClientFactory.CreateRestClient(BCTenant, EnvironmentName);
        IsInitialized := true;
    end;

    procedure Get(Endpoint: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::GET, Endpoint, '', ResponseText));
    end;

    procedure Get(Endpoint: Text; var Response: JsonObject) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Get(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        Response := HttpResponseMessage.GetContent().AsJson().AsObject();
    end;

    procedure Post(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::POST, Endpoint, RequestBody, ResponseText));
    end;

    procedure Put(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::PUT, Endpoint, RequestBody, ResponseText));
    end;

    procedure Patch(Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::PATCH, Endpoint, RequestBody, ResponseText));
    end;

    procedure Delete(Endpoint: Text; var ResponseText: Text): Boolean
    begin
        exit(SendRequest("Http Method"::DELETE, Endpoint, '', ResponseText));
    end;

    local procedure SendRequest(Method: Enum "Http Method"; Endpoint: Text; RequestBody: Text; var ResponseText: Text): Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpRequestMessage: Codeunit "Http Request Message";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpRequestMessage.SetHttpMethod(Method);
        HttpRequestMessage.SetRequestUri(Endpoint);
        if RequestBody <> '' then
            HttpRequestMessage.SetContent(HttpContent.Create(RequestBody, 'application/json'));

        HttpResponseMessage := RestClient.Send(HttpRequestMessage);
        ResponseText := HttpResponseMessage.GetContent().AsText();

        exit(HttpResponseMessage.GetIsSuccessStatusCode());
    end;
}
