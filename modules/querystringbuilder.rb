require 'sinatra/base'
require './modules/wcsearch'
require './modules/utilities'
require './modules/neighboursearch'
# this module builds larger sql queries that can't be directly projected by sequel
# so we use raw sql queries via sequel instead
# these queries are mainly used when using the peptide property search
module Sinatra
  module QueryStringBuilder

    class NeighbourSearch
      def initialize
      end
    end #class

    def build_property_array(params)
      querystring = ''
      placeholders = Array.new

      if option_selected?(params['type'])
        if params['type'] == "complete sequence" && !option_selected?(params[:blos])
          querystring << 'peptides_sequencing_datasets.peptide_sequence = ? '
          placeholders.insert(-1, params['seq'].to_s.upcase)
        elsif params['type'] == "partial sequence"
          querystring << 'peptides_sequencing_datasets.peptide_sequence LIKE ? '
          likestr = '%' << params['seq'].to_s.upcase << '%'
          placeholders.insert(-1, likestr)
        elsif params['type'] == "wildcard sequence"
          querystring << 'peptides_sequencing_datasets.peptide_sequence REGEXP ? '
          wildcard = wc_search(params[:seq.to_s.upcase])
          placeholders.insert(-1, wildcard)
        elsif params['type'] == "reverse wildcard sequence"
          querystring << 'peptides_sequencing_datasets.peptide_sequence REGEXP ? '
          wildcard = rev_wc_search(params[:seq].to_s.upcase) 
          placeholders.insert(-1, wildcard)
        end
      end

      if option_selected?(params['l']) && !option_selected?(params['s'])
        if current_user.admin?
          querystring << 'AND libraries.library_name = ? ' if querystring.length > 0
          querystring << 'libraries.library_name = ? ' if querystring.length == 0
          placeholders.insert(-1, params['l'].to_s)
        else
          allowed_sel = DB[:selections_sequel_users].select(:selection_name).where(:id => current_user.id).map(:selection_name)
          selections = Selection.select(:selection_name).where(:library_name => params['l'].to_s, :selection_name=> allowed_sel).map(:selection_name)
          querystring << 'AND selections.selection_name IN (' if querystring.length > 0
          querystring << 'selections.selection_name IN (' if querystring.length == 0
          (0...selections.size).each do |index|
            querystring << "?,"
          end
          querystring.chop!
          querystring << ") "
          placeholders.insert(-1, *selections)
        end
      elsif option_selected?(params['s']) && !option_selected?(params['ds'])
        querystring << 'AND selections.selection_name = ? ' if querystring.length > 0
        querystring << 'selections.selection_name = ? ' if querystring.length == 0
        placeholders.insert(-1, params['s'].to_s)
      elsif option_selected?(params['ds'])
        querystring << 'AND sequencing_datasets.dataset_name = ? ' if querystring.length > 0
        querystring << 'sequencing_datasets.dataset_name = ? ' if querystring.length == 0
        placeholders.insert(-1, params['ds'].to_s)
      end
      
      unless current_user.admin?
        if params['l'].nil? && params['s'].nil? && params['ds'].nil?
          datasets = DB[:sequel_users_sequencing_datasets].select(:dataset_name).where(:id => current_user.id).map(:dataset_name)
          querystring << 'AND sequencing_datasets.dataset_name IN (' if querystring.length > 0
          querystring << 'sequencing_datasets.dataset_name IN (' if querystring.length == 0
          (0...datasets.size).each do |index|
            querystring << "?,"
          end
          querystring.chop!
          querystring << ") "
          placeholders.insert(-1, *datasets)
        end
      end      


      if option_selected?(params['ts'])
        querystring << 'AND sel_target.species = ? ' if querystring.length > 0
        querystring << 'sel_target.species = ? ' if querystring.length == 0
        placeholders.insert(-1, params['ts'].to_s)
      end
      if option_selected?(params['tt'])
        querystring << 'AND sel_target.tissue = ? ' if querystring.length > 0
        querystring << 'sel_target.tissue = ? ' if querystring.length == 0
        placeholders.insert(-1, params['tt'].to_s)
      end

      if option_selected?(params['tc'])
        querystring << 'AND sel_target.cell = ? ' if querystring.length > 0
        querystring << 'sel_target.cell = ? ' if querystring.length == 0
        placeholders.insert(-1, params['tc'].to_s)
      end
      
      if option_selected?(params['ss'])
        querystring << 'AND seq_target.species = ? ' if querystring.length > 0
        querystring << 'seq_target.species = ? ' if querystring.length == 0
        placeholders.insert(-1, params['ss'].to_s)
      end 

      if option_selected?(params['st'])
        querystring << 'AND seq_target.tissue = ? ' if querystring.length > 0
        querystring << 'seq_target.tissue = ? ' if querystring.length == 0
        placeholders.insert(-1, params['st'].to_s)
      end 

      if option_selected?(params['sc'])
        querystring << 'AND seq_target.cell = ? ' if querystring.length > 0
        querystring << 'seq_target.cell = ? ' if querystring.length == 0
        placeholders.insert(-1, params['sc'].to_s)
      end 

      if option_selected?(params['ralt'])
        querystring << 'AND rank < ? ' if querystring.length > 0
        querystring << 'rank < ? ' if querystring.length == 0
        placeholders.insert(-1, params['ralt'].to_i)
      end

      if option_selected?(params['regt'])
        querystring << 'AND reads > ? ' if querystring.length > 0
        querystring << 'reads > ? ' if querystring.length == 0
        placeholders.insert(-1, params['regt'].to_i)
      end

      if option_selected?(params['dgt'])
        querystring << 'AND dominance > ? ' if querystring.length > 0
        querystring << 'dominance > ? ' if querystring.length == 0
        placeholders.insert(-1, params['dgt'].to_f)
      end

      if option_selected?(params['tp'])
        querystring << 'AND results.result_id NOT NULL ' if querystring.length > 0
        querystring << 'results.result_id NOT NULL ' if querystring.length == 0
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

