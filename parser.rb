require "date"

REGEX = 0
TYPE = 1

class Parser

  def initialize
    @regexps = {
      :id => [/coo:\d{6}/im, :integer],
      :data_movimento => [/movimento do dia: \d{2}\/\d{2}\/\d{4}/im, :date],
      :cont_reducao_z => [/contador de reduções z:\s\d+/im, :string]
    }

    @reducao_z = {}
  end

  def get_value(line)
    line.to_s.split(":")[1].strip
  end

  def fix_type(value, type)
    case type
    when :integer
      return value.to_i
    when :date
      return Date.parse(value)      
    else
      value
    end
  end

  def parse_id(text)
    line = @regexps[:id][REGEX].match(text)

    @reducao_z[:id] = fix_type(get_value(line), @regexps[:id][TYPE])
  end

  def parse_data_movimento(text)
    line = @regexps[:data_movimento][REGEX].match(text)

    @reducao_z[:data_movimento] =
                    fix_type(get_value(line), @regexps[:data_movimento][TYPE])
  end

  def parse_cont_reduc_z(text)
    line = @regexps[:cont_reducao_z][REGEX].match(text)

    @reducao_z[:cont_reducao_z] =
                    fix_type(get_value(line), @regexps[:cont_reducao_z][TYPE])
  end

  def print_redz
    puts @reducao_z
  end

end
