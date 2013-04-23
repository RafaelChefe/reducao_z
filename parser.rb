require "date"

REGEX = 0
TYPE = 1

class Parser

  attr_reader :reducao_z

  def initialize
    @regexps = {
      :id => [/coo:\d{6}/im, :integer],
      :data_movimento => [/movimento do dia: \d{2}\/\d{2}\/\d{4}/im, :date],
      :cont_reducao_z => [/contador de reduções z:\s\d+/im, :string],
      :cont_reinicio_operacao => [/contador\s+de\s+reinício\s+de\s+operação:\s+\d+/im, :string],
      :cont_operacoes_nao_fiscais => [/geral de operação não fiscal: \d+/im, :string],
    }

    @reducao_z = {}
  end

  def fix_type(value, type)
    case type
    when :integer
      return value.to_i
    when :date
      return Date.parse(value)      
    when :string
      return value
    end
  end

  def parse(text)
    @regexps.each_key do |key|
      line = @regexps[key][REGEX].match(text)

      if line != nil
        # gets only the value from a pair like key: value
        value = line.to_s.split(":")[1].strip

        # converts to the appropriate type, based on the @regexps hash
        @reducao_z[key] = fix_type(value, @regexps[key][TYPE]) 
      end
    end
  end
end
