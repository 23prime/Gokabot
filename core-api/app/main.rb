require 'sinatra'
require 'dotenv/load'
require 'rest-client'

require_relative 'line/callback'
require_relative 'line/push'
require_relative 'line/ramdom_push'
require_relative 'discord/push'

get '/' do
  'Hello, gokabot!'
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Line::Callback::Callback.response(body, signature)
  return 200
end

post '/line/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Line::Callback::Callback.response(body, signature)
  return 200
end

post '/line/push' do
  msg = params[:msg]
  target = params[:target]
  return 401 if msg.nil? || target.nil?
  return Line::Push.new.send_push_msg(msg, target)
end

post '/line/push/random' do
  target = params[:target]
  return 401 if target.nil?
  return Line::RamdomPush.new.send_push_msg(target)
end

post '/discord/push' do
  msg = params[:msg]
  return 401 if msg.nil?
  return 200 if Discord::Push.new.send_message(msg)
  return 500
end
