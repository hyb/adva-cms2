require 'routing_filter'

# If the path is, aside from a slash and an optional locale, the leftmost part
# of the path, replace it by "sections/:id" segments.

module RoutingFilter
  class SectionPath < Filter
    extend ActiveSupport::Memoizable

    cattr_accessor :default_port
    self.default_port = '80'

    cattr_accessor :exclude
    self.exclude = %r(^/admin)

    def around_recognize(path, env, &block)
      # p "#{self.class.name}: #{path}"
      if !excluded?(path)
        search, replace = recognition(host(env), path)
        path.sub!(%r(^/([\w]{2,4}/)?(#{search})(?=/|\.|\?|$)), "/#{$1}#{replace}#{$3}") if search
      end
      yield
    end

    def around_generate(params, &block)
      yield.tap do |path|
        # p "#{self.class.name}: #{path}"
        if !excluded?(path)
          search, replace = *generation(path)
          path.sub!(search) { "#{replace}#{$3}" } if search
          path.replace("/#{path}") unless path[0, 1] == '/'
        end
      end
    end

    protected

      def excluded?(path)
        path =~ exclude
      end

      def recognition(host, path)
        if site = Site.by_host(host) and path =~ recognition_pattern(site)
          section = site.sections.where(:path => $2).first
          [$2, "#{$1}#{section.type.pluralize.downcase}/#{section.id}"]
        end
      end

      def recognition_pattern(site)
        paths = site.sections.map(&:path).reject(&:blank?)
        paths = paths.sort { |a, b| b.size <=> a.size }.join('|')
        paths.empty? ? %r(^$) : %r(^/([\w]{2,4}/)?(#{paths})(?=/|\.|\?|$))
      end

      def generation(path)
        if path =~ generate_pattern
          section = Section.find($2.to_i)
          ["/#{$1}/#{$2}", "#{section.path}#{$3}"]
        end
      end

      def generate_pattern
        types = Section.types.map { |type| type.downcase.pluralize }.join('|')
        %r(/(sections|#{types})/([\d]+(/?))(\.?))
      end

      def host(env)
        host, port = env.values_at('SERVER_NAME', 'SERVER_PORT')
        port == default_port ? host : [host, port].compact.join(':')
      end
  end
end
