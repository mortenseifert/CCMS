namespace D4P.CCMS.Connector;

using D4P.CCMS.Tenant;
using System.RestClient;

codeunit 62036 D4PBCAdminAPIClient
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        AdminRestClientFactory: Codeunit D4PBCAdminRestClientFactory;
        RestClient: Codeunit "Rest Client";
        CurrentTenantId: Guid;
        IsInitialized: Boolean;
        NotInitializedErr: Label 'Admin API Client is not initialized. Call SetTenant before making API requests.';

    procedure SetTenant(BCTenant: Record "D4P BC Tenant")
    begin
        if IsInitialized and (CurrentTenantId = BCTenant."Tenant ID") then
            exit;

        RestClient := AdminRestClientFactory.CreateRestClient(BCTenant);
        CurrentTenantId := BCTenant."Tenant ID";
        IsInitialized := true;
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

    procedure Post(Endpoint: Text; RequestBody: JsonObject; var Response: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Post(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        Response := HttpResponseMessage.GetContent().AsText();
    end;

    procedure Put(Endpoint: Text; RequestBody: JsonObject; var ResponseText: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Put(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := HttpResponseMessage.GetContent().AsText();
    end;

    procedure Patch(Endpoint: Text; RequestBody: JsonObject; var ResponseText: Text) Success: Boolean
    var
        HttpContent: Codeunit "Http Content";
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);

        HttpResponseMessage := RestClient.Patch(Endpoint, HttpContent.Create(RequestBody));
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := HttpResponseMessage.GetContent().AsText();
    end;

    procedure Delete(Endpoint: Text; var ResponseText: Text) Success: Boolean
    var
        HttpResponseMessage: Codeunit "Http Response Message";
    begin
        if not IsInitialized then
            Error(NotInitializedErr);
        HttpResponseMessage := RestClient.Delete(Endpoint);
        Success := HttpResponseMessage.GetIsSuccessStatusCode();
        ResponseText := HttpResponseMessage.GetContent().AsText();
    end;
}