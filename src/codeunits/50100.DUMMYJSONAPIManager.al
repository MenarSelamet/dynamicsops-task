codeunit 50100 "DummyJSON API Manager"
{
    procedure GetRandomCompanyName(): Text
    var
        Client: HttpClient;
        Response: HttpResponseMessage;
        Content: Text;
        JsonObject: JsonObject;
        JsonArray: JsonArray;
        JsonToken: JsonToken;
        CompanyObject: JsonObject;
        CompanyName: Text;
        RandomIndex: Integer;
        UserObject: JsonObject;

    begin
        if not Client.Get('Https://dummyjson.com/users', Response) then Error('Failed to call DummyJSON API');
        if not Response.IsSuccessStatusCode() then Error('API returned error:%1', Response.HttpStatusCode);
        Response.Content().ReadAs(Content);


        if not JsonObject.ReadFrom(Content) then Error('Could not read JSON response');
        if JsonObject.Get('users', JsonToken) then begin
            JsonArray := JsonToken.AsArray();

            RandomIndex := Random(JsonArray.Count());

            if JsonArray.Get(RandomIndex, JsonToken) then begin
                UserObject := JsonToken.AsObject();

                if UserObject.Get('company', JsonToken) then
                    CompanyObject := JsonToken.AsObject();
                if CompanyObject.Get('name', JsonToken) then
                    CompanyName := JsonToken.AsValue().AsText();
            end;
        end;

        exit(CompanyName);

    end;

}