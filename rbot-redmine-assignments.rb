# coding: utf-8

# Redmine issue information for rbot
#
# by Martin Bagge / brother <brother@bsnet.se>
#
# License: WTFPL

require 'open-uri'
require 'json'

class RedmineAssigneeLookup < Plugin

  Config.register Config::StringValue.new('redmine.host',
                                          :default => 'http://localhost',
                                          :desc => _('Domain URL with URI scheme.'))
  Config.register Config::ArrayValue.new('redmine.channels',
                                         :default => ['#kaos'],
                                         :desc => "The channels where the bot will listen (and reply).")
  Config.register Config::IntegerValue.new('redmine.nbrofassignments',
                                           :default => 5,
                                           :desc => "Maximum number of assigned tickets to show per user.")
  Config.register Config::StringValue.new('redmine.botuser',
                                          :default => "morpheus",
                                          :desc => "The Redmine administrator user the bot uses to fetch user information. !config set redmine.botuser")
  Config.register Config::StringValue.new('redmine.botuserpassword',
                                          :desc => "Password for the Redmine administor. !config set redmine.botuserpassword.")


  def help(plugin, topic="")
    "Activate your REST API in Redmine. Configure host to read from and channel(s) to watch. See !config list redmine."
  end

  def assignedto(m, params)
    if !params[:user]
      params[:user] = m.sourcenick
    end
    uname = params[:user]

    host = @bot.config['redmine.host']
    botuser = @bot.config['redmine.botuser']
    botuserpassword = @bot.config['redmine.botuserpassword']

    unless @bot.config['redmine.channels'].include?(m.channel.to_s)
      return nil
    end

    if !botuser
      m.reply "No Redmine user added. Aborting."
    end
    if !botuserpassword
      m.reply "No password for Redmine user added. Aborting. See !config list redmine."
    end

    data = JSON.parse(
      open(host + "/users.json?name="+uname, http_basic_authentication:
                                               [botuser, botuserpassword]
          ).read()
    )

    # Because the user fetch above is a bit fuzzy (matches in login,
    # firstname, lastname and mail and can thus fetch more than one
    # user...) we need to narrow the hit to exactly one user.
    userid = ""
    if data["total_count"] < 1
      m.reply "nope"
    else
      data["users"].each do |u|
        if u["login"].to_s == uname
          userid = u["id"].to_i()
          break
        end
      end
      if userid < 1
        m.reply "no perfect match"
        return nil
      end
    end

    # Fetch all issues the user is assigned to
    data = JSON.parse(open(host + "/issues.json?assigned_to_id="+userid.to_s()).read())

    if data["total_count"] > 0
      if data["total_count"] > @bot.config["redmine.nbrofassignments"]
        m.reply uname + " have " + data["total_count"].to_s + " issues assigned. Will only show first " + @bot.config["redmine.nbrofassignments"].to_s + "."
      end
      k = @bot.config["redmine.nbrofassignments"]
      data["issues"].each do |i|
        m.reply i["project"]["name"] + ": #" + i["id"].to_s + " " + i["subject"] + " (" + i["status"]["name"] + ")"

        k -= 1
        if k == 0
          break
        end
      end
    else
      m.reply "No issues assigned."
    end

  end

end

ral = RedmineAssigneeLookup.new
ral.register("issueassign")
ral.map "tickets", :action => "assignedto"
ral.map "tickets :user", :action => "assignedto"
