DB.create_table?(:libraries) do
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

DB.create_table?(:selections) do
  String :selection_name, :primary_key => true
  Date :date
  foreign_key :target_id, :targets, :on_delete => :set_null
  foreign_key :library_name, :libraries, :on_delete => :cascade, :type=>'varchar(255)' 
  index :selection_name
end

DB.create_table?(:sequencing_datasets) do
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
  foreign_key :library_name, :libraries, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :selection_name, :selections, :on_delete => :cascade, :type=>'varchar(255)'
  index :dataset_name
end

DB.create_table?(:peptides) do
  String :peptide_sequence, :primary_key => true
  index :peptide_sequence
end

DB.create_table?(:clusters) do
  primary_key :cluster_id
  String :parameters
  String :consensus_sequence
  Float :dominance
  foreign_key :library_name, :libraries, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :selection_name, :selections, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :dataset_name, :sequencing_datasets, :on_delete => :cascade, :type=>'varchar(255)'
  index :cluster_id
end

DB.create_table?(:dna_sequences) do
  String :dna_sequence, :primary_key => true
  index :dna_sequence
end

DB.create_table?(:results) do
  primary_key :result_id
  Text :performance
  foreign_key :target_id, :targets, :on_delete => :set_null
  index :result_id
end

DB.create_table?(:targets) do
  primary_key :target_id
  String :species
  String :tissue
  String :cell
  index :target_id
end

DB.create_table?(:clusters_peptides) do
  foreign_key :cluster_id, :clusters, :on_delete => :cascade
  foreign_key :peptide_sequence, :peptides, :on_delete => :cascade, :type=>'varchar(255)'
  primary_key [:cluster_id, :peptide_sequence]
  index [:cluster_id, :peptide_sequence]
end

DB.create_table?(:peptides_sequencing_datasets) do
  foreign_key :dataset_name, :sequencing_datasets, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :peptide_sequence, :peptides, :on_delete => :cascade, :type=>'varchar(255)'
  Integer :rank
  Integer :reads
  Float :dominance
  foreign_key :result_id, :results, :on_delete => :set_null
  primary_key [:dataset_name, :peptide_sequence]
  index [:dataset_name, :peptide_sequence]
end

DB.create_table?(:dna_sequences_peptides_sequencing_datasets) do
  foreign_key :dna_sequence, :dna_sequences, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :peptide_sequence, :peptides, :on_delete => :cascade, :type=>'varchar(255)'
  foreign_key :dataset_name, :sequencing_datasets, :on_delete => :cascade, :type=>'varchar(255)'
  Integer :reads
  primary_key [:dna_sequence, :peptide_sequence, :dataset_name]
  index [:dna_sequence, :peptide_sequence, :dataset_name]
end

DB.create_table?(:motifs) do
  String :motif_sequence, :primary_key => true
  index :motif_sequence
end

DB.create_table?(:motif_lists) do
  String :list_name, :primary_key => true
  index :list_name
end

DB.create_table?(:motifs_motif_lists) do
  foreign_key :list_name
  foreign_key :motif_sequence
  primary_key [:list_name, :motif_sequence]
  index [:list_name, :motif_sequence]
end
