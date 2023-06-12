namespace :route_formatter do
  desc "TODO"
  task csv: :environment do |_t|
    class CSVFormatter
      def initialize
        @buffer = []
      end

      def result
        @buffer.join("\n")
      end

      def section_title(title); end

      def section(routes)
        routes.each do |r|
          @buffer << [r[:name], r[:verb], r[:path], r[:reqs]].join(",") if r[:verb] == 'GET'
        end
      end

      def header(_routes)
        @buffer << %w"Prefix Verb URI_Pattern Controller#Action".join(",")
      end

      def no_routes
        @buffer << ""
      end
    end
    require "action_dispatch/routing/inspector"
    all_routes = Rails.application.routes.routes
    inspector = ActionDispatch::Routing::RoutesInspector.new(all_routes)
    puts inspector.format(CSVFormatter.new)
  end
end