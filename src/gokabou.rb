$VERSION = '1.0.0'
$HELP = File.open('./docs/help', 'r').read
$OMIKUJI = File.open('./docs/omikuji', 'r').read.split("\n")
$TWEETS = File.open('./docs/gokabou_tweets', 'r').read.split("\n")
$DEADS = [
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


class Gokabou
  def answer(msg)
    case msg
    when /死ね|死んで/
      return $DEADS.sample
    when /行く/
      return '俺もイク！ｗ'
    when /^gokabot[[:blank:]]+(-v|--version)$/
      return $VERSION
    when /^gokabot[[:blank:]]+(-h|--help)$/
      return $HELP
    when /^ごかぼっと$|^gokabot$/
      return 'なんですか？'
    when /^ごかぼう$|^gokabou$|^ヒゲ$|^ひげ$/
      return $TWEETS.sample
    when /^おみくじ$/
      return $OMIKUJI.sample
    when /^たけのこ(君|くん|さん|)$/
      return 'たけのこ君ｐｒｐｒ'
    when /^ぬるぽ$/
      return 'ｶﾞｯ'
    else
      return nil
    end
  end
end