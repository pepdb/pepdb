helpers do
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

 
  def build_property_array(params)
    querystring = ''
    placeholders = Array.new
       
    if !params['type'].nil? 
      if params['type'] == "exact sequence"
        querystring << 'peptides.peptide_sequence = ?'
        placeholders.insert(-1, params['seq'].to_s.upcase!)
      elsif params['type'] == "partial sequence"
        querystring << 'peptides.peptide_sequence LIKE ?'
        likestr = '%' << params['seq'].to_s.upcase << '%'
        placeholders.insert(-1, likestr)
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
      querystring << ' AND species = ?' if querystring.length > 0
      querystring << 'species = ?' if querystring.length == 0
      placeholders.insert(-1, params['ts'].to_s)
    end 
    if !params['tt'].nil?
      querystring << ' AND tissue = ?' if querystring.length > 0
      querystring << 'tissue = ?' if querystring.length == 0
      placeholders.insert(-1, params['tt'].to_s)
    end 

    if !params['tc'].nil?
      querystring << ' AND cell = ?' if querystring.length > 0
      querystring << 'cell = ?' if querystring.length == 0
      placeholders.insert(-1, params['tc'].to_s)
    end 
    ####### sequenced targets???     #############
=begin
    if !params['ss'].nil?
      querystring[:] = params['ss']
    end 

    if !params['st'].nil?
      querystring[:] = params['st']
    end 

    if !params['sc'].nil?
      querystring[:] = params['sc']
    end 
=end
    
    if !params['ralt'].nil? && !params['ragt'].nil?
      querystring << ' AND rank BETWEEN ? AND ?' if querystring.length > 0
      querystring << 'rank BETWEEN ? AND ?' if querystring.length == 0
      placeholders.insert(-1, params['ragt'].to_i, params['ralt'].to_i)
    elsif !params['ralt'].nil?
      querystring << ' AND rank < ?' if querystring.length > 0
      querystring << 'rank < ?' if querystring.length == 0
      placeholders.insert(-1, params['ralt'].to_i)
    elsif !params['ragt'].nil?
      querystring << ' AND rank > ?' if querystring.length > 0
      querystring << ' AND rank > ?' if querystring.length > 0
      placeholders.insert(-1, params['ragt'].to_i)
    end 

    if !params['relt'].nil? && !params['regt'].nil?
      querystring << ' AND reads BETWEEN ? AND ?' if querystring.length > 0
      querystring << 'reads BETWEEN ? AND ?' if querystring.length == 0
      placeholders.insert(-1, params['regt'].to_i, params['relt'].to_i)
    elsif !params['relt'].nil?
      querystring << ' AND reads < ?' if querystring.length > 0
      querystring << 'reads < ?' if querystring.length == 0
      placeholders.insert(-1, params['relt'].to_i)
    elsif !params['regt'].nil?
      querystring << ' AND rank > ?' if querystring.length > 0
      querystring << 'rank > ?' if querystring.length == 0
      placeholders.insert(-1, params['regt'].to_i)
    end 

    if !params['dlt'].nil? && !params['dgt'].nil?
      querystring << ' AND dominance BETWEEN ? AND ?' if querystring.length > 0
      querystring << 'dominance BETWEEN ? AND ?' if querystring.length == 0
      placeholders.insert(-1, params['dgt'].to_f, params['dlt'].to_f)
    elsif !params['dlt'].nil?
      querystring << ' AND dominance < ?' if querystring.length > 0
      querystring << 'dominance < ?' if querystring.length == 0
      placeholders.insert(-1, params['dlt'].to_f)
    elsif !params['dgt'].nil?
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
end
