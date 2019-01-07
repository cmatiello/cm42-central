module GitlabApi
  class FetchProjects < GitlabApi::Base
    SUCCESS_RESPONSE_CODE = 200

    def initialize(gitlab_api_url, gitlab_private_token)
      @gitlab_api_url = gitlab_api_url
      @gitlab_private_token = gitlab_private_token
    end

    def perform
      get(path)
    end

    private

    def path
      'projects'
    end
  end
end
