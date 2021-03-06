require 'sinatra/base'
require 'sqlite3'
require 'csv'
require settings.root + '/modules/columnfinder'
require 'sinatra-authentication'
require 'benchmark'
# this module is used to insert and update database data
module Sinatra
  module DBInserter 
    include SinatraAuthentication
    # this class reads possible datafiles, for further format informations
    # see the bachelor thesis
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
      
      def ds_type
        dsfile = File.readlines(@file)
        if dsfile[0].match(/^\S+\s+\S*\s*$/)
          :manual 
        else
          :ngs
        end
      end

      def read_file(*data_args)
        if @filetype == "dataset"
          type = read_dataset_file
          if type == :ngs
            return @dnas, @dna_pep, @peps, @pep_ds
          else
            return @peps, @pep_ds
          end
       elsif @filetype == "cluster"
          read_cluster_file(data_args[0], data_args[1], data_args[2])
        elsif @filetype == "motif"
          read_motif_file
        end
      end #read_file
      
      private
    
      def read_dataset_file
        dsfile = File.readlines(@file)
        if dsfile[0].match(/^\S+\s+\S*\s*$/)
          read_manual_file(dsfile)
          :manual
        else
          read_ngs_file(dsfile)
          :ngs
        end
      end

      def read_manual_file(dsfile)
        total_reads = calc_total_reads(dsfile)
        duplicate_peps = []
        dsfile.each_with_index do |line, index|
          linematch = line.scan(/\S+/)
          duplicate_peps.insert(-1, index.next) if @peps.include?(linematch[0])
          @peps.insert(-1, linematch[0])
          reads = linematch[1].nil? ? 1 : linematch[1].to_i
          dominance = reads / total_reads.to_f
          @pep_ds.insert(-1,[@dataset, linematch[0], reads, dominance])
        end #dsfile
        sorted_list = @pep_ds.sort {|x,y| y[2] <=> x[2]}
        skipped_ranks = rank = last_reads = 0
        sorted_list.each do |line|
          reads = line[2]
          if last_reads == reads
            skipped_ranks += 1
          elsif skipped_ranks != 0
            rank = rank + skipped_ranks + 1
            skipped_ranks = 0
            last_reads = reads
          else
            rank += 1
            last_reads = reads
          end 
          line.push(rank)
        end
        @pep_ds = sorted_list
        raise ArgumentError, "duplicate peptides on lines #{duplicate_peps.join(", ")}" unless duplicate_peps.empty?
      end #manual_file

      def calc_total_reads(file)
        total_reads = 0
        file.each do |line|
          linematch = line.scan(/\S+/)
          unless linematch[1].nil?
            total_reads = total_reads + linematch[1].to_i
          else
            total_reads = total_reads + 1
          end #if match 
        end #file
        total_reads
      end

      def read_ngs_file(dsfile)
        last_reads = 0
        skipped_ranks = 0
        rank = 0
        dsfile.each do |line|
          linematch = line.scan(/\S+/)
          @peps.insert(-1, linematch[0])
          reads = linematch[1].to_i
          if last_reads == reads
            skipped_ranks += 1
          elsif skipped_ranks != 0
            rank = rank + skipped_ranks + 1
            skipped_ranks = 0
            last_reads = reads
          else
            rank += 1
            last_reads = reads
          end
          @pep_ds.insert(-1,[@dataset, linematch[0], reads, linematch[2].to_f, rank])
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
      end #ngs_file

      
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
          end
        end #end line
        return clusters, cluster_data
      end
        
      def read_motif_file
        mots_mot_lists = []
        motifs = []
        line_counter = 1
        CSV.foreach(@file, :col_sep => ';', :row_sep => :auto ) do |row|
          if row[0].nil?
            raise ArgumentError, "No motif given on line #{line_counter}"
          end
          row[0].gsub!(/\s+/, "")
          if row[0].match(/[^\[\]\w]/)
            raise ArgumentError, "invalid motif character (only [,] or characters allowed) on line #{line_counter}"
          end
          motif = [row[0].upcase]
          list = [@dataset, row[0].upcase, row[1], row[2], row[3]]
          mots_mot_lists.insert(-1,list)
          motifs.insert(-1, motif)
          line_counter += 1
        end
        return motifs, mots_mot_lists
      end
    end #class

    class InsertData   
      include Utilities
      include SinatraAuthentication
      # sqlite can't handle more than ~500 statements at once
      MAX_SQLITE_STATEMENTS = 450
      include Rack::Utils
      alias_method :es, :escape_html
      def initialize(values)
        @values = values
        @errors ={}
        @datatype = values[:submittype]
      end # snit
      
      def current_time
        Time.now.strftime "%H:%M:%S"
      end

      
      def try_insert
          if @datatype == "library"
            into_library
          elsif @datatype == "selection"
            into_selection
          elsif @datatype == "dataset"
            into_dataset 
          elsif @datatype == "cluster"
            into_cluster 
          elsif @datatype == "target"
            into_target
          elsif @datatype == "motif"
            into_motif
          elsif @datatype == "performance"
            into_performance
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
          target = find_target 
      
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
        # because a large amount of data is inserted in the following section wrap it in a transaction
        DB.transaction do
          begin
            library = DB[:selections].select(:library_name).where(:selection_name => @values[:dselname].to_s).first[:library_name]
            get_target = DB[:targets].select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).count
            if get_target > 0
              target = DB[:targets].select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).first[:target_id]
            else
              target = nil
            end  
            DB[:sequencing_datasets].insert(:dataset_name => "#{es @values[:dsname].to_s}", :read_type => "#{es @values[:rt].to_s}", :date =>"#{es @values[:date]}", :target_id => target, :library_name => library, :selection_name => "#{es @values[:dselname].to_s}", :used_indices => "#{es @values[:ui].to_s}", :origin => "#{es @values[:or].to_s}", :produced_by => "#{es @values[:prod].to_s}", :sequencer => "#{es @values[:seq].to_s}", :selection_round => "#{es @values[:selr].to_i}", :sequence_length => "#{es @values[:seql]}", :statistic_file => @values[:statpath])
            fr = FileReader.new(@values[:submittype], @values[:pepfile][:tempfile], @values[:dsname])
            dataset_type = fr.ds_type
            if dataset_type == :ngs 
              dnas, dna_pep, peps, pep_ds =  fr.read_file
            else
              peps, pep_ds =  fr.read_file 
            end
            dnas_qry, dnas_placeholder_args = build_compound_select_string(dnas, :dna_sequences, :dna_sequence) if dataset_type == :ngs
            peps_qry, peps_placeholder_args = build_compound_select_string(peps, :peptides, :peptide_sequence)

            if dataset_type == :ngs
              dnas_qry.zip(dnas_placeholder_args).each do |qry, args|
                new_data= DB[qry, *args]
                new_data.insert
              end #qry,args
            end #ngs
            peps_qry.zip(peps_placeholder_args).each do |qry, args|
              new_data= DB[qry, *args]
              new_data.insert
            end #qry,args
        DB[:dna_sequences_peptides_sequencing_datasets].import([:dataset_name, :peptide_sequence, :dna_sequence,:reads], dna_pep) if dataset_type == :ngs
            DB[:peptides_sequencing_datasets].import([:dataset_name, :peptide_sequence, :reads, :dominance, :rank], pep_ds)
          rescue Sequel::Error => e 
            @errors[:insert] = e.message #"Inserting data failed. Changes rolled back"
            raise Sequel::Rollback 
          rescue ArgumentError => e
            @errors[:ds] = e.message
            raise Sequel::Rollback
          end
        end
        update_distinct_peptides = ''

        # after inserting a new sequencing dataset update the distinct peptides field of the corresponding library 
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
              #TODO intention?
            end
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
      
      def into_performance
        begin
          DB[:peptide_performances].insert(:library_name => @values[:dlibname].to_s, :peptide_sequence => @values[:pseq],:performance => "#{es @values[:perf].to_s}")
        rescue Sequel::Error => e
          if e.message.include? "unique"
            @errors[:result] = "Given peptide performace already exists. Try editing existing data."
          else
           @errors[:result] = e.message 
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
     
      # sequel's import method currently does not support insert-ignore when using sqlite
      # so we need to build a sql-string to explicitly use insert-ignore when inserting large amounts of data
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
      def find_target
        result = nil
        if option_selected?(@values[:dtar])
          target_elements = @values[:dtar].split(/ - /)
          result = Target.select(:target_id).where(:species => target_elements[0], :tissue => target_elements[1], :cell => target_elements[2]).first[:target_id]
        end
        result
      end
      
    end #class  
    
    class UpdateData
      include Utilities
      include ColumnFinder
      include Rack::Utils
      alias_method :es, :escape_html
      def initialize(values)
        @mot_updates = []
        @errors ={}
        @table = values[:tab].to_sym
        @row_id = values[:eleid]
        @values = values
        @update_hash = {}
        @id_column = find_id_column(@values[:tab])
        select_upd_type
      end #init

      def update
        if @table == :motifs_motif_lists 
          @mot_updates.each do |upd|
            DB[@table].where(upd[0]).update(upd[1])
          end
        elsif @table == :peptide_performances
          DB[@table].where(@perf_update[0]).update(@perf_update[1])
        else
          DB[@table].where(@id_column => @row_id).update(@update_hash)
        end 
        @errors
      end
      private
      def select_upd_type
      case @table.to_s
        when "libraries"
          up_library
        when "selections"
          up_selection
        when "sequencing_datasets"
          up_dataset
        when "clusters"
          up_cluster
        when "results"
          up_result
        when  "targets"
          up_target
        when "motif_lists"
          up_motlist
        when "peptide_performances"
          up_performance
        end
      end #select_upd_t

      def up_library
        @update_hash[:encoding_scheme] = es @values[:enc].to_s      
        @update_hash[:carrier] = es @values[:ca].to_s      
        @update_hash[:insert_length] = es @values[:insert].to_i      
        @update_hash[:produced_by] = es @values[:prod].to_s      
        @update_hash[:peptide_diversity] = es @values[:diversity].to_f      
        @update_hash[:date] = es @values[:date].to_s      
        @row_id.to_s
      end #up_lib

      def up_selection
        @update_hash[:performed_by] = es @values[:perf].to_s      
        @update_hash[:date] = es @values[:date].to_s      
        @update_hash[:target_id] = find_target
        @update_hash[:library_name] = @values[:dlibname]
        @row_id.to_s
      end #up_sel

      def up_dataset
        @update_hash[:read_type] = es @values[:rt].to_s      
        @update_hash[:used_indices] = es @values[:ui].to_s      
        @update_hash[:origin] = es @values[:or].to_s      
        @update_hash[:produced_by] = es @values[:prod].to_s      
        @update_hash[:sequencer] = es @values[:seq].to_s      
        @update_hash[:date] = es @values[:date].to_s      
        @update_hash[:selection_round] = es @values[:selr].to_i   
        @update_hash[:sequence_length] = es @values[:seql].to_i      
        @update_hash[:target_id] = find_target      
        @update_hash[:selection_name] = es @values[:dselname].to_s      
        lib = Selection.select(:library_name).where(:selection_name => @update_hash[:selection_name]).first
        @update_hash[:library_name] = lib[:library_name]      
        @update_hash[:statistic_file] = @values[:statpath]
        @row_id.to_s
      end #up_ds

      def up_cluster
        @id_column = :cluster_id
        @update_hash[:parameters] = es @values[:paras].to_s
        @update_hash[:dataset_name] = es @values[:ddsname].to_s
        lib_sel = SequencingDataset.select(:library_name, :selection_name).where(:dataset_name => @update_hash[:dataset_name]).first
        @update_hash[:selection_name] = lib_sel[:selection_name]
        @update_hash[:library_name] = lib_sel[:library_name]
      end

      def up_target
        @update_hash[:species] = @values[:sp]
        @update_hash[:tissue] = @values[:tis]
        @update_hash[:cell] = @values[:cell]
      end
      
      def up_motlist
        @table = :motifs_motif_lists
        DB[:motifs_motif_lists].select(:motif_sequence).where(:list_name => @row_id).all.each_with_index do |motif, index|
          where_hash = {:list_name => @row_id, :motif_sequence => motif[:motif_sequence].to_s}
          upd_hash = {:target => "#{es @values["mt#{index}"].to_s}", :receptor => "#{es @values["mr#{index}"].to_s}", :source => "#{es @values["ms#{index}"].to_s}" }
          @mot_updates[index] = [where_hash, upd_hash]
        end
      end
      
      def up_performance
        where_hash = {:library_name => @values[:dlibname], :peptide_sequence => @values[:eleid]}
        upd_hash = {:performance => @values[:perf]}
        @perf_update = [where_hash, upd_hash]
      end

      def find_target
        result = nil
        unless @values[:dspecies].nil? && @values[:dtissue].nil? && @values[:dcell].nil?
          target = Target.select(:target_id).where(:species => @values[:dspecies].to_s, :tissue => @values[:dtissue].to_s, :cell => @values[:dcell].to_s).first
          result = target[:target_id] unless target.nil?
        end
        if option_selected?(@values[:dtar])
          target_elements = @values[:dtar].split(/ - /)
          result = Target.select(:target_id).where(:species => target_elements[0], :tissue => target_elements[1], :cell => target_elements[2])
        end
        result
      end

    end #class
  
    def update_data(values)
      up = UpdateData.new(values)
      errors = up.update
    end #update
      
    def insert_data(values)
      d = InsertData.new(values)  
      errors = d.try_insert
      if errors.empty? && values[:submittype] == "selection"
        apply_auto_selections(values[:selname])
      end
      errors
    end #insert

  end

  helpers DBInserter 
end
