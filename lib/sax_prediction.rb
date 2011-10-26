require 'bundler/setup'
require 'isoelectric_calc'
require 'result_pI_checker'

# Usage: identify_potential_charges(str) gives a PepCharges Struct 

# PepCharges = Struct.new(:seq, :n_term, :c_term, :y_num, :c_num, :k_num, :h_num, :r_num, :d_num, :e_num, :pi)

# This can then be used to calculate what pH represents a -1, -2, -3... charge on the peptide.
PepAttributes = Struct.new(:seq, :n_term, :c_term, :y_num, :c_num, :k_num, :h_num, :r_num, :d_num, :e_num, :u_num, :polar_num, :hydrophobic_num, :pi, :charge_arr) # charge_arr should be an array from 2-12 by 0.5 pH units
def charges(pep_charges)
	2.0.step(12, 0.5).map do |ph|
		charge_at_pH(pep_charges, ph)
	end
end
def generate_attributes(str)
	pepcharges = identify_potential_charges(str)
	pepcharges.pi = calc_PI(pepcharges)
	pep = PepAttributes.new(*pepcharges.to_a)
	pep.charge_arr = charges(pepcharges)
	pep
end

def make_arff(arr_of_structs, filename = nil, sax_pH_fraction = nil)
	sax_pH_fraction ||= '?'
	filename ||= 'tmp.arff'
	File.open(filename, 'w') do |out|
		out.puts "% This is output from the sax_prediction program, part of the GEM_NAME project."
		out.puts "% So, if you really want to fix something with this file, you should go to the source files"
		out.puts "@relation Sax_prediction-#{DateTime.now.to_s}"
		arr_of_structs.first.members.each do |attribute|
			case arr_of_structs.first[attribute]
				when Float, Fixnum
					out.puts "@attribute #{attribute} NUMERIC"
				when String
					out.puts "@attribute #{attribute} STRING"
				when Array
					#out.puts "@attribute charges relational"
					2.0.step(12, 0.5).each do |ph|
						out.puts "@attribute charge_at_#{ph} NUMERIC"
					end #ph.each do 
					#out.puts "@end charges"
			end	#case
		end # each do
		out.puts "@attribute fraction NUMERIC"
		out.puts "@DATA"
		arr_of_structs.each do |struct|
			entry = struct.values[0..13].join(', ')
			entry << ", #{struct.values[14].join(', ')}"
			entry << ", #{sax_pH_fraction}"
			out.puts entry
		end
	end
end
if File.basename($0) == 'sax_prediction.rb'
	if ARGV.size == 0 or ARGV.size % 2 != 0
		puts "Usage:  Look it up yourself"
		puts "Output: Look it up yourself"
		exit
	end
	files = []; sax_fractions = []
	while ARGV.size > 0
		files << ARGV.shift
		sax_fractions << ARGV.shift
	end
	files.each_with_index do |file, i|
		arr_of_structs = parse_pepxml(file).map do |pepid|
			generate_attributes(pepid.aaseq)
		end
		make_arff(arr_of_structs, "#{File.basename(file)}_#{sax_fractions[i]}.arff",  sax_fractions[i])
	end
end
	
