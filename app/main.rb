require 'sinatra'
require 'line/bot'
require 'dotenv/load'
require 'rest-client'
require './app/imports.rb'

$OBJS = [
  Nyokki.new,
  Gokabou.new,
  Anime::Answerer.new,
  Weather.new,
  WebDict::Answerer.new,
  Denippi.new,
  Tex.new,
  Pigeons.new,
  Dfl_search.new
]

def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV['LINE_CHANNEL_SECRET']
    config.channel_token = ENV['LINE_CHANNEL_TOKEN']
  }
end

def get_name(user_id)
  token = ENV['LINE_CHANNEL_TOKEN']
  uri = "https://api.line.me/v2/bot/profile/#{user_id}"

  begin
    res = RestClient.get uri, { :Authorization => "Bearer #{token}" }
    name = JSON.parse(res.body)['displayName']
  rescue => exception
    name = exception.message
  end

  return name
end

# Make reply for each case.
def reply(event)
  msg = event.message['text']
  user_id = event['source']['userId']
  name = get_name(user_id)
  puts "Message: #{msg}"
  puts "From:    #{user_id} (#{name})"
  return mk_reply(msg, user_id)
end

def mk_reply(msg, user_id)
  reply_text  = ''
  $reply_type = 'text'

  $OBJS.each do |obj|
    begin
      if ans = obj.answer(msg)
        reply_text = ans
        break
      end
    rescue => exception
      exception.message
      reply_text = "エラーおつｗｗｗｗｗｗ\n\n> #{exception}"
    end
  end

  reply_text = '' if user_id == ENV['MY_USER_ID'] && reply_text == '負けｗｗｗ'

  case $reply_type
  when 'text'
    reply = {
      type: 'text',
      text: reply_text
    }
  when 'image'
    reply = {
      type: 'image',
      originalContentUrl: reply_text,
      previewImageUrl: reply_text
    }
  end

  return reply
end

# Execute.
post '/callback' do
  body = request.body.read

  signature = request.env['HTTP_X_LINE_SIGNATURE']
  unless client.validate_signature(body, signature)
    error 400 do 'Bad Request' end
  end

  events = client.parse_events_from(body)
  events.each { |event|
    case event
    when Line::Bot::Event::Message
      case event.type
      when Line::Bot::Event::MessageType::Text
        client.reply_message(event['replyToken'], reply(event))
      when Line::Bot::Event::MessageType::Image, Line::Bot::Event::MessageType::Video
        response = client.get_message_content(event.message['id'])
        tf = Tempfile.open('content')
        tf.write(response.body)
      end
    end
  }

  'OK'
end
