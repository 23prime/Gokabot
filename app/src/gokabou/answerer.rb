require 'dotenv/load'
require_relative './gen_msg.rb'
require_relative './update_db.rb'

module Gokabou
  class Answerer
    attr_accessor :help, :omikuji, :deads, :new_years

    def initialize
      @version = '1.0.0'
      @help = File.open('./docs/help', 'r').read
      @omikuji = File.open('./docs/omikuji', 'r').read.split("\n")

      @deads = [
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
        'いやでｗｗｗいやでござるｗｗｗ',
        'し、しにたくないでおぢゃる〜ｗｗｗ'
      ]

      @new_years = [
        'あけおめでつｗ',
        'Happy New Year でござるｗｗ',
        'は？',
        'ことよろチクビｗ',
        'あけおまんこｗｗｗｗｗｗ開帳くぱぁｗｗｗｗｗｗ',
        '今年はヒゲを剃りたい'
      ]

      @d = Time.now
      @month = @d.month
      @day = @d.day

      @ud = UpdateDB.new
      @gen = GenMsg.new(@ud.all_sentences)
    end

    def include_uri?(msg)
      splited = msg.split(/[[:space:]]/)
      splited.map! { |str| str =~ URI::DEFAULT_PARSER.regexp[:ABS_URI] }

      return splited.any?
    end

    def updatable(msg, user_id)
      gid = ENV['GOKABOU_USER_ID']

      unless user_id == gid && msg.length > 4 && msg.length <= 300
        return false
      end

      return false if include_uri?(msg)
      return !@ud.all_sentences.include?(msg)
    end

    def answer(*msg_data)
      msg = msg_data[0]
      user_id = msg_data[1]

      if updatable(msg, user_id)
        @ud.update_db(msg, user_id)
        @gen.update_dict(msg)
      end

      case msg
      when /\Aこん(|です)(|ｗ|w)\Z/i
        return 'こん'
      when /死ね|死んで/
        return @deads.sample
      when /行く/
        return '俺もイク！ｗ'
      when /\Agokabot[[:blank:]]+(-v|--version)\Z/
        return @version
      when /\Agokabot[[:blank:]]+(-h|--help)\Z/
        return @help
      when /ごかぼっと|gokabot|ごかぼう|gokabou|\Aヒゲ\Z|\Aひげ\Z/
        return @gen.gen_ans
      when /\Aおみくじ\Z/
        return @omikuji.sample
      when /たけのこ(君|くん|さん|ちゃん|)/
        return 'たけのこ君ｐｒｐｒ'
      when /\Aぬるぽ\Z/
        return 'ｶﾞｯ'
      when /あけ|明け|おめ|こん|おは|happy|new|year|2019/i
        return @new_years.sample if @month == 1 && @day == 1
      else
        return nil
      end
    end
  end
end
