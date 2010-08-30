module Adva
  module Importers
    class Directory
      module Models
        class Page < Section
          PATTERN = %r(/[\w-]+\.yml$)
        
          class << self
            def build(paths)
              return [] if paths.blank?

              paths = Array(paths)
              pages = paths.select { |path| path.to_s =~ PATTERN }
              paths.replace(paths - pages)
              pages.map { |path| new(path) }.uniq
            end
          end
        
          def initialize(path)
            path = File.dirname(path) if File.basename(path, File.extname(path)) == 'index'
            super
          end
          
          def attribute_names
            [:site_id, :type, :path, :title, :article_attributes]
          end
          
          def model
            ::Page
          end
        
          def article_attributes
            attributes = { :title => title, :body => body }
            record.article && record.id ? attributes.merge(:id => record.article.id.to_s) : attributes
          end
        end
      end
    end
  end
end