#!/usr/bin/env ruby
require 'bundler'
require 'rubygems'
Bundler.require

require 'json'

class PivotalStories < Thor
  desc 'list', '終了したストーリの一覧を取得します'
  option :project_id, require: true, aliases: :p
  option :token, require: true, aliases: :t
  option :accepted_after, aliases: :d
  option :created_after, aliases: :c
  option :state, default: 'accepted', aliases: :s
  def list
    project_id = options[:project_id]
    token = options[:token]

    con = Faraday.new(url: 'https://www.pivotaltracker.com/services/v5/')
    res = con.get "projects/#{project_id}/stories" do |req|
      req.headers['X-TrackerToken'] = token
      req.params[:with_state] = options[:state]
      req.params[:accepted_after] = iso8601(options[:accepted_after]) if options[:accepted_after]
      req.params[:created_after] = iso8601(options[:created_after]) if options[:created_after]
    end

    JSON.parse(res.body).each do |story|
      if options[:state] == 'accepted'
        puts "- #{Date.parse(story['accepted_at'])} [#{story['name']}](#{story['url']}) #{story['estimate']} "
      else
        puts "- #{story['estimate']} [#{story['name']}](#{story['url']})"
      end
    end
  end

  private

  def iso8601(date)
    Date.parse(date).to_time.iso8601
  end
end

PivotalStories.start(ARGV)
