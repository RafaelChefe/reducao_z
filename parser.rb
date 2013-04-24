require "date"

REGEX = 0
TYPE = 1

class Parser

  def initialize
    # parsing information for each field, organized like this:
    # :field_key => [/regex/, :data_type]
    @fields_spec = {
      :id => [/coo:\d{6}/im, :integer],
      :data_movimento => [/movimento do dia: \d{2}\/\d{2}\/\d{4}/im, :date],
      :cont_reducao_z => [/contador de reduções z:\s\d+/im, :string],
      :cont_reinicio_operacao => [/contador\s+de\s+reinício\s+de\s+operação:\s+\d+/im, :string],
      :cont_operacoes_nao_fiscais => [/geral de operação não fiscal: \d+/im, :string],
      :cont_comp_deb_cred => [/comprovante de crédito ou débito: \d+/im, :string]
    }
  end

  # converts a string to the given data type
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
    reducao_z = Hash.new

    # for each field specified in @fields_spec
    @fields_spec.each_key do |key|

      # matches the corresponding line using the specified regex
      line = @fields_spec[key][REGEX].match(text)

      if line != nil
        # extracts only the value from the matched line (after the ":")
        value = line.to_s.split(":")[1].strip

        # converts to the specified data type
        reducao_z[key] = fix_type(value, @fields_spec[key][TYPE]) 
      end
    end

    reducao_z
  end
end
