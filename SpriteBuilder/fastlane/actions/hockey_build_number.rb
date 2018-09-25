require 'credentials_manager'
require 'open-uri'
require 'json'

module Fastlane
  module Actions
    module SharedValues
    end

    class HockeyBuildNumberAction < Action
      def self.run(options)
        find_latest_build(options[:token], options[:app_id])  
      end
      
      def self.description
        "Fetch highest build number in Hockey"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :token,
            env_name: "FL_HOCKEY_TOKEN",
            description: "Token used to authenticate with Hockey",
            optional: false,
          ),
          FastlaneCore::ConfigItem.new(key: :app_id,
            env_name: "FL_HOCKEY_APP_ID",
            description: "The 'App ID' from Hockey",
            optional: false,
          )
        ]
      end

      def self.output
        []
      end

      def self.author
        "Cody Rayment"
      end

      def self.is_supported?(platform)
        [:ios].include? platform
      end
      
      def self.find_latest_build(token, app_id)
        json = fetch_json(token, app_id)

        UI.crash! "Failed to fetch versions info from Hockey" unless json && json["app_versions"]
        versions = json["app_versions"]

        if versions.count == 0
          UI.message "No versions found. Returning 0"
          return 0
        end

        UI.message "Found #{versions.count} versions"

        max_version = versions.max_by { |version| version["version"].to_i }
        UI.message "Version with highest build number: #{max_version}"
        build_number = max_version["version"].to_i
        UI.success "Highest build_number: #{build_number}"

        return build_number
      end

      def self.fetch_json(token, app_id)
        begin
          open("https://rink.hockeyapp.net/api/2/apps/#{app_id}/app_versions", "X-HockeyAppToken" => token) do |f|
            return nil unless f.status.first == "200"
            return JSON.parse(f.read)
          end
        rescue OpenURI::HTTPError => error
          return nil
        end 
      end
    end
  end
end