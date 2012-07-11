require 'htmlentities'
module ModelMixins
  module Ladas
    module HtmlEntities
      def html_entities_decode
        coder = HTMLEntities.new
        coder.decode(self.to_s)
      end

      def html_entities_encode
        coder = HTMLEntities.new
        coder.encode(self.to_s)
      end
    end
  end
end