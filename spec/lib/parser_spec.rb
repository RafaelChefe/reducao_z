require "spec_helper"
require "parser"

FIXED_FIELDS_HASH = { :cont_comp_deb_cred_cancelados => "0000",
                      :cont_especificos_rel_ger => "0" * 120,
                      :cont_operacaoes_nao_fiscais => "0" * 120,
                      :tot_parc_nao_sujeitos_icms => "0" * 392,
                      :tot_descontos_issqn => "0" * 14,
                      :modo => "00",
                      :pos_id => 0,
                      :store_chain_id => 0
                    }

def helper(text, redz)
  expected_result = redz.merge(FIXED_FIELDS_HASH)
  expected_result.should == Parser.new.parse(text)
end

describe Parser do

  it "parses cont_ordem_operacao" do
    helper("05/03/2013 19:09:14 COO:017936\n", { :cont_ordem_operacao => "017936", :data_hora_reducao => DateTime.new(2013, 3, 5, 19, 9, 14) } )
  end

  it "parses sangria" do
    helper("29 Sangria : 0001 50,00\n", { :tot_sangria => "50,00" })
  end

  it "parses test_data_movimento" do
    helper("MOVIMENTO DO DIA: 05/03/2013\n", { :data_movimento => Date.parse("05/03/2013") })
  end

  it "parses test_cont_reducao_z" do
    helper("Contador de Reduções Z: 1330", { :cont_reducao_z => "1330" })
  end

  it "parses test_cont_reinicio_operacao" do
    helper("Contador de Reinício de Operação: 004\n", { :cont_reinicio_operacao => "004" })
  end

  it "parses test_cont_operacoes_nao_fiscais" do
    helper("Geral de Operação Não Fiscal: 005185\n", { :cont_geral_oper_nao_fiscais => "005185" })
  end

  it "parses test_cont_comp_deb_cred" do
    helper("Comprovante de Crédito ou Débito: 0004\n", { :cont_comp_deb_cred => "0004" })
  end

  # venda bruta is in it's own test because of a weird bug
  it "parses test_venda_bruta" do
    helper("VENDA BRUTA DIÁRIA: 1.446,12\n", { :venda_bruta => BigDecimal.new("1446.12") })
  end

  it "parses test_contadores_restantes" do
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

  it "parses test_totalizadores" do
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
end
