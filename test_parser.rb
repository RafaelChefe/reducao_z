#coding: utf-8
#

require "test-unit"
require "./parser"
require "bigdecimal"

FIXED_FIELDS_HASH = { :cont_comp_deb_cred_cancelados => "0000",
                      :cont_especificos_rel_ger => "0" * 120,
                      :cont_operacaoes_nao_fiscais => "0" * 120,
                      :tot_parc_nao_sujeitos_icms => "0" * 392,
                      :tot_descontos_issqn => "0" * 14,
                      :modo => "00",
                      :pos_id => 0,
                      :store_chain_id => 0
                    }

class TestReductionZ < Test::Unit::TestCase

  def helper(text, redz)
    expected_result = redz.merge(FIXED_FIELDS_HASH)
    assert_equal expected_result, Parser.new.parse(text)
  end

  def test_cont_ordem_operacao
    helper("05/03/2013 19:09:14 COO:017936\n", { :cont_ordem_operacao => "017936", :data_hora_reducao => DateTime.new(2013, 3, 5, 19, 9, 14) } )
  end

  def test_sangria
    helper("29 Sangria : 0001 50,00\n", { :tot_sangria => "50,00" })
  end

  def test_data_movimento
    helper("MOVIMENTO DO DIA: 05/03/2013\n", { :data_movimento => Date.parse("05/03/2013") })
  end

  def test_cont_reducao_z
    helper("Contador de Reduções Z: 1330", { :cont_reducao_z => "1330" })
  end

  def test_cont_reinicio_operacao
    helper("Contador de Reinício de Operação: 004\n", { :cont_reinicio_operacao => "004" })
  end

  def test_cont_operacoes_nao_fiscais
    helper("Geral de Operação Não Fiscal: 005185\n", { :cont_geral_oper_nao_fiscais => "005185" })
  end

  def test_cont_comp_deb_cred
    helper("Comprovante de Crédito ou Débito: 0004\n", { :cont_comp_deb_cred => "0004" })
  end

  # venda bruta is in it's own test because of a weird bug
  def test_venda_bruta
    helper("VENDA BRUTA DIÁRIA: 1.446,12\n", { :venda_bruta => BigDecimal.new("1446.12") })
  end

  def test_contadores_restantes
    text = <<-EOS.gsub(/^\s+/, "")
      Geral de Operação Não-Fiscal Cancelada: 0000
      Geral de Relatório Gerencial: 001817
      Contador de Cupom Fiscal: 009792
      Cupom Fiscal Cancelado: 0003
      Contador de Fita Detalhe: 000000
      Comprovante Não Emitido: 0002
    EOS

    redz = {
      :cont_oper_nao_fiscais_canceladas =>  "0000",
      :cont_geral_rel_ger =>  "001817",
      :cont_cupom_fiscal =>  "009792",
      :cont_cupom_fiscal_cancelados =>  "0003",
      :cont_fita_detalhe_emitida =>  "000000",
      :cont_comp_deb_cred_nao_emitido => "0002"
    }

    helper(text, redz)
  end

  def test_totalizadores
    text = <<-EOS.gsub(/^\s+/, "")
      TOTALIZADOR GERAL: 1.533.200,46
      CANCELAMENTO ICMS: 278,00
      DESCONTO ICMS: 15,78
      Total de ISSQN: 0,00
      CANCELAMENTO ISSQN: 0,00
      ------------------
      ACRÉSCIMO ICMS: 0,00
      ACRÉSCIMO ISS: 0,00
      Isento ICMS: 369,35
      Não Incidência ICMS: 0,00
      Substituição Tributária ICMS: 0,00
      Isento ISSQN: 0,00
      Não Incidência ISSQN: 0,00
      30 Suprimento : 0001 50,00
      CANC NÃO-FISC: 0,00
      DESC NÃO-FISC: 0,00
      ACRE NÃO-FISC: 0,00
      Substituição Tributária ISSQN: 0,00
    EOS

    redz = {
      :tot_geral => "1.533.200,46",
      :tot_cancelamentos_icms => "278,00",
      :tot_descontos_icms => "15,78",
      :tot_acrescimos_issqn => "0,00",
      :tot_cancelamentos_issqn => "0,00",
      :tot_acrescimos_icms => "0,00",
      :tot_isencao_icms => "369,35",
      :tot_nao_incidencia_icms => "0,00",
      :tot_subst_trib_icms => "0,00",
      :tot_isencao_issqn => "0,00",
      :tot_nao_incidencia_issqn => "0,00",
      :tot_suprimento => "50,00",
      :tot_cancelamentos_nao_fiscais => "0,00",
      :tot_descontos_nao_fiscais => "0,00",
      :tot_acrescimos_nao_fiscais => "0,00",
      :tot_subst_trib_issqn => "0,00"
    }

    helper(text, redz)
  end

  def test_aliq_trib
    text = <<-EOS.gsub(/^\s+/, "")
      ----------ICMS----------
      Totalizador Base Cálculo( R$)       Imposto( R$)
      T07,00%                 0,00               11,11
      T12,00%                 0,00               22,22
      T25,00%                 0,00               33,33
      T17,00%               563,55               44,44
    EOS

    redz = { :aliq_trib => "0700120025001700000000000000000000000000000000000000000000000000",
             :tot_parciais_trib => "00000000001111000000000022220000000000333300000000004444000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000000" }

    helper(text, redz)
  end

  def test_params
    text = ""
    pos_id = 111
    store_chain_id = 222

    redz = { :pos_id => pos_id, :store_chain_id => store_chain_id }

    expected_result = FIXED_FIELDS_HASH.merge(redz)

    assert_equal expected_result, Parser.new.parse(text, pos_id, store_chain_id)
  end

end
