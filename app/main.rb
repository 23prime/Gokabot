require 'sinatra'
require 'dotenv/load'
require 'rest-client'

require './app/src/push/push'
require './app/src/push/ramdom_push'
require './app/src/push/push_discord'
require_relative './response.rb'

get '/' do
  'Hello, gokabot!'
end

post '/callback' do
  body = request.body.read
  signature = request.env['HTTP_X_LINE_SIGNATURE']
  Response::Response.response(body, signature)
  'OK'
end

post '/push' do
  msg = params[:msg]
  target = params[:target]
  return 401 if msg.nil? || target.nil?
  return Push.send_push_msg(msg, target)
end

post '/push/random' do
  target = params[:target]
  return 401 if target.nil?
  return RamdomPush.send_push_msg(target)
end

post '/push/discord' do
  msg = params[:msg]
  return 401 if msg.nil?
  return 200 if PushDiscord.send_message(msg)
  return 500
end
