require 'sinatra/base'
# this module implements the (reverse) wildcard search when using the peptide property search
module Sinatra
  module WCSearch 
    class WildcardSearch
      include Rack::Utils
      alias_method :h, :escape_html
      WILDCARD = {:X => "ARNDCQEGHILKMFPSTWYV", :+ => "KRH", :- => "DE", :B => "TSGCNQY", :Z => "AVLIPMFW", :< => "AGS", :J => "ANDCGILPSTV", :> => "REQHKMFWY", :U => "HFWY"}
      AMINOACIDS = "ARNDCQEGHILKMFPSTWYV"

      def initialize(seq)
        @seq = seq.upcase
        @regexp = ''
      end

      # this method builds the regexp from the given wildcard sequence
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
  
  def wc_search(seq)
    wc = WildcardSearch.new(seq)
    wildcard = wc.build_string
  end
  def rev_wc_search(seq)
    rev_wc = ReverseWildcardSearch.new(seq)
    wildcard = rev_wc.build_string
  end

  end
  helpers WCSearch 
end
