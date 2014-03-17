require 'sinatra/base'
require 'xmlsimple'
# this module adds some convenience methods

module Sinatra
  module Tooltips
    Tips = XmlSimple.xml_in('./modules/tooltips.xml', :ForceArray=> false)
    def get_element_type
      case request.path
      when /libraries/
        "library"
      when /selections/
        "selection"
      when /datasets/
        "sequencing_dataset"
      when /cluster-infos/
        "cluster"
      when /info-tables/
        request.params["ref"].tr(" ", "_").downcase
      when /show_sn_table/
        if request.params["ref"] == "Library"
          "selection"
        elsif request.params["ref"] == "Selection"
          "sequencing_dataset"
        elsif request.params["ref"] == "Sequencing Dataset"
          "peptide"
        end
      when /show-info/
        if request.params["ref"] == "Library"
          "selection"
        elsif request.params["ref"] == "Selection"
          "sequencing_dataset"
        elsif request.params["ref"] == "Sequencing Dataset"
          "peptide"
        elsif request.params["ref"] == "Clusters"
          "peptide"
        end
      else
        "nix"
      end
    end

    def get_tooltip_text(column_name)
      type = get_element_type
      puts "type: #{type}"
      puts request.url
      puts request.path
      puts "column: #{column_name}"
      #puts Tips.inspect
      Tips[type][column_name.to_s]
    end

  end
  helpers Tooltips
end
