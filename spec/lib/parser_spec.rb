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

end
