module GitlabApi
  class Base
    attr_accessor :response

    def self.perform(*attrs)
      new(*attrs).perform
    end

    def connection
      @connection ||= Faraday.new(url: gitlab_api_url) do |faraday|
        faraday.headers['Content-Type'] = 'application/json'
        faraday.headers['Accept'] = 'application/json'
        faraday.headers['Private-Token'] = gitlab_private_token
        faraday.adapter Faraday.default_adapter
      end
    end

    def get(path)
      self.response = connection.get(path)
      self
    end

    def data
      @data ||= JSON.parse(response.body)
    end

    def success?
      response.status == self.class::SUCCESS_RESPONSE_CODE
    end

    def error_message
      return if success?

      data['message'] || data['error']
    end

    private

    attr_reader :gitlab_api_url, :gitlab_private_token
  end
end
