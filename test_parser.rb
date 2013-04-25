require "test-unit"
require "./parser"

class TestReductionZ < Test::Unit::TestCase

  def setup
    # a small hack to remove leading whitespace
    @text = <<-EOS.gsub(/^\s+/, "")
      ------------------------------------------------
      05/03/2013 19:09:14 COO:017936
      ------------------------------------------------
      REDUÇÃO Z
      MOVIMENTO DO DIA: 05/03/2013
      -------CONTADORES-------
      Contador de Reduções Z: 1330
      Contador de Reinício de Operação: 004
      Geral de Operação Não Fiscal: 005185
      Comprovante de Crédito ou Débito: 0004
      Geral de Operação Não-Fiscal Cancelada: 0000
      Geral de Relatório Gerencial: 001817
      Contador de Cupom Fiscal: 009792
      Cupom Fiscal Cancelado: 0003
      Contador de Fita Detalhe: 000000
      -TOTALIZADORES FISCAIS--
      TOTALIZADOR GERAL: 1.533.200,46
      VENDA BRUTA DIÁRIA: 1.446,00
      CANCELAMENTO ICMS: 278,00
      DESCONTO ICMS: 15,78
      Total de ISSQN: 0,00
      CANCELAMENTO ISSQN: 0,00
      ------------------
      VENDA LÍQUIDA: 1.152,22
      ACRÉSCIMO ICMS: 0,00
      ACRÉSCIMO ISS: 0,00
      ----------ICMS----------
      Totalizador Base Cálculo( R$) Imposto( R$)
      T07,00% 0,00 0,00
      T12,00% 0,00 0,00
      T25,00% 0,00 0,00
      T17,00% 487,50 82,87
      ------------------
      Total ICMS: 487,50 82,87
      ---------ISSQN----------
      Totalizador Base Cálculo( R$) Imposto( R$)
      ------------------
      Total ISSQN: 0,00 0,00
      -----Não Tributados-----
      Totalizador Valor Acumulado( R$)
      Substituição Tributária ICMS: 0,00
      Isento ICMS: 664,72
      Não Incidência ICMS: 0,00
      Substituição Tributária ISSQN: 0,00
      Isento ISSQN: 0,00
      Não Incidência ISSQN: 0,00
      -----------TOTALIZADORES NÃO FISCAIS------------
      CANC NÃO-FISC: 0,00
      DESC NÃO-FISC: 0,00
      ACRE NÃO-FISC: 0,00
      Nº Operação CON Valor Acumulado( R$)
      29 Sangria : 0001 50,00
      30 Suprimento : 0001 50,00
      ------------------
      Total Operações Não-Fiscais R$ 100,00
      --RELATÓRIO GERENCIAL---
      Nº Relatório CER
      01 Relatório Geral 0005
      ---MEIOS DE PAGAMENTO---
      No. Meio Pagamento TEF Valor Acumulado ( R$)
      01 Dinheiro N 343,00
      02 cartão S 436,35
      03 Cheque S 404,00
      04 Devoluçäes S 65,00
      05 Saldo anterior S 0,00
      TROCO 46,13
      ------------------------------------------------
      Comprovante Não Emitido: 0002
      Tempo Emitindo Doc. Fiscal: 00:18:20
      Tempo Operacional: 19:09:14
      MFD: 8751061142206
      Número de Reduções Restantes: 0712
      ------------------------------------------------
      BEMATECH MP-2000 TH FI ECF-IF
      ECF:001 LJ:0032 VERSÃO:01.03.02
      FAB:BE0306SC95531101930 05/03/2013 19:09:43
      QQQQQQQQQWYRREQQTU BR
      ------------------------------------------------
    EOS
  end

  def helper(text, redz)
    assert_equal redz, Parser.new.parse(text)
  end

  def test_id
    helper("05/03/2013 19:09:14 COO:017936\n", { :id => 17936 })
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
    helper("Geral de Operação Não Fiscal: 005185\n", { :cont_operacoes_nao_fiscais => "005185" })
  end

  def test_cont_comp_deb_cred
    helper("Comprovante de Crédito ou Débito: 0004\n", { :cont_comp_deb_cred => "0004" })
  end

end
