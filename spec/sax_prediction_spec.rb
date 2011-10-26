require 'spec_helper'

describe "generate_attributes" do
	before do 
		@test = 'AAAADFYILEKRKRST'
	end
  it "generates the array of values representing the charges at various pHs." do
		charges = generate_attributes(@test).charge_arr
		charges.class.should.equal Array
		charges.length.should.equal 21
  end
	it 'provides a PepAttributes object' do 
		generate_attributes(@test).class.should.equal PepAttributes
	end
end
describe "make arff file" do 
	before do 
		@tests = ["AAAADFYILEKRKRST", "AYADFYILEKSTRK", "RARYANANDGMARAK", "RYANASTAFK"]
		@structs = @tests.map{|a| generate_attributes(a)}
	end
	it 'makes an arff file' do 
		p @structs.first
		make_arff(@structs)
	end
end
