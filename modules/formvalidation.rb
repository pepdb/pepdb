require 'sinatra/base'

module Sinatra
  module FormValidation

    def validate_form(params)
      if params[:submittype] == "library"
        validate_library(params)
      elsif paras[:submittype] == "selection"
        validate_selection(params)
      elsif paras[:submittype] == "dataset"
        validate_selection(params)
      elsif paras[:submittype] == "cluster"
        validate_selection(params)
      elsif paras[:submittype] == "result"
        validate_selection(params)
      elsif paras[:submittype] == "target"
        validate_selection(params)
      elsif paras[:submittype] == "motif"
        validate_selection(params)
      end
    end
    
    def validate_library(params)
      name = escape_html params[:libname]
      enc = escape_html params[:encodings]
      carrier = escape_html params[:carrier]
      produced = escape_html params[:prod]
      insert = escape_html params[:insert]
      diversity = escape_html params[:diversity]
      date = escape_html params[:date]
      
      DB[:libraries].insert(:library_name => name, :encoding_scheme => enc, :carrier => carrier, :produced_by => produced, :insert_length => insert, :peptide_diversity => diversity, :date => date)
    end
      
  
  end

  helpers FormValidation
end
