require 'sequel'
DB = Sequel.sqlite('pep.db')
load 'create_tables.rb'

class Library < Sequel::Model
  one_to_many :selections, :key => :selection_name
  one_to_many :sequencing_datasets, :key => :dataset_name
  one_to_many :clusters
end

class Selection < Sequel::Model
  many_to_one :target
  many_to_one :library, :key => :library_name

  one_to_many :sequencing_datasets, :key => :dataset_name
  one_to_many :clusters
end

class SequencingDataset < Sequel::Model
  many_to_one :target
  many_to_one :library, :key => :library_name
  many_to_one :selection, :key => :selection_name

  one_to_many :clusters

  many_to_many :foundpeptides, :class =>:Peptide, :key => :peptide_sequence, :select => [:rank, :reads, :dominance, :result_id]

  one_to_many :dnafindings
  many_to_many :dnapeptides, :class => :Peptide,:join_table=>:dnafindings, :key => :peptide_sequence
  many_to_many :dna_sequences, :join_table=>:dnafindings, :key => :dna_sequence
end

class Peptide < Sequel::Model
  many_to_many :clusters
  many_to_many :peptide_datasets, :class => :SequencingDataset, :key => :dataset_name, :select => [:rank, :reads, :dominance, :result_id]

  one_to_many :dnafindings
  many_to_many :dna_sequences, :join_table=>:dnafindings, :key => :dna_sequence
  many_to_many :dna_datasets, :class => :SequencingDataset,:join_table => :dnafindings, :key => :dataset_name
  
end

class Cluster < Sequel::Model
  many_to_one :library, :key => :library_name
  many_to_one :selection, :key => :selection_name
  many_to_one :sequencing_dataset, :key => :dataset_name

  many_to_many :peptides, :key => :peptide_sequence
end

class DNASequence < Sequel::Model
  one_to_many :dnafindings
  many_to_many :peptides, :join_table=>:dnafindings, :key => :peptide_sequence
  many_to_many :sequencing_datasets, :join_table => :dnafindings, :key => :dataset_name
end

class Result < Sequel::Model
  many_to_one :target
  one_to_one :observation
end

class Target < Sequel::Model
  one_to_many :selections, :key => :selection_name
  one_to_many :sequencing_datasets, :key => :dataset_name
  one_to_many :results 
end

class DNAFinding < Sequel::Model(:dna_sequences_peptides_sequencing_datasets)
  many_to_one :dna_sequence, :key => :dna_sequence
  many_to_one :peptide, :key => :peptide_sequence
  many_to_one :sequencing_dataset, :key => :dataset_name
end

class Observation < Sequel::Model(:peptides_sequencing_datasets)
  many_to_one :peptide, :key => :peptide_sequence
  many_to_one :sequencing_dataset, :key => :dataset_name
  many_to_one :result
end
