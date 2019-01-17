module GitlabApi
  class CreateHook < GitlabApi::Base
    SUCCESS_RESPONSE_CODE = 201

    def initialize(gitlab_api_url, gitlab_private_token, gitlab_project_id, params)
      @gitlab_project_id = gitlab_project_id
      @gitlab_private_token = gitlab_private_token
      @gitlab_api_url = gitlab_api_url
      @params = params
    end

    def perform
      post do |req|
        req.url path
        req.body = @params.to_json
      end
    end

    private

    def path
      "projects/#{@gitlab_project_id}/hooks"
    end
  end
end
