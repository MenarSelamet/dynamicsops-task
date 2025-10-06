codeunit 50104 "DummyJSON API Manager"
{
    var
        CannotFindSetupErr: Label 'DummyJSON API Setup not found. Please configure it first.';
        CannotFindMappingErr: Label 'User mapping not found for customer %1. Please add a mapping in the Customer User Mapping setup.';
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
    begin
        if not APISetup.Get() then
            Error(CannotFindSetupErr);

        APISetup.Token := '';
        APISetup."Token Expiry" := 0DT;
        APISetup.Modify();

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

        Session.LogMessage('00001W', StrSubstNo('Login Response: %1', ResponseText),
            Verbosity::Normal, DataClassification::SystemMetadata,
            TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');

        if not Response.IsSuccessStatusCode then
            Error(APIRequestErr, StrSubstNo('%1: %2', Response.ReasonPhrase, ResponseText));

        if not JsonObject.ReadFrom(ResponseText) then
            Error(APIRequestErr, 'Invalid JSON response: ' + CopyStr(ResponseText, 1, 200));

        if not (TryGetTokenFromJson(JsonObject, 'token', Token) or
         TryGetTokenFromJson(JsonObject, 'accessToken', Token) or
         TryGetTokenFromJson(JsonObject, 'access_token', Token) or
         TryGetTokenFromJson(JsonObject, 'Token', Token)) then
            Error(APIRequestErr, 'Token not found in response.');

        APISetup.Token := Token;
        APISetup."Token Expiry" := CurrentDateTime() + 3600000; // 1 hour
        APISetup.Modify();

        exit(Token);
    end;

    local procedure TryGetTokenFromJson(JsonObject: JsonObject; FieldName: Text; var Token: Text): Boolean
    var
        JsonToken: JsonToken;
    begin
        if JsonObject.Get(FieldName, JsonToken) then begin
            Token := JsonToken.AsValue().AsText();
            if Token <> '' then begin
                Session.LogMessage('00001X', StrSubstNo('Found token in field: %1', FieldName),
                    Verbosity::Normal, DataClassification::SystemMetadata,
                    TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
                exit(true);
            end;
        end;
        exit(false);
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

        if (UserId < 1) or (UserId > 100) then begin
            Session.LogMessage('00001Z', StrSubstNo('Invalid UserId: %1. DummyJSON users range is 1-100.', UserId),
                Verbosity::Error, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
            Error('Invalid User ID. DummyJSON users range from 1 to 100.');
        end;

        Token := GetBearerToken();

        Request.Method := 'GET';
        Request.SetRequestUri(StrSubstNo('%1/users/%2', APISetup."Base URL", UserId));

        if Token <> '' then begin
            Request.GetHeaders(Headers);
            Headers.Add('Authorization', StrSubstNo('Bearer %1', Token));
        end;

        if not Client.Send(Request, Response) then
            Error(APIRequestErr, 'Could not connect to API');

        if not Response.IsSuccessStatusCode then begin
            Response.Content.ReadAs(ResponseText);
            Session.LogMessage('000020', StrSubstNo('API call failed for UserId %1: %2 - %3',
                UserId, Response.HttpStatusCode, ResponseText),
                Verbosity::Error, DataClassification::SystemMetadata,
                TelemetryScope::ExtensionPublisher, 'Category', 'DummyJSON');
            Error(APIRequestErr, StrSubstNo('%1 (User ID: %2)', Response.ReasonPhrase, UserId));
        end;

        Response.Content.ReadAs(ResponseText);

        if not JsonObject.ReadFrom(ResponseText) then
            Error(APIRequestErr, 'Invalid JSON response');

        CompanyName := '';
        if JsonObject.Get('company', JsonToken) then begin
            CompanyJson := JsonToken.AsObject();
            if CompanyJson.Get('name', JsonToken) then
                CompanyName := JsonToken.AsValue().AsText();
        end;

        IBAN := '';
        if JsonObject.Get('bank', JsonToken) then begin
            BankJson := JsonToken.AsObject();
            if BankJson.Get('iban', JsonToken) then
                IBAN := JsonToken.AsValue().AsText();
        end;

        exit((CompanyName <> '') or (IBAN <> ''));
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