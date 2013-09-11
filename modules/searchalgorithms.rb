require 'sinatra/base'

module Sinatra
  module SearchAlgorithms
  
    def comparative_search(dataset, reference, search_type)
      relevant_peptides = Array.new
      dataset.each do |ds|
        puts ds[:dataset_name]
        reference.each do |ref|
          if(ds[:peptide_sequence] != reference[:peptide_sequence] && search_type == "ds_only")
            relevant_peptides.insert(-1, ds[:peptide_sequence])
          end
        end
      end
    end
  end
  helpers SearchAlgorithms
end
