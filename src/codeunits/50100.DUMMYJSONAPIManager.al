codeunit 50104 "DummyJSON API Manager"
{
    var
        CannotFindSetupErr: Label 'DummyJSON API Setup not found. Please configure it first.';
        CannotFindMappingErr: Label 'User mapping not found for customer %1.';
        APIRequestErr: Label 'API request failed: %1';

    procedure GetBearerToken(): Text
    var
        APISetup: Record "DummyJSONAPISetup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestBody: Text;
        ResponseText: Text;
        JsonToken: JsonToken;
        JsonObject: JsonObject;
        Token: Text;
        JObject: JsonObject;
    begin
        if not APISetup.Get() then
            Error(CannotFindSetupErr);

        if not APISetup."Use Authentication" then
            exit('');

        if (APISetup.Token <> '') and (CurrentDateTime() < (APISetup."Token Expiry" - 300000)) then
            exit(APISetup.Token);

        RequestBody := StrSubstNo('{"username":"%1","password":"%2"}', APISetup.Username, APISetup.Password);
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.Method := 'POST';
        Request.SetRequestUri(APISetup."Base URL" + '/auth/login');
        Request.Content := Content;

        if not Client.Send(Request, Response) then
            Error(APIRequestErr, 'Could not connect to API');

        Response.Content.ReadAs(ResponseText);

        if not Response.IsSuccessStatusCode then begin
            Session.LogMessage('00001T', StrSubstNo('Login failed: %1 - Response: %2',
                Response.ReasonPhrase, ResponseText), Verbosity::Error,
                DataClassification::SystemMetadata, TelemetryScope::ExtensionPublisher,
                'Category', 'DummyJSON');
            Error(APIRequestErr, StrSubstNo('%1 - Response: %2', Response.ReasonPhrase, ResponseText));
        end;

        if not JsonObject.ReadFrom(ResponseText) then
            Error(APIRequestErr, 'Invalid JSON response: ' + CopyStr(ResponseText, 1, 100));

        if JsonObject.Get('token', JsonToken) then
            Token := JsonToken.AsValue().AsText()
        else if JsonObject.Get('accessToken', JsonToken) then
            Token := JsonToken.AsValue().AsText()
        else if JsonObject.Get('access_token', JsonToken) then
            Token := JsonToken.AsValue().AsText()
        else begin

            Session.LogMessage('00001U', StrSubstNo('Token not found in response. Full response: %1',
                ResponseText), Verbosity::Error, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
            Error(APIRequestErr, 'Token not found in response. Check API documentation.');
        end;

        if Token = '' then
            Error(APIRequestErr, 'Empty token received');

        APISetup.Token := Token;
        APISetup."Token Expiry" := CurrentDateTime() + 3600000;
        APISetup.Modify();

        exit(Token);
    end;

    procedure GetUserData(UserId: Integer; var CompanyName: Text; var IBAN: Text): Boolean
    var
        APISetup: Record "DummyJSONAPISetup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Headers: HttpHeaders;
        ResponseText: Text;
        JsonObject: JsonObject;
        CompanyJson: JsonObject;
        BankJson: JsonObject;
        JsonToken: JsonToken;
        Token: Text;
    begin
        if not APISetup.Get() then
            Error(CannotFindSetupErr);

        if APISetup."Use Authentication" then
            Token := GetBearerToken()
        else
            Token := '';

        Token := GetBearerToken();

        Request.Method := 'GET';
        Request.SetRequestUri(StrSubstNo('%1/users/%2', APISetup."Base URL", UserId));
        Request.GetHeaders(Headers);
        Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));

        if not Client.Send(Request, Response) then
            Error(APIRequestErr, 'Could not connect to API');

        if not Response.IsSuccessStatusCode then
            Error(APIRequestErr, Response.ReasonPhrase);

        Response.Content.ReadAs(ResponseText);

        if not JsonObject.ReadFrom(ResponseText) then
            Error(APIRequestErr, 'Invalid JSON response');

        if JsonObject.Get('company', JsonToken) then begin
            CompanyJson := JsonToken.AsObject();
            if CompanyJson.Get('name', JsonToken) then
                CompanyName := JsonToken.AsValue().AsText();
        end;

        if JsonObject.Get('bank', JsonToken) then begin
            BankJson := JsonToken.AsObject();
            if BankJson.Get('iban', JsonToken) then
                IBAN := JsonToken.AsValue().AsText();
        end;

        exit((CompanyName <> '') or (IBAN <> ''));
        if Token <> '' then
            Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));

    end;

    procedure GetUserIdFromCustomer(CustomerNo: Code[20]): Integer
    var
        CustomerUserMapping: Record "CustomerUserMapping";
    begin
        if CustomerUserMapping.Get(CustomerNo) then
            exit(CustomerUserMapping."DummyJSON User Id");

        Error(CannotFindMappingErr, CustomerNo);
    end;
}