#coding: utf-8

require "date"
require "bigdecimal"

REGEX = 0
TYPE = 1
MONEY_REGEX = /(\d+\.)*\d+,\d+/im
REGEX_OPTIONS = Regexp::IGNORECASE | Regexp::MULTILINE

class Parser

  def initialize
    # parsing information for each field, organized like this:
    # :field_key => [/regex/, :data_type]
    @fields_spec = {
      :id => [/coo:\d{6}/im, :integer],
      :data_movimento => [/movimento\s+do\s+dia:\s+\d{2}\/\d{2}\/\d{4}/im, :date],
      :cont_reducao_z => [/contador\s+de\s+reduções\s+z:\s+\d+/im, :string],
      :cont_reinicio_operacao => [/contador\s+de\s+reinício\s+de\s+operação:\s+\d+/im, :string],
      :cont_geral_oper_nao_fiscais => [/geral\s+de\s+operação\s+não\s+fiscal:\s+\d+/im, :string],
      :cont_comp_deb_cred => [/comprovante\s+de\s+crédito\s+ou\s+débito:\s+\d+/im, :string],
      :cont_oper_nao_fiscais_canceladas => [/geral\s+de\s+operação\s+não-fiscal\s+cancelada: \d+/im, :string],
      :cont_geral_rel_ger => [/geral\s+de\s+relatório\s+gerencial:\s+\d+/im, :string],
      :cont_cupom_fiscal => [/contador\s+de\s+cupom\s+fiscal:\s+\d+/im, :string],
      :cont_cupom_fiscal_cancelados => [/cupom\s+fiscal\s+cancelado:\s+\d+/im, :string],
      :cont_fita_detalhe_emitida => [/contador\s+de\s+fita\s+detalhe:\s+\d+/im, :string],
      :cont_comp_deb_cred_nao_emitido => [/comprovante\s+não\s+emitido:\s+\d+/im, :string],
      :tot_geral => [Regexp.new("totalizador\s+geral:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :venda_bruta => [Regexp.new("venda\s+bruta\s+diária:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :decimal],
      :tot_cancelamentos_icms => [Regexp.new("cancelamento\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_descontos_icms => [Regexp.new("desconto\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_acrescimos_issqn => [Regexp.new("acréscimo\s+iss:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_cancelamentos_issqn => [Regexp.new("cancelamento\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_acrescimos_icms => [Regexp.new("acréscimo\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_isencao_icms => [Regexp.new("isento\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_nao_incidencia_icms => [Regexp.new("não\s+incidência\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_subst_trib_icms => [Regexp.new("substituição\s+tributária\s+icms:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_isencao_issqn => [Regexp.new("isento\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string],
      :tot_nao_incidencia_issqn => [Regexp.new("não\s+incidência\s+issqn:\s+#{MONEY_REGEX}", REGEX_OPTIONS), :string]
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
    when :decimal
      # converting Brazilian money format to international format, as in:
      # 1.234,56 => 1234.56
      return BigDecimal.new(value.delete(".").gsub(",", "."))
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
