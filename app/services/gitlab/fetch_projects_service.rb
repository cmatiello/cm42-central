module Gitlab
  class FetchProjectsService
    def initialize(project)
      @project = project
    end

    def fetch
      @api ||= GitlabApi::FetchProjects.perform(
        gitlab_integration.data['url'],
        gitlab_integration.data['token']
      )

      api.success?
    end

    def projects
      return unless api&.success?

      api.data.map { |project| Gitlab::Project.new(project) }
    end

    def error_message
      api&.error_message
    end

    private

    def gitlab_integration
      @project.integrations.find_by(kind: 'gitlab')
    end

    attr_reader :project, :api
  end
end
