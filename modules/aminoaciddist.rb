require 'sinatra/base'
# this module adds some convenience methods

module Sinatra
  module AminoAcidDistribution 
    def get_amino_acid_dist(dataset)
      dist_hash = {}
      positions = []
      line_found = false
      filename = settings.root + "/statisticfiles/" + dataset.tr(" ", "_")
      if (File.exists?(filename) && File.readable?(filename))
        file = File.new(filename)
        lines = file.readlines
        lines.each do |line|
          unless line_found
            if line.match(/^\s+1/)
              line_found = true
              positions = line.scan(/[0-9]/)
              puts positions.inspect
            end  
          else
            acid_values = {}
            unless line.match(/^\s/)
              acid_values = {}
              values = line.scan(/\S+/)
              1.upto(positions[-1].to_i) do |position|
                acid_values[position] = values[position].to_f
              end
              dist_hash[values[0]] = acid_values
            end  
          end
        end
        dist_hash
      else
        raise ArgumentError, "requested sequencing dataset has no statistic file"
      end
    end
    
    def get_cell_color(value)
      if value > 3.0
        "darkbluecell"
      elsif (value <= 3.0 && value > 1.5)
        "lightbluecell"
      elsif (value <= 1.5 && value > 0.67)
        ""
      elsif (value <= 0.67 && value > 0.33)
        "lightredcell"
      elsif (value <=0.33)
        "darkredcell"
      end
    end

  end
  helpers AminoAcidDistribution 
end
