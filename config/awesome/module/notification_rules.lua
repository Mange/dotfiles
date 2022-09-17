local utils = require "utils"

local function handle(args)
  if
    args.appname == "Brave"
    and string.find(args.message, "^calendar.google.com\n")
  then
    args.timeout = 0
    args.urgency = "critical"
    return true
  end

  -- Spotify notifications are not important and should disappear quickly.
  if args.appname == "Spotify" then
    args.timeout = 2
    args.urgency = "low"
    return true
  end

  -- Brave notifications ad blocker; enable ad notifications for rewards but
  -- don't actually see them…
  -- Brave notifications all start with the URL of the website pushing the
  -- notification, which in the case of ads is no URL (represented with a
  -- single space character). For this reason, all ad notifications look like
  -- " \n\n<AD TEXT…>".
  if args.appname == "Brave" and string.find(args.message, "^ *\n\n") then
    args.title = "Adblock"
    args.message = ""
    args.timeout = 1
    args.urgency = "low"
    return false
  end

  -- Toasts should not be kept in the logs
  if args.category == "x-mange.toast" then
    return true
  end

  -- Log unhandled notifications so I have a chance of adding them to my rules here.
  -- Logging with depth 3+ will log binary icon data inside the log, which
  -- makes it hard to work with.
  if not utils.is_test() then
    utils.log("notifications", args, "unmatched notification", 2)
    utils.log("notifications", "")
    utils.log("notifications", "message:")
    utils.log("notifications", args.message)
    utils.log("notifications", "----")
  end

  return true
end

return {
  handle = handle,
}
