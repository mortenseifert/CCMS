namespace D4P.CCMS.Connector;

using D4P.CCMS.Tenant;

codeunit 62003 D4PBCAccessTokenHandler
{
    SingleInstance = true;

    var
        BearerCache: Dictionary of [Guid, SecretText];
        CurrentTenantId: Guid;

    procedure SetTenant(TenantId: Guid)
    begin
        CurrentTenantId := TenantId;
    end;

    procedure GetAccessToken() AccessToken: SecretText
    begin
        // TODO : Timeout
        if BearerCache.ContainsKey(CurrentTenantId) then
            exit(BearerCache.Get(CurrentTenantId));

        AcquireAccessToken(AccessToken);
        BearerCache.Add(CurrentTenantId, AccessToken);
        exit(AccessToken);
    end;

    local procedure AcquireAccessToken(var AccessToken: SecretText)
    var
        D4PBCTenant: Record "D4P BC Tenant";
        Content: HttpContent;
        AccessTokenClient: HttpClient;
        Headers: HttpHeaders;
        Response: HttpResponseMessage;
        ResponseJson: JsonObject;
        ResponseBody: Text;
        ContentBodyTok: Label 'grant_type=client_credentials&client_id=%1&client_secret=%2&scope=https%3A%2F%2Fapi.businesscentral.dynamics.com%2F.default', Locked = true, Comment = 'Content body for access token request, %1 = client ID, %2 = client secret';
    begin
        GetBCTenant(D4PBCTenant, CurrentTenantId);
        Content.WriteFrom(SecretStrSubstNo(ContentBodyTok, Format(D4PBCTenant."Client ID", 0, 4), D4PBCTenant.GetClientSecret()));
        Content.GetHeaders(Headers);
        if Headers.Contains('Content-Type') then
            Headers.Remove('Content-Type');
        Headers.Add('Content-Type', 'application/x-www-form-urlencoded');
        AccessTokenClient.Post('https://login.microsoftonline.com/' + Format(CurrentTenantId, 0, 4) + '/oauth2/v2.0/token', Content, Response);

        if not Response.IsSuccessStatusCode() then
            Error('Failed to acquire access token.\Status code: %1\%2', Response.HttpStatusCode(), Response.ReasonPhrase());

        Response.Content().ReadAs(ResponseBody);
        ResponseJson.ReadFrom(ResponseBody);
        AccessToken := 'Bearer ' + ResponseJson.GetText('access_token');
    end;

    local procedure GetBCTenant(var BCTenant: Record "D4P BC Tenant"; TenantId: Guid)
    begin
        BCTenant.SetRange("Tenant ID", TenantId);
        BCTenant.FindFirst();
    end;
}