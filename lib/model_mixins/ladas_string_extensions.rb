# encoding: utf-8
module ModelMixins
  module Ladas
    module StringExtensions

      # init
      def self.included(base)
#      base.send :extend, ClassMethods
        base.send :include, InstanceMethods
      end

#    module ClassMethods
#    end

      module InstanceMethods
        # hodi vsechno na male pismena a nahradi nepatricne znaky
        # ve stringu za -
        def codeize
          accented_chars = ' /\\éěřťýúůíóášďžčňÉĚŘŤÝÚŮÍÓÁŠĎŽČŇ.'
          ascii_chars = '---eertyuuioasdzcneertyuuioasdzcn_'
          str = self.mb_chars.downcase.tr(' ', '-') # Downcase and space => dash
          accented_chars.split('').each_index { |i| str.gsub!(accented_chars.split('')[i], "#{ascii_chars.split('')[i]}") }
          str.gsub!(/[^0-9a-z\-_]*/, '').to_s
        end

        def to_s_clean
          self.to_s.gsub(/[\.][0]+$/, '')
        end

      end
    end
  end
end