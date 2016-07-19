json.success true

json.tokens do
    json.auth_token @token.token
    json.diagnostics_sync_token @token.diagnostics_sync_token
end

json.user do
    json.name  @user.name
    json.email @user.email
    json.id    @user.id
end
