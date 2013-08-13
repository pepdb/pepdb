DB.create_table(:libraries) do
  String :library_name, :primary_key => true
  String :encoding_scheme
  String :carrier
  String :produced_by
  Date :date
  Integer :insert_length
  Integer :distinct_peptides
  Float :peptide_diversity 
  index :library_name 
end

DB.create_table(:selections) do
  String :selection_name, :primary_key => true
  Date :date
  foreign_key :target_id, :targets, :on_delete => :set_null
  foreign_key :library_name, :libraries, :on_delete => :cascade 
  index :selection_name
end

DB.create(:sequencing_datasets) do
  String :dataset_name, :primary_key => true
  String :read_type
  String :used_indices
  String :origin
  String :produced_by
  String :sequencer
  Date :date
  Integer :selection_round
  Integer :sequence_length
  File :statistics
  foreign_key :target_id, :targets, :on_delete => :set_null
  foreign_key :library_name, :libraries, :on_delete => :cascade
  foreign_key :selection_name, :selections, :on_delete => :cascade
  index :dataset_name
end

DB.create(:peptides) do
  String :peptide_sequence, :primary_key => true
  index :peptide_sequence
end

DB.create(:clusters) do
  primary_key :cluster_id
  String :parameters
  String :consensus_sequence
  Float :dominance_sum
  foreign_key :library_name, :libraries, :on_delete => :cascade
  foreign_key :selection_name, :selections, :on_delete => :cascade
  foreign_key :dataset_name, :sequencing_datasets, :on_delete => :cascade
  index :cluster_id
end

DB.create(:dna_sequences) do
  String :dna_sequence, :primary_key => true
  index :dna_sequence
end

DB.create(:results) do
  primary_key :result_id
  String :performance
  foreign_key :target_id, :targets, :on_delete => :set_null
  index :result_id
end

DB.create(:targets) do
  primary_key :target_id
  String :species
  String :tissue
  String :cell
  index :target_id
end

DB.create(:clusters_peptides) do
  Integer :cluster_id
  String :peptide_sequence
  primary_key [:cluster_id, :peptide_sequence]
  index :cluster_id
end

DB.create(:peptides_sequencing_datasets) do
  String :dataset_name
  String :peptide_sequence
  Integer :rank
  Integer :reads
  Float :dominance
  primary_key [:dataset_name, :peptide_sequence]
  index [:dataset_name, :peptide_sequence]
end

DB.create(:dna_sequences_peptides_sequencing_datasets) do
  String :dna_sequence
  String :peptide_sequence
  String :dataset_name
  Integer :reads
  foreign_key :result_id, :results, :on_delete => :set_null
  primary_key [:dna_sequence, :peptide_sequence, :dataset_name]
  index [:dna_sequence, :peptide_sequence, :dataset_name]
end
