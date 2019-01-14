module Gitlab
  class FetchBranchesService
    def initialize(project)
      @project = project
    end

    def fetch
      @api ||= GitlabApi::FetchBranches.perform(
        gitlab_integration.data['url'],
        gitlab_integration.data['token'],
        gitlab_integration.data['project_id']
      )

      api.success?
    end

    def branches
      return unless api&.success?

      api.data.map { |branch| Gitlab::Branch.new(branch) }
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
