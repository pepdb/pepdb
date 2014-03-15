require 'sinatra/base'
# this module adds some convenience methods

module Sinatra
  module Tooltips
    def get_tooltip_text(column_name)
      case column_name
      when /Name/ 
        "designation of the individual library"
      when /Carrier/ 
        "Specifies the structure in which the peptides are embedded. For example, a phage or viral vector"
      when /Insert_length/
        "Length of the amino acid sequences that make up the library peptides"
      when /Encoding_scheme/
        "The encoding scheme reflects which codons were used to encode the randomized peptides. Examples are: <ul>
        <li>NNN (N= G,A,T or C; All nucleotides possible at all positions in the codon)</li><li>NNK (K = G or T; G or T at the third position in the codon)</li><li>NNS (S = G or C; G or C at the third position in the codon)</li><li>NNB (B = G, C or T; G, C or T at the third position in the codon)</li><li>Trimer (One codon per amino acid possible)</li></ul>"
      else
        "nuthin"
      end
    end

  end
  helpers Tooltips
end
