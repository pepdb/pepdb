require 'sequel'
require 'logger'

# this file realizes the ORM part of sequel
# all database tables can be accessed via the corresponding ruby classes
# after this file has been loaded

# create db connection and load the regexp module
#DB = Sequel.sqlite('pep.db', :synchronous => "off", :loggers => Logger.new('update.log'),:after_connect => (proc do |db|
DB = Sequel.sqlite('pep.db', :synchronous => "off", :after_connect => (proc do |db|
  db.enable_load_extension(1) 
  db.execute("SELECT load_extension('./regexp.sqlext')")
  db.enable_load_extension(0) 
end))
require './create_tables'


class Library < Sequel::Model
  one_to_many :selections, :key => :selection_name
  one_to_many :sequencing_datasets, :key => :dataset_name
  one_to_many :clusters
  many_to_many :sequel_users, :left_key => :library_name, :right_key => :id
end

class Selection < Sequel::Model
  many_to_one :target
  many_to_one :library, :key => :library_name

  one_to_many :sequencing_datasets, :key => :dataset_name
  one_to_many :clusters
  many_to_many :sequel_users, :left_key => :selection_name, :right_key => :id
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
  many_to_many :sequel_users, :left_key => :dataset_name ,:right_key => :id
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

class DnaSequence < Sequel::Model
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

class DnaFinding < Sequel::Model(:dna_sequences_peptides_sequencing_datasets)
  many_to_one :dna_sequence, :key => :dna_sequence
  many_to_one :peptide, :key => :peptide_sequence
  many_to_one :sequencing_dataset, :key => :dataset_name
end

class Observation < Sequel::Model(:peptides_sequencing_datasets)
  many_to_one :peptide, :key => :peptide_sequence
  many_to_one :sequencing_dataset, :key => :dataset_name
  many_to_one :result
end

class PeptidePerformance < Sequel::Model
  many_to_one :libraries, :key => :library_name
  many_to_one :peptides, :key => :peptide_sequence
end

class Motif < Sequel::Model
  many_to_many :motif_lists, :key => :list_name
end

class MotifList < Sequel::Model
  many_to_many :motifs, :key => :motif_sequence
end

class SequelUser < Sequel::Model
  many_to_many :libraries, :left_key => :id, :right_key => :library_name
  many_to_many :selections, :left_key => :id,:right_key => :selection_name
  many_to_many :sequencing_datasets, :left_key => :id, :right_key => :dataset_name

end
