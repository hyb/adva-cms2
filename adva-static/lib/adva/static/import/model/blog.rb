module Adva
  class Static
    class Import
      module Model
        class Blog < Section
          class << self
            def recognize(sources)
              return [] if sources.blank?

              sources = Array(sources)
              posts = sources.select { |source| Post.permalink?(source) }
              return [] if posts.blank?

              blogs = posts.map { |post| Post.strip_permalink(post) }.flatten.uniq
              blogs = blogs.map { |blog| sources.detect { |source| blog.path == source.path } || blog }
              sources.replace(sources - blogs - posts)
              blogs.map { |source| new(source) }
            end
          end

          def attribute_names
            super + [:posts_attributes]
          end

          def posts_attributes
            Post.recognize(source.files).map(&:attributes)
          end
        end
      end
    end
  end
end