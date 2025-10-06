codeunit 50103 "DummyJSON Debug Helper"
{
    procedure DebugLoginResponse()
    var
        APISetup: Record "DummyJSONAPISetup";
        Client: HttpClient;
        Request: HttpRequestMessage;
        Response: HttpResponseMessage;
        Content: HttpContent;
        Headers: HttpHeaders;
        RequestBody: Text;
        ResponseText: Text;
        JsonObject: JsonObject;
        JsonToken: JsonToken;
        i: Integer;
        KeyName: Text;
        KeyValue: Text;
    begin
        if not APISetup.Get() then
            exit;

        RequestBody := StrSubstNo('{"username":"%1","password":"%2"}', APISetup.Username, APISetup.Password);
        Content.WriteFrom(RequestBody);
        Content.GetHeaders(Headers);
        Headers.Clear();
        Headers.Add('Content-Type', 'application/json');

        Request.Method := 'POST';
        Request.SetRequestUri(APISetup."Base URL" + '/auth/login');
        Request.Content := Content;

        if Client.Send(Request, Response) then begin
            Response.Content.ReadAs(ResponseText);

            if JsonObject.ReadFrom(ResponseText) then begin
                KeyValue := StrSubstNo('Status: %1\\n\\nFull Response:\\n%2\\n\\nJSON Properties:\\n',
                              Response.HttpStatusCode, ResponseText);

                if JsonObject.Get('token', JsonToken) then
                    KeyValue += StrSubstNo('token: %1\\n', JsonToken.AsValue().AsText());
                if JsonObject.Get('accessToken', JsonToken) then
                    KeyValue += StrSubstNo('accessToken: %1\\n', JsonToken.AsValue().AsText());
                if JsonObject.Get('access_token', JsonToken) then
                    KeyValue += StrSubstNo('access_token: %1\\n', JsonToken.AsValue().AsText());
                if JsonObject.Get('Token', JsonToken) then
                    KeyValue += StrSubstNo('Token: %1\\n', JsonToken.AsValue().AsText());

                Message(KeyValue);
            end else begin
                Message('Status: %1\\n\\nResponse (non-JSON):\\n%2', Response.HttpStatusCode, ResponseText);
            end;
        end else begin
            Message('Failed to send request');
        end;
    end;
}