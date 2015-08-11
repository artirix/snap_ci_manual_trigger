module SnapCiManualTrigger
  class Service

    CONNECTION_URL = 'https://api.snap-ci.com'

    HEADERS = {
      'Accept'       => 'application/vnd.snap-ci.com.v1+json',
      'Content-type' => 'application/json',
    }

    attr_reader :user, :api_key, :owner, :repository, :branch_name, :connection

    def initialize(user:, api_key:, owner:, repository:, branch_name:, connection: nil)
      @user        = user
      @api_key     = api_key
      @owner       = owner
      @repository  = repository
      @branch_name = branch_name
      @connection  = connection || build_connection
    end

    def new_pipeline
      response = call_new_pipeline
      check_unauthorized(response)
      check_not_found(response)

      parsed_response = parse_response response
      parsed_response['counter']
    end

    def manual_stage(pipeline:, stage:)
      response = call_manual_stage pipeline, stage
      check_unauthorized(response)
      check_not_found(response, pipeline, stage)

      parsed_response = parse_response response
      parsed_response['_embedded']['_links']['self']['href']
    end

    def manual_stage_on_new_pipeline(stage)
      pipeline_id = new_pipeline
      manual_stage pipeline: pipeline_id, stage: stage
    end

    private

    def check_unauthorized(response)
      if response.status == 401
        raise SnapCiManualTrigger::InvalidCredentialsError, 'User - API Key pair invalid, request not authorized'
      end
    end

    def check_not_found(response, pipeline = nil, stage = nil)
      if response.status == 404
        resource_data            = {
          owner:       owner,
          repository:  repository,
          branch_name: branch_name
        }

        resource_data[:pipeline] = pipeline if pipeline.present?
        resource_data[:stage]    = stage if stage.present?

        raise SnapCiManualTrigger::InvalidResourceError, "resource not found: #{resource_data.inspect}"
      end
    end

    def parse_response(response)
      Oj.load response.body
    end

    def build_connection
      Faraday.new(url: CONNECTION_URL, request: { params_encoder: Faraday::FlatParamsEncoder }) do |faraday|
        faraday.basic_auth(user, api_key)
        faraday.request :url_encoded # form-encode POST params
        # faraday.response :logger # log requests to STDOUT
        faraday.adapter Faraday.default_adapter
      end
    end

    def call_new_pipeline
      connection.post new_pipeline_path, nil, HEADERS
    end

    def call_manual_stage(pipeline, stage)
      connection.post manual_stage_path(pipeline, stage), nil, HEADERS
    end

    def new_pipeline_path
      "/project/#{owner}/#{repository}/branch/#{branch_name}/trigger"
    end

    def manual_stage_path(pipeline, stage)
      "/project/#{owner}/#{repository}/branch/#{branch_name}/trigger/#{pipeline}/#{stage}"
    end
  end
end