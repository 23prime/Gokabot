# coding: utf-8
require 'sinatra'
require 'line/bot'
require 'date'
require './app/imports.rb'


$version = '1.0.0'
$help = File.open('./docs/help', 'r').read
$all_animes = File.open('./docs/18summer.yaml', 'r').read
$omikuji = File.open('./docs/omikuji', 'r').read.split("\n")
$gokabou = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
$deads = [
  'いや、死なないよ。',
  '死ぬ〜〜〜〜〜ｗ', 
  '死んだｗ',
  'おいおい…',
  '死んダダダダダダーン',
  '人に死ねなんて言葉使うな😡',
  '死ぬまで死なないよ',
  '死ねのバーゲンセールかよ',
  'きみ、死ねしか言えないの？',
  'そっちからリプ送ってきて死ねっつうな！死ね！しねしねこうせん！💨',
  'いやでｗｗｗいやでござるｗｗｗ'
]
$web_dict = WebDict::Answerer.new()


def client
  @client ||= Line::Bot::Client.new { |config|
    config.channel_secret = ENV["LINE_CHANNEL_SECRET"]
    config.channel_token = ENV["LINE_CHANNEL_TOKEN"]
  }
end


# Make reply for each case.
def reply(event)
  msg = event.message['text']
  mk_reply(msg)
end


def mk_reply(msg) 
  rep_text  = ''
  msg       = Anime.convert(msg)
  msg_split = msg.split(/[[:blank:]]+/)
  msg0      = msg_split[0]
  wdays     = %w[Sun Mon Tue Wed Thu Fri Sat]
  d         = Date.today.wday

  if Nyokki.stat > 0 || msg =~ /(1|１)(ニョッキ|にょっき|ﾆｮｯｷ)/
    rep_text = Nyokki.nyokki(msg)
  elsif ans = $web_dict.answer(msg)
    rep_text = ans
  elsif ['All', 'Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'].include?(msg)
    rep_text = Anime.filter($all_animes, msg)
  elsif msg =~ /死ね|死んで/
    rep_text = $deads.sample
  elsif msg =~ /行く/
    rep_text = '俺もイク！ｗ'
  elsif msg =~/^.$/
    rep_text = Denippi.monyo_chk(msg)
  elsif
    case msg0
    when '天気', '今日の天気', '明日の天気'
      rep_text = Weather.weather(msg0, msg_split[1])
    end
  else
    case msg
    when 'gokabot -v', 'gokabot --version'
      rep_text = $version
    when 'gokabot -h', 'gokabot --help'
      rep_text = $help
    when 'ごかぼっと', 'gokabot'
      rep_text = 'なんですか？'
    when 'ごかぼう', 'gokabou', 'ヒゲ', 'ひげ'
      rep_text = $gokabou.sample
    when '昨日のアニメ', '昨日', 'yesterday'
      rep_text = Anime.filter($all_animes, wdays[d - 1])
    when '今日のアニメ', '今日', 'today'
      rep_text = Anime.filter($all_animes, wdays[d])
    when '明日のアニメ', '明日', 'tomorrow'
      rep_text = Anime.filter($all_animes, wdays[(d + 1) % 7])
    when 'おみくじ'
      rep_text = $omikuji.sample
    when 'たけのこ'
      rep_text = 'たけのこ君ｐｒｐｒ'
    when 'ぬるぽ'
      rep_text = 'ｶﾞｯ'
    end
  end

  reply = {
    type: 'text',
    text: rep_text
  }
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
