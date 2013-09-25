require 'sinatra/base'

module Sinatra
  module QueryStringBuilder
    class WildcardSearch
      include Rack::Utils
      alias_method :h, :escape_html 
      WILDCARD = {:X => "ARNDCQEGHILKMFPSTWYV", :+ => "KRH", :- => "DE", :B => "TSGCNQY", :Z => "AVLIPMFW", :< => "AGS", :J => "ANDCGILPSTV", :> => "REQHKMFWY", :U => "HFWY"}    
      AMINOACIDS = "ARNDCQEGHILKMFPSTWYV"

      def initialize(seq)
        @seq = seq.upcase
        @regexp = ''
      end
      
      def build_string
        bracket_open = false
        bracket_class = ''
        @seq.each_char do |char|
          if bracket_open
            if char == "]"
              bracket_open = false
              @regexp << bracket_class + "]"
              bracket_class = ''
            else
              test_char(char, bracket_class, bracket_open) 
            end # ]
          else
            if char == "["
              bracket_open = true
              bracket_class << '['
            else
              test_char(char, @regexp, bracket_open) 
            end # [
          end # bracket_open
        end # char
        puts @regexp
        @regexp
      end # end buid_string
      
      def test_char(char, container, open)
        if AMINOACIDS.include? char
          container << char
        elsif WILDCARD[char.to_sym] != nil
          container << "[" + WILDCARD[char.to_sym] + "]" unless open
          container << WILDCARD[char.to_sym] if open
        else
          raise ArgumentError, "invalid wildcard character #{h char} given!"
        end # AMINO
      end #test_char

    end # end class

    class ReverseWildcardSearch
      include Rack::Utils
      alias_method :h, :escape_html 
      REVERSEWC = {:A => "Z<J", :R => "+>", :N => "BJ", :D => "-J", :C => "BJ", :Q => "B>", :E => "->", :G => "B<J", :H => "+>U", :I => "ZJ", :L => "ZJ", :K => "+>", :M => "Z>", :F => "Z>U", :P => "ZJ", :S => "B<J", :T => "BJ", :W => "Z>U", :Y => "B>U", :V => "ZJ"}
      def initialize(seq)
        @seq = seq.upcase
        @regexp = ''
        @wildcard = ''
      end
      
      def build_string
        @seq.each_char do |char|
          unless REVERSEWC[char.to_sym].nil?
            @wildcard << "[" << REVERSEWC[char.to_sym] << "]"
          else
            raise ArgumentError, "invalid amino acid #{h char} given!"
          end
        end #char
        puts @wildcard
        wc = WildcardSearch.new(@wildcard)
        @regexp = wc.build_string
      end #build_string
    end # class

    def build_property_array(params)
      querystring = ''
      placeholders = Array.new

      if !params['type'].nil?
        if params['type'] == "complete sequence"
          querystring << 'peptides.peptide_sequence = ?'
          placeholders.insert(-1, params['seq'].to_s.upcase!)
        elsif params['type'] == "partial sequence"
          querystring << 'peptides.peptide_sequence LIKE ?'
          likestr = '%' << params['seq'].to_s.upcase << '%'
          placeholders.insert(-1, likestr)
        elsif params['type'] == "wildcard sequence"
          querystring << 'peptides.peptide_sequence REGEXP ?'
          wc = WildcardSearch.new(params[:seq])
          wildcard = wc.build_string
          placeholders.insert(-1, wildcard)
        elsif params['type'] == "reverse wildcard sequence"
          querystring << 'peptides.peptide_sequence REGEXP ?'
          rwc = ReverseWildcardSearch.new(params[:seq].upcase) 
          wildcard = rwc.build_string
          placeholders.insert(-1, wildcard)
        end
      end

      if !params['l'].nil?
        querystring << ' AND libraries.library_name = ?' if querystring.length > 0
        querystring << 'libraries.library_name = ?' if querystring.length == 0
        placeholders.insert(-1, params['l'].to_s)
      end

      if !params['s'].nil?
        querystring << ' AND selections.selection_name = ?' if querystring.length > 0
        querystring << 'selections.selection_name = ?' if querystring.length == 0
        placeholders.insert(-1, params['s'].to_s)
      end

      if !params['ds'].nil?
        querystring << ' AND sequencing_datasets.dataset_name = ?' if querystring.length > 0
        querystring << 'sequencing_datasets.dataset_name = ?' if querystring.length == 0
        placeholders.insert(-1, params['ds'].to_s)
      end

      if !params['pl'].nil?
        querystring << ' AND peptide_length = ?' if querystring.length > 0
        querystring << 'peptide_length = ?' if querystring.length == 0
        placeholders.insert(-1, params['pl'].to_i)
      end

      if !params['sr'].nil?
        querystring << ' AND selection_round = ?' if querystring.length > 0
        querystring << 'selection_round = ?' if querystring.length == 0
        placeholders.insert(-1, params['sr'].to_i)
      end

      if !params['ts'].nil?
        querystring << ' AND sel_target.species = ?' if querystring.length > 0
        querystring << 'sel_target.species = ?' if querystring.length == 0
        placeholders.insert(-1, params['ts'].to_s)
      end
      if !params['tt'].nil?
        querystring << ' AND sel_target.tissue = ?' if querystring.length > 0
        querystring << 'sel_target.tissue = ?' if querystring.length == 0
        placeholders.insert(-1, params['tt'].to_s)
      end

      if !params['tc'].nil?
        querystring << ' AND sel_target.cell = ?' if querystring.length > 0
        querystring << 'sel_target.cell = ?' if querystring.length == 0
        placeholders.insert(-1, params['tc'].to_s)
      end
      
      if !params['ss'].nil?
        querystring << ' AND seq_target.species = ?' if querystring.length > 0
        querystring << 'seq_target.species = ?' if querystring.length == 0
        placeholders.insert(-1, params['ss'].to_s)
      end 

      if !params['st'].nil?
        querystring << ' AND seq_target.tissue = ?' if querystring.length > 0
        querystring << 'seq_target.tissue = ?' if querystring.length == 0
        placeholders.insert(-1, params['st'].to_s)
      end 

      if !params['sc'].nil?
        querystring << ' AND seq_target.cell = ?' if querystring.length > 0
        querystring << 'seq_target.cell = ?' if querystring.length == 0
        placeholders.insert(-1, params['sc'].to_s)
      end 

      if !params['ragt'].nil?
        querystring << ' AND rank > ?' if querystring.length > 0
        querystring << ' AND rank > ?' if querystring.length == 0
        placeholders.insert(-1, params['ragt'].to_i)
      end

      if !params['regt'].nil?
        querystring << ' AND reads > ?' if querystring.length > 0
        querystring << 'reads > ?' if querystring.length == 0
        placeholders.insert(-1, params['regt'].to_i)
      end

      if !params['dgt'].nil?
        querystring << ' AND dominance > ?' if querystring.length > 0
        querystring << 'dominance > ?' if querystring.length == 0
        placeholders.insert(-1, params['dgt'].to_f)
      end

      if !params['tp'].nil?
        querystring << ' AND results.result_id NOT NULL' if querystring.length > 0
        querystring << 'results.result_id NOT NULL' if querystring.length == 0
      end

      return querystring, placeholders
    end

    def build_cdom_string(params)
      querystring = ''
      placeholders = Array.new
      if !params[:ds_dom_max].empty? && !params[:ds_dom_min].empty?
        querystring << 'dominance BETWEEN ? AND ?'
        placeholders.insert(-1, params[:ds_dom_min].to_f, params[:ds_dom_max].to_f)
      elsif !params[:ds_dom_max].empty?
        querystring << 'dominance < ?'
        placeholders.insert(-1, params[:ds_dom_max].to_f)
      elsif !params[:ds_dom_min].empty?
        querystring << 'dominance > ?'
        placeholders.insert(-1, params[:ds_dom_min].to_f)
      end

      return querystring, placeholders
    end

    def build_rdom_string(params)
      querystring = ''
      placeholders = Array.new
      if !params[:ref_dom_max].empty? && !params[:ref_dom_min].empty?
        querystring << 'dominance BETWEEN ? AND ?'
        placeholders.insert(-1, params[:ref_dom_min].to_f, params[:ref_dom_max].to_f)
      elsif !params[:ref_dom_max].empty?
        querystring << 'dominance < ?'
        placeholders.insert(-1, params[:ref_dom_max].to_f)
      elsif !params[:ref_dom_min].empty?
        querystring << 'dominance > ?'
        placeholders.insert(-1, params[:ref_dom_min].to_f)
      end
      
      return querystring, placeholders
    end
    
    def build_formdrop_string(params)
      querystring = ''
      placeholders = Array.new
      if !params[:selected1].nil? && !params[:selected2].nil?
        querystring << '? = ? AND ? = ?'                                                                                         
        placeholders.insert(-1, params[:where1].to_sym, params[:selected1].to_s, params[:where2].to_sym, params[:selected2].to_s)
      elsif !params[:selected1].nil?
        querystring << '? = ?'                                                                                         
        placeholders.insert(-1, params[:where1].to_sym, params[:selected1].to_s)
      elsif !params[:selected2].nil?
        querystring << '? = ?'                                                                                         
        placeholders.insert(-1, params[:where2].to_sym, params[:selected2].to_s)
     end       
      return querystring, placeholders
    end

  end

  helpers QueryStringBuilder
end

