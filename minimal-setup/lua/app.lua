local resty_redis_connector = require "resty.redis.connector"
local string = require "string"

local M = {}
local redis_connector

M.init = function()
    redis_connector = assert(resty_redis_connector.new{url = "redis://redis:6379/0"})
end

M.api = function()
    ngx.say("Api v1.0")
end

return M