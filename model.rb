require 'data_mapper'

# show logging
DataMapper::Logger.new($stdout, :debug)

DataMapper.setup(:default, "sqlite3://#{Dir.pwd}/project.db")

class Library
  include DataMapper::Resource

  property :name,               String, :key => true
  property :insert_length,      Integer
  property :carrier,            String
  property :date,               Date
  property :distinct_peptides,  Integer
  property :peptide_diversity,  Integer
  property :produced_by,        String
end

class Selection
  include DataMapper::Resource
  property :name, String, :key => true
  property :date, Date
end

class SequencingDataset
  include DataMapper::Resource
  property :name,             String, :key => true
  property :read_type,        String
  property :used_indices,     String
  property :date,             Date
  property :origin,           String
  property :produced_by,      String
  property :sequencer,        String
  property :selection_round,  Integer
  property :sequence_length,  Integer
  property :statistics,       Text
end

class Cluster 
  include DataMapper::Resource
  property :id,                 Serial
  property :parameter,          Text
  property :consensus_sequence, String
  property :dominance_sum,      Float
end

class Peptide
  include DataMapper::Resource
  property :sequence, String, :key => true
end

class DNASequence
  include DataMapper::Resource
  property :sequence, String, :key => true
end

class PeptideResult
  include DataMapper::Resource
  property :id,           Serial
  property :performance,  Text
end

class Target 
  include DataMapper::Resource
  property :id,       Serial
  property :species,  String
  property :tissue,   String
  property :cell,     String

end


class SDObservation
  include DataMapper::Resource
  property :reads,      Integer
  property :dominance,  Float
  property :rank,       Integer
  
  belongs_to :peptide, :parent_key => [ :sequence ], :key => true
  belongs_to :sequencingdataset, :parent_key => [ :name ], :key => true

end

class DNAFinding
  include DataMapper::Resource
  property :reads, Integer

end

class PepInCluster
  include DataMapper::Resource
  belongs_to :cluster, :key => true
  belongs_to :peptide, :key => true
end

DataMapper.finalize
DataMapper.auto_upgrade!


########## REALTIONS
class Library
  
  has n, :selections, :child_key => [ :name ], :parent_key => [ :name ]
  has n, :clusters, :parent_key => [ :name ]
  has n, :sequencingdatasets, :child_key => [ :name ], :parent_key => [ :name ]
end

class Selection

  belongs_to :library, :child_key => [ :name ], :parent_key => [ :name ]
  belongs_to :target, :child_key => [ :name ] 

  has n, :sequencingdatasets, :child_key => [ :name ], :parent_key => [ :name ]
  has n, :clusters, :parent_key => [ :name ]
end

class SequencingDataset

  belongs_to :library, :child_key => [ :name ], :parent_key => [ :name ]
  belongs_to :selection, :child_key => [ :name ], :parent_key => [ :name ]

  has n, :clusters, :parent_key => [ :name ]

  has n, :sdobservations
  has n, :peptides, :through => :sd_observations
  
  has n, :dnafindings
  has n, :dnasequences, :through => :dna_finding
  has n, :peptides, :through => :dna_finding

end

class Cluster 
  
  belongs_to :library, :parent_key => [ :name ]
  belongs_to :selection, :parent_key => [ :name ]
  belongs_to :sequencingdataset, :parent_key => [ :name ] 

  has n, :pepinclusters
  has n, :peptides, :through => :pep_in_cluster

end

class Peptide

  has n, :dnafindings
  has n, :dnasequences, :through => :dna_findings
  has n, :sequencingdatasets, :through => :dna_findings

  has n, :sdobservations
  has n, :sequencingdatasets, :through => :sd_observations
  has 1, :peptideresult, :through => :sd_observations

  has n, :pepinclusters
  has n, :clusters, :through => :pep_in_cluster

end

class DNASequence
  has n, :dnafindings
  has n, :peptides, :through => :dna_findings
  has n, :sequencingdatasets, :through => :dna_findings


end

class PeptideResult
  belongs_to :sdobservation
  belongs_to :target
end

class Target 
  has n, :sequencingdatasets, :child_key => [ :name ], :required => false
  has n, :peptideresults, :required => false
  has n, :slections, :child_key => [ :name ], :required => false
end

class SDObservation
  has n, :peptide_results, :required => false
end

class DNAFinding
  belongs_to :dnasequence, :parent_key => [ :sequence ], :key => true
  belongs_to :peptide, :parent_key => [ :sequence ], :key => true
  belongs_to :sequencingdataset, :parent_key => [ :name ], :key => true
end














