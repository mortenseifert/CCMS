namespace D4P.CCMS.Connector;

using D4P.CCMS.Setup;
using D4P.CCMS.Tenant;
using System.RestClient;
using System.Security.Authentication;

codeunit 62035 D4PBCAutomRestClientFactory
{
    Access = Internal;
    InherentEntitlements = X;
    InherentPermissions = X;

    var
        OAuthTokenEndpointTxt: Label 'https://login.microsoftonline.com/%1/oauth2/v2.0/token', Comment = 'OAuth token endpoint, %1 = tenant ID';

    procedure CreateRestClient(BCTenant: Record "D4P BC Tenant"; EnvironmentName: Text): Codeunit "Rest Client"
    var
        BCSetup: Record "D4P BC Setup";
        HttpClientHandler: Codeunit D4PBCHttpClientHandler;
        RestClient: Codeunit "Rest Client";
    begin
        BCSetup := BCSetup.GetSetup();
        HttpClientHandler.SetDebugMode(BCSetup."Debug Mode");
        RestClient := RestClient.Create(HttpClientHandler, GetOAuthCredentials(BCTenant));
        RestClient.SetBaseAddress(BCSetup.GetAutomationAPIBaseUrl() + '/' + EnvironmentName);
        exit(RestClient);
    end;

    local procedure GetOAuthCredentials(BCTenant: Record "D4P BC Tenant") HttpAuthOAuthClientCredentials: Codeunit HttpAuthOAuthClientCredentials
    var
        Scopes: List of [Text];
        TenantID: Text;
        TokenEndpointUrl: Text;
    begin
        TenantID := Format(BCTenant."Tenant ID", 0, 4).ToLower();
        TokenEndpointUrl := OAuthTokenEndpointTxt.Replace('%1', TenantID);
        Scopes.Add('https://api.businesscentral.dynamics.com/.default');
        HttpAuthOAuthClientCredentials.Initialize(TokenEndpointUrl, BCTenant."Client ID", BCTenant.GetClientSecret(), Scopes);
    end;
}
