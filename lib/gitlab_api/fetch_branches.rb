module GitlabApi
  class FetchBranches < GitlabApi::Base
    SUCCESS_RESPONSE_CODE = 200

    def initialize(gitlab_api_url, gitlab_private_token, gitlab_project_id)
      @gitlab_api_url = gitlab_api_url
      @gitlab_private_token = gitlab_private_token
      @gitlab_project_id = gitlab_project_id
    end

    def perform
      get(path)
    end

    private

    def path
      "projects/#{@gitlab_project_id}/repository/branches"
    end
  end
end
