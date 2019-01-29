module Gitlab
  class FetchProjectsService
    delegate :error_message, to: :api, allow_nil: true

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

    private

    def gitlab_integration
      @project.integrations.find_by(kind: 'gitlab')
    end

    attr_reader :project, :api
  end
end
