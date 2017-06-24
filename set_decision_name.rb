require 'json'

TXT_DIR = 'no_name_txt'
Encoding.default_external = 'UTF-8'

# set_call_names
class SetCallNames
  attr_accessor :decision_suffix
  def initialize
    @decision_suffix = JSON.parse(File.read('calls.json')).map{|k, v| [k, v["確定"]["末尾"]]}.to_h
    @decision_inline = JSON.parse(File.read('calls.json')).map{|k, v| [k, v["確定"]["文中"]]}.to_h
  end

  def execute
    dir_path = File.expand_path(TXT_DIR + '/**')
    Dir.glob(dir_path) { |filepath|
      txt = File.read(filepath)
      filename = File.basename(filepath)
      txt_lines = txt.each_line.map(&:chomp)

      txt_lines.each_with_index { |line, i|
        if line !~ /^[「【]/ then next end
        correct_user = get_correct_user(line)
        puts "#{filename} #{i} 【#{correct_user}】#{line}" if correct_user != nil
      }
    }
  end

  def get_correct_user(line)
    @decision_inline.each{ |user, words|
      if words.any?{ |n| line =~ /#{n}/ }
        return user
      end
    }

    @decision_suffix.each{ |user, words|
      if words.any?{ |n| line =~ /#{n}[、。」]/ }
        return user
      end
    }
    return nil
  end
end

SetCallNames.new.execute
