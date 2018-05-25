local resty_redis_connector = require "resty.redis.connector"
local string = require "string"

local M = {}
local redis_connector

M.init = function()
    redis_connector = assert(resty_redis_connector.new{url = "redis://redis:6379/0"})
end

local redis_auth = function(user, pass)
    -- return nil, "Failed to authorize"
    local isok = false
    
    local redis = assert(redis_connector:connect())
    local expected = redis:get(user)
    if expected ~= ngx.null and expected == pass then
        isok = true
    end
    
    redis_connector:set_keepalive(redis)
    return isok
end

local get_user_pass = function(auth)
    if auth then
        local userpass_base64 = string.match(auth, "Basic ([a-zA-Z0-9=]+)")
        if userpass_base64 then
            local userpass = ngx.decode_base64(userpass_base64)
            if userpass then
                local user, pass = string.match(userpass, "(%a+):(%a+)")
                if user and pass then
                    return user, pass
                end
            end
        end
    end
end

M.proxy_access = function()
    local headers = ngx.req.get_headers()
    local auth = headers["Authorization"]
    local user, pass = get_user_pass(auth)
    local res, err = redis_auth(user, pass)
    if res == true then
        ngx.req.set_header("X-User", user)
        ngx.exit(ngx.OK)
    elseif res == nil then
        ngx.res.status = 500
        ngx.say("Internal server error: " .. (err and err or 'nil'))
    end
    ngx.header["WWW-Authenticate"] = "Basic"
    return ngx.exit(ngx.HTTP_UNAUTHORIZED)
end

M.backend = function()
  ngx.header["Content-Type"] = "text/raw"
  local headers = ngx.req.get_headers()
  ngx.say("Backend")
  ngx.say("X-User: ", headers["X-User"])
end

return M