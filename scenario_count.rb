require 'json'

TXT_DIR = 'txt'
Encoding.default_external = 'UTF-8'

# Scenario
class ScenarioCount
  attr_accessor :dics

  def execute
    # 結果リスト
    @dics = {}

    # 検査対象テキスト読み込み
    dir_path = File.expand_path(TXT_DIR + '/**')
    Dir.glob(dir_path) { |filepath|
      txt = File.read(filepath)
      filename = File.basename(filepath)
      txt_lines = txt.each_line.map(&:chomp)

      txt_lines.each_with_index { |line, i|
        if line == '' then next end
        call_check(line, i, filename)
      }
    }

    # 結果を表示
    @dics.each{ |user, serif|
      puts "【#{user}】 #{serif.length}"
    }
  end

  # セリフカウント
  def call_check(line, i, filename)
    if line =~ /^(.*?)「(.*?)」$/
      user = $1
      serif = $2
      if @dics.has_key?($1)
        @dics[$1].push($2)
      else
        @dics.store($1, [$2])
      end
      return
    elsif line =~ /^(.*?)『(.*?)』$/
      user = $1
      serif = $2
      if @dics.has_key?($1)
        @dics[$1].push($2)
      else
        @dics.store($1, [$2])
      end
      return
    end
  end
end

ScenarioCount.new.execute
