require 'sinatra/base'

module Sinatra
  module Utilities
    include Rack::Utils
    alias_method :h, :escape_html
  
    def choose_data(params)
      if params['selector'] == "sel"
        datatype = Selection.select(:selection_name).where(:library_name => params['checkedElem'])
        columnname = :selection_name
      elsif params['selector'] == "ds"
        datatype = SequencingDataset.select(:dataset_name).where(:selection_name => params['checkedElem'])
        columnname = :dataset_name
      end

      return datatype, columnname
    end

  end

  helpers Utilities
end
