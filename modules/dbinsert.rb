require 'sinatra/base'
require 'sqlite3'
require 'csv'

module Sinatra
  module DBInserter 
        
    class FileReader
      def initialize(filetype, file, dataset)
        @filetype = filetype
        @file = file
        @dataset = dataset
        @dnas = []
        @dna_pep = []
        @peps = []
        @pep_ds = []
      end

      def read_file(*data_args)
        if @filetype == "dataset"
          read_dataset_file
          return @dnas, @dna_pep, @peps, @pep_ds
        elsif @filetype == "cluster"
          read_cluster_file(data_args[0], data_args[1], data_args[2])
        elsif @filetype == "motif"
          read_motif_file
        end
      end #read_file
      
      private
    
      def read_dataset_file
        dsfile = File.readlines(@file)
        dsfile.each_with_index do |line, index|
          linematch = line.scan(/\S+/)
          @peps.insert(-1, linematch[0])
          @pep_ds.insert(-1,[@dataset, linematch[0], linematch[1].to_i, linematch[2].to_f, index.next])
          ds_pep_dna = [@dataset, linematch[0]]
          linematch.slice(3, linematch.size - 3).each do |part|
            @dnas.insert(-1, part) if part =~ /\D+/
            ds_pep_dna.insert(-1, part)
            if ds_pep_dna.size == 4
              @dna_pep.insert(-1,ds_pep_dna)
              ds_pep_dna = [@dataset, linematch[0]]
            end #if
          end#each part
        end #each line
      end
      
      def read_cluster_file(cluster_paras, selection, library)
        if Cluster.all.count > 0
          current_cluster_id = Cluster.last[:cluster_id]
        else
          current_cluster_id = 0 
        end
        clusters = []
        cluster_data = []
        clfile = File.readlines(@file)
        clfile.each do |line|
          linematch = line.match(/(\S+)\s+(\d+)\s+(\S+)/)
          if linematch[1][0] == "+"
            con_seq = linematch[1].slice(1, linematch[1].size-1)
            clusters.insert(-1, [@dataset, selection, library, con_seq, linematch[2], linematch[3], cluster_paras])
            current_cluster_id += 1
          else
            cluster_data.insert(-1, [current_cluster_id, linematch[1]])
            if Peptide.select(:peptide_sequence).where(:peptide_sequence => linematch[1]).count == 0 
              puts "ohoh"
              puts linematch[1]
            end
          end
        end #end line
        return clusters, cluster_data
      end
        
      def read_motif_file
        mots_mot_lists = []
        motifs = []
        line_counter = 1
        CSV.foreach(@file, :col_sep => ';', :row_sep => :auto ) do |row|
          row[0].gsub!(/\s+/, "")
          if row[0].match(/[^\[\]\w]/)
            raise ArgumentError, "invalid motif character on line #{line_counter}"
          end
          motif = [row[0].upcase]
          list = [@dataset, row[0].upcase, row[1], row[2], row[3]]
          mots_mot_lists.insert(-1,list)
          motifs.insert(-1, motif)
        end
        return motifs, mots_mot_lists
      end
    end #class

    class InsertData   
      MAX_SQLITE_STATEMENTS = 450
      include Rack::Utils
      alias_method :es, :escape_html
      def initialize(values)
        @values = values
        @errors ={}
        @datatype = values[:submittype]
      end # init
      
      def try_insert
          if @datatype == "library"
            into_library
          elsif @datatype == "selection"
            into_selection
          elsif @datatype == "dataset"
            into_dataset 
          elsif @datatype == "cluster"
            into_cluster 
          elsif @datatype == "result"
            into_result 
          elsif @datatype == "target"
            into_target
          elsif @datatype == "motif"
            into_motif
          end
          @errors
      end #try_insert

      def into_library
        begin
          DB[:libraries].insert(:library_name => "#{es @values[:libname].to_s}", :encoding_scheme =>"#{es @values[:enc].to_s}", :carrier => "#{es @values[:ca].to_s}", :produced_by => "#{es @values[:prod].to_s}", :date => "#{es @values[:date]}", :insert_length => "#{es @values[:insert].to_i}", :peptide_diversity => "#{es @values[:diversity].to_f}")
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:lib] = "Given name not unique"
          else
           @errors[:lib] = "database error" 
          end
        end
      end #library

      def into_selection
        begin
          target = DB[:targets].select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).first[:target_id]
          DB[:selections].insert(:selection_name => "#{es @values[:selname].to_s}", :performed_by => "#{es @values[:perf].to_s}", :date =>"#{es @values[:date]}", :target_id => target, :library_name => "#{es @values[:dlibname].to_s}")
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:sel] = "Given name not unique"
          else
           @errors[:sel] = e.message 
          end
        end
      end #selection
      
      def into_dataset
        pep_ds = []
        dna_pep = []
        DB.transaction do
          begin
            library = DB[:selections].select(:library_name).where(:selection_name => @values[:dselname].to_s).first[:library_name]
            target = DB[:targets].select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).first[:target_id]
            DB[:sequencing_datasets].insert(:dataset_name => "#{es @values[:dsname].to_s}", :read_type => "#{es @values[:rt].to_s}", :date =>"#{es @values[:date]}", :target_id => target, :library_name => library, :selection_name => "#{es @values[:dselname].to_s}", :used_indices => "#{es @values[:ui].to_s}", :origin => "#{es @values[:or].to_s}", :produced_by => "#{es @values[:prod].to_s}", :sequencer => "#{es @values[:seq].to_s}", :selection_round => "#{es @values[:selr].to_i}", :sequence_length => "#{es @values[:seql]}")
          rescue Sequel::Error => e
            if e.message.include? "unique"
              @errors[:ds] = "Given name not unique"
            else
              @errors[:ds] = e.message 
            end
            raise Sequel::Rollback 
          end
          fr = FileReader.new(@values[:submittype], @values[:pepfile][:tempfile], @values[:dsname])
          dnas, dna_pep, peps, pep_ds =  fr.read_file
          dnas_qry, dnas_placeholder_args = build_compound_select_string(dnas, :dna_sequences, :dna_sequence)
          peps_qry, peps_placeholder_args = build_compound_select_string(peps, :peptides, :peptide_sequence)

          begin
            dnas_qry.zip(dnas_placeholder_args).each do |qry, args|
              new_data= DB[qry, *args]
              new_data.insert

            end #qry,args
            peps_qry.zip(peps_placeholder_args).each do |qry, args|
              new_data = DB[qry, *args]
              new_data.insert
            end #qry,args
 
          rescue Sequel::Error => e 
            @errors[:insert] = e.message #"Inserting data failed. Changes rolled back"
            raise Sequel::Rollback 
          end # resc
        DB[:dna_sequences_peptides_sequencing_datasets].import([:dataset_name, :peptide_sequence, :dna_sequence,:reads], dna_pep)
        DB[:peptides_sequencing_datasets].import([:dataset_name, :peptide_sequence, :reads, :dominance, :rank], pep_ds)
        #end # trans
      end
      update_distinct_peptides = DB["UPDATE libraries SET distinct_peptides = (SELECT COUNT (DISTINCT peptide_sequence) FROM peptides_sequencing_datasets AS pep_seq INNER JOIN sequencing_datasets AS ds ON pep_seq.dataset_name = ds.dataset_name  WHERE library_name = (SELECT library_name FROM sequencing_datasets WHERE dataset_name = ?)) WHERE library_name = (SELECT library_name FROM sequencing_datasets WHERE dataset_name = ?)", @values[:dsname].to_s, @values[:dsname].to_s]
      update_distinct_peptides.update
      end #dataset
       
      def into_cluster
        DB.transaction do
          begin
            library = DB[:sequencing_datasets].select(:library_name).where(:dataset_name => @values[:ddsname].to_s).first[:library_name]
            selection = DB[:sequencing_datasets].select(:selection_name).where(:dataset_name => @values[:ddsname].to_s).first[:selection_name]
            fr = FileReader.new(@values[:submittype], @values[:clfile][:tempfile], @values[:ddsname])
            clusters, cluster_data =  fr.read_file(@values[:paras], selection, library)
            DB[:clusters].import([:dataset_name, :selection_name, :library_name, :consensus_sequence, :reads_sum, :dominance_sum, :parameters], clusters)
            Cluster.all.each do |cl|
              puts cl[:cluster_id]
            end
            puts cluster_data
            DB[:clusters_peptides].import([:cluster_id, :peptide_sequence], cluster_data)
          rescue Sequel::Error => e
            if e.message.include? "unique"
              @errors[:cluster] = "Given name not unique"
            else
             @errors[:cluster] = e.message 
            end
            raise Sequel::Rollback
          end # end rescue
        end #transaction
      end #cluster
      
      def into_target
        begin
          DB[:targets].insert(:species => "#{es @values[:sp].to_s}", :tissue => "#{es @values[:tis].to_s}", :cell => "#{es @values[:cell].to_s}")
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:tar] = "Given name not unique"
          else
           @errors[:tar] = "database error" 
          end
        end
      end #target
      
      def into_result
          target = DB[:targets].select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).first[:target_id]
        begin
          id = DB[:results].insert(:target_id => target, :performance => "#{es @values[:perf].to_s}")
          DB[:peptides_sequencing_datasets].where(:dataset_name => @values[:ddsname], :peptide_sequence => @values[:pseq]).update(:result_id => id)
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:tar] = "Given name not unique"
          else
           @errors[:tar] = e.message 
          end
        end
      end #result
      
      def into_motif
        DB.transaction do
          begin
            DB[:motif_lists].insert(:list_name => "#{es @values[:mlname].to_s}")
            fr = FileReader.new(@values[:submittype], @values[:motfile][:tempfile], @values[:mlname])
            motifs, motifs_mot_lists = fr.read_file
            motifs_qry, motifs_placeholder_args = build_compound_select_string(motifs, :motifs, :motif_sequence)

            motifs_qry.zip(motifs_placeholder_args).each do |qry, args|
              new_data= DB[qry, *args]
              new_data.insert
            end
            
            motifs.each_with_index do |entry, index|
              raise ArgumentError, "duplicate motif sequence on line #{index+1}"  if motifs.slice(0, index).include?(entry)    
        
            end

            DB[:motifs_motif_lists].import([:list_name, :motif_sequence, :target, :receptor, :source], motifs_mot_lists)
           
          rescue Sequel::Error => e
            if e.message.include? "unique"
              @errors[:mot] = e.message #"Given name not unique"
            else
             @errors[:mot] = e.message#"database error" 
            end #if
            raise Sequel::Rollback
          rescue ArgumentError => e
            @errors[:mot] = e.message
            raise Sequel::Rollback
          end #rescue
        end #transaction
      end #motif
      
      def build_compound_select_string(data, table, *columns)
        qry = []
        placeholder_args = []
        qry_string = build_qrystring(table, columns) 
        (1...MAX_SQLITE_STATEMENTS).each do |index|
          qry_string << " UNION SELECT ?" << ",?" * (columns.size-1)
        end #index
        (0..data.size).step(MAX_SQLITE_STATEMENTS) do |index|
          if ((data.size - index) < MAX_SQLITE_STATEMENTS)
            qry_string = build_qrystring(table, columns)
            (1...data.size - index).each do |newstr|
              qry_string << " UNION SELECT ?" << ",?" * (columns.size-1)
            end #end newstr
            qry.insert(-1, qry_string)
            holder_args = data.slice(index, data.size-index)
            placeholder_args.insert(-1, holder_args) if holder_args[0].class == String
            placeholder_args.insert(-1, holder_args.flatten) if holder_args[0].class == Array
          else       
            qry.insert(-1, qry_string)
            holder_args = data.slice(index, MAX_SQLITE_STATEMENTS)
            placeholder_args.insert(-1, holder_args) if holder_args[0].class == String
            placeholder_args.insert(-1, holder_args.flatten) if holder_args[0].class == Array
            #placeholder_args.insert(-1, data.slice(index, MAX_SQLITE_STATEMENTS))
          end # endif
        end #end index
        
        return qry, placeholder_args
      end
        
      def build_qrystring(table, columns)
        qry_string = "INSERT OR IGNORE INTO #{table}"
        string_columns = "(" 
        last_part = "SELECT " 
        columns.each_with_index do |column, index|
          if index < columns.size-1 
            string_columns << "#{column},"
            last_part << " ? AS #{column},"
          else
            string_columns << "#{column})"
            last_part << " ? AS #{column}"
          end
        end
        qry_string << string_columns << last_part  
      end
      
    end #class  
      
    def insert_data(values)
      d = InsertData.new(values)  
      errors = d.try_insert
    end #validate

  end

  helpers DBInserter 
end
