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
            Message('Response: %1\\n\\nStatus: %2', ResponseText, Response.HttpStatusCode);
        end else begin
            Message('Failed to send request');
        end;
    end;
}