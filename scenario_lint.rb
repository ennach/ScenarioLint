require 'json'

TXT_DIR = 'txt'
Encoding.default_external = 'UTF-8'

# Scenario
class ScenarioLint
  attr_accessor :calls, :prohibit_words

  # 呼称表と禁止語句読み込み
  def initialize
    @calls = JSON.parse(File.read('calls.json'))
    @prohibit_words = File.read('prohibit_words.txt').each_line.map(&:chomp).select{|n| n != '' }
  end

  def execute
    # 検査対象テキスト　読み込み
    dir_path = File.expand_path(TXT_DIR + '/**')
    Dir.glob(dir_path) { |filepath|
      txt = File.read(filepath)
      filename = File.basename(filepath)
      txt_lines = txt.each_line.map(&:chomp)

      txt_lines.each_with_index { |line, i|
        if line == '' then next end

        # 禁止語句チェック
        prohibit_check(line, i, filename)

        # 呼称ミスチェック
        call_check(line, i, filename)

        # その他チェック（文字数上限など）
        other_check(line, i, filename)
      }
    }
  end

  def prohibit_check(line, i, filename)
      @prohibit_words.each { |word|
        if line.include?(word)
          puts "#{filename} #{i+1} 禁止語句'#{word}'"
        end
      }
  end

  # 呼称チェック
  def call_check(line, i, filename)
  #  if line =~ /^(.*?),「(.*?)」$/
    if line =~ /^(.*?)「(.*?)」$/
      user = $1
      serif = $2
      call_check_core(user, serif, filename, i)
    end
  end

  def call_check_core(user, serif, filename, i)
    user_call = @calls[user]
    if user_call == nil then return end

    correct_list = user_call["正"]
    miss_list = user_call["否"]

    correct_list.each{ |name, call|
      miss_call = miss_list[name]
      if (miss_call == nil) then next end
      miss = miss_call.select{|n| serif.include?(n) }
      if(miss.any?{|n|  !call.include?(n)})
        puts "#{filename} #{i+1} 呼称ミス 【#{user}】'#{miss} ' (#{serif})"
      end
    }
  end

  def monologue_check(line, i, filename)
      if !is_serif(line) && line !~ /^[　]/
        puts "#{filename} #{i+1} 行頭字下げがありません。"
      end
  end

  def other_check(line, i, filename)
    if line =~ /^「/
       puts "#{filename} #{i+1} '「'から始まっています（発言者名がありません）。"
    end
    if line.length > 100
      puts "#{filename} #{i+1} 100文字を超えています。(#{line.length})"
    end
    # if !is_serif(line) && line !~ /^[\/　]/
    #   puts "#{filename} #{i+1} 開始文字違反。(#{line})"
    # end
  end

  def is_serif(line)
    # return line =~ /^(.*,)「/ || line =~ /^(.*,)『/
    return line =~ /^(.*)「/ || line =~ /^(.*)『/
  end
end

ScenarioLint.new.execute
