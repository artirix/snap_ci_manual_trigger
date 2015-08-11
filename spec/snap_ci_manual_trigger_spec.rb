require 'spec_helper'

describe SnapCiManualTrigger do
  it 'has a version number' do
    expect(SnapCiManualTrigger::VERSION).not_to be nil
  end


  let(:body) { nil }
  let(:headers) {
    {
      'Accept'       => 'application/vnd.snap-ci.com.v1+json',
      'Content-type' => 'application/json',
    }
  }

  let(:snap_ci_user) { 'myuser' }
  let(:snap_ci_api_key) { 'qwerty' }

  let(:connection_url) { 'https://api.snap-ci.com' }
  let(:connection_stubs) { Faraday::Adapter::Test::Stubs.new }
  let(:connection) do
    Faraday.new(url: connection_url, request: { params_encoder: Faraday::FlatParamsEncoder }) do |faraday|
      faraday.basic_auth(snap_ci_user, snap_ci_api_key)
      faraday.request :url_encoded # form-encode POST params
      # faraday.response :logger # log requests to STDOUT
      faraday.adapter :test, connection_stubs
    end
  end

  let(:owner) { 'snap-ci' }
  let(:repository) { 'api-docs-sample-repository' }
  let(:branch_name) { 'master' }

  let(:for_params) do
    {
      owner:       owner,
      repository:  repository,
      branch_name: branch_name,
      user:        snap_ci_user,
      api_key:     snap_ci_api_key,
      connection:  connection
    }
  end

  let(:build_service) { described_class.for for_params }

  describe '.for' do
    context 'without api key' do
      let(:snap_ci_api_key) { nil }

      it do
        expect { build_service }.to raise_error(SnapCiManualTrigger::InvalidCredentialsError)
      end
    end

    context 'without user' do
      let(:snap_ci_user) { nil }

      it do
        expect { build_service }.to raise_error(SnapCiManualTrigger::InvalidCredentialsError)
      end
    end

    context 'without owner' do
      let(:owner) { nil }

      it do
        expect { build_service }.to raise_error(SnapCiManualTrigger::InvalidResourceError)
      end
    end

    context 'without repository' do
      let(:repository) { nil }

      it do
        expect { build_service }.to raise_error(SnapCiManualTrigger::InvalidResourceError)
      end
    end

    context 'without passing branch_name' do
      let(:build_service) { described_class.for for_params.reject { |k, _v| k == :branch_name } }

      it do
        expect(build_service.branch_name).to eq 'master'
      end
    end

    context 'without passing connection' do
      let(:build_service) { described_class.for for_params.reject { |k, _v| k == :connection } }

      it 'builds a connection with the correct url and basic auth' do
        c = build_service.connection

        expect(c).to be_a Faraday::Connection

        expect(c.url_prefix.to_s).to eq "#{connection_url}/"

        expect(c.headers).to eq connection.headers

        # try changing basic auth to different one, headers should differ
        c.basic_auth 'abc', '123'
        expect(c.headers).not_to eq connection.headers

        # back to proper basic auth, headers should be the same
        c.basic_auth snap_ci_user, snap_ci_api_key
        expect(c.headers).to eq connection.headers
      end
    end
  end

  describe 'actions' do

    let(:pipeline_url) { "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/#{pipeline_id}" }

    let(:pipeline_id) { 25 }
    let(:stage) { 'Deploy' }
    subject { build_service }
    let(:response_hash) { Oj.load response_body }
    let(:new_pipeline_id) { pipeline_id }

    let(:new_pipeline_path) { "/project/#{owner}/#{repository}/branch/#{branch_name}/trigger" }
    let(:manual_stage_path) { "/project/#{owner}/#{repository}/branch/#{branch_name}/trigger/#{pipeline_id}/#{stage}" }


    let(:new_pipeline_ok_response_headers) do
      {
        'Content-Type' => 'application/vnd.snap-ci.com.v1+json; charset=utf-8',
        'Location'     => "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/#{new_pipeline_id}"
      }
    end
    let(:new_pipeline_ok_response_body) do
      <<-JSON
{
  "message": "A new pipeline was triggered",
  "sha": "a31847e0036f2c95dab513a2339a0990795fbe7e",
  "counter": #{pipeline_id},
  "_embedded": {
    "_links": {
      "self": {
        "href": "#{pipeline_url}"
      },
      "latest": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/{latest,newest}"
      },
      "oldest": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/{oldest,earliest}"
      },
      "previous": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/#{(pipeline_id - 1)}"
      },
      "docs": {
        "href": "https://docs.snap-ci.com/api/pipelines"
      }
    },
    "counter": #{pipeline_id},
    "result": "unknown",
    "commits": [
      {
        "_links": {
          "github": [
            {
              "rel": "api",
              "href": "https://api.github.com/repos/#{owner}/#{repository}/commits/a31847e0036f2c95dab513a2339a0990795fbe7e"
            },
            {
              "rel": "http",
              "href": "https://github.com/#{owner}/#{repository}/commits/a31847e0036f2c95dab513a2339a0990795fbe7e"
            }
          ]
        },
        "sha": "a31847e0036f2c95dab513a2339a0990795fbe7e",
        "short_sha": "a31847e",
        "author": "Ketan Padegaonkar <ketanpadegaonkar@gmail.com>",
        "message": "Update README.md",
        "time": "2014-12-30T08:48:15Z"
      }
    ],
    "stages": [
      {
        "name": "Build",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Build",
        "result": "unknown",
        "duration": null,
        "workers": [
          {
            "counter": 1,
            "result": null,
            "duration": 0,
            "artifacts": [

            ],
            "started_at": null,
            "completed_at": null
          }
        ],
        "started_at": null,
        "completed_at": null
      },
      {
        "name": "Deploy",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Deploy",
        "result": "unknown",
        "duration": null,
        "workers": [
          {
            "counter": 1,
            "result": null,
            "duration": 0,
            "artifacts": [

            ],
            "started_at": null,
            "completed_at": null
          }
        ],
        "started_at": null,
        "completed_at": null
      },
      {
        "name": "Smoke",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Smoke",
        "result": "unknown",
        "duration": null,
        "workers": [
          {
            "counter": 1,
            "result": null,
            "duration": 0,
            "artifacts": [

            ],
            "started_at": null,
            "completed_at": null
          }
        ],
        "started_at": null,
        "completed_at": null
      }
    ]
  }
}
      JSON
    end


    let(:manual_stage_ok_response_headers) do
      {
        'Content-Type' => 'application/hal+json; charset=utf-8',
        'Location'     => pipeline_url
      }
    end


    let(:manual_stage_ok_response_body) do
      <<-JSON
{
  "message": "The manual stage Deploy was successfully triggered.",
  "_embedded": {
    "_links": {
      "self": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/#{pipeline_id}"
      },
      "latest": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/{latest,newest}"
      },
      "oldest": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/{oldest,earliest}"
      },
      "previous": {
        "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/pipelines/#{(pipeline_id - 1)}"
      },
      "docs": {
        "href": "http://docs.snap-ci.com/api/pipelines"
      }
    },
    "counter": #{pipeline_id},
    "result": "passed",
    "commits": [
      {
        "_links": {
          "github": [
            {
              "rel": "api",
              "href": "https://api.github.com/repos/#{owner}/#{repository}/commits/53fb6cfe8a14cbcac0f4f291f1118b1de11118d9"
            },
            {
              "rel": "http",
              "href": "https://github.com/#{owner}/#{repository}/commits/53fb6cfe8a14cbcac0f4f291f1118b1de11118d9"
            }
          ]
        },
        "sha": "53fb6cfe8a14cbcac0f4f291f1118b1de11118d9",
        "short_sha": "53fb6cf",
        "author": "Ketan Padegaonkar <ketanpadegaonkar@gmail.com>",
        "message": "Update config.ru",
        "time": "2014-09-23T10:02:59Z"
      }
    ],
    "stages": [
      {
        "name": "Build",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Build",
        "result": "passed",
        "duration": 19,
        "artifacts": [
          {
            "_links": {
              "self": {
                "href": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/artifacts/tracking-pipeline/25/Build/foo.tar.gz.snap"
              }
            },
            "name": "foo",
            "download_url": "https://api.snap-ci.com/project/#{owner}/#{repository}/branch/#{branch_name}/artifacts/tracking-pipeline/25/Build/foo.tar.gz.snap"
          }
        ],
        "started_at": "2014-12-24T15:49:21Z",
        "completed_at": "2014-12-24T15:49:21Z"
      },
      {
        "name": "Deploy",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Deploy",
        "result": "unknown",
        "duration": null,
        "artifacts": [

        ],
        "started_at": null,
        "completed_at": null
      },
      {
        "name": "Smoke",
        "full_name": "#{owner}/#{repository} (#{branch_name}) :: Smoke",
        "result": "unknown",
        "duration": null,
        "artifacts": [

        ],
        "started_at": null,
        "completed_at": null
      }
    ]
  }
}

      JSON
    end

    let(:unauthorized_response_body) { "{\n  \"message\": \"Your request was not authorized, please make sure your request contains proper authorization.\"\n}\n" }
    let(:unauthorized_response_headers) do
      {
        "cache-control"   => "no-cache, no-cache=\"set-cookie\"",
        "content-type"    => "application/vnd.snap-ci.com.v1+json; charset=utf-8",
        "date"            => "Tue, 11 Aug 2015 09:46:59 GMT",
        "server"          => "nginx/1.9.3",
        "set-cookie"      => "AWSELB=2569850D0469DB490959909294C16AEE2FBF268FFA1B7AACB306795D17F2DD07572038B59C49B973FFBA27C9A69FF9A70481C9104CE07BE82F9DCD966253D5D564470F35E2;PATH=/;MAX-AGE=300",
        "x-rack-cache"    => "invalidate, pass",
        "x-request-id"    => "9db698c36d3be14d3da28a67c925c17a",
        "x-runtime"       => "0.010510",
        "x-ua-compatible" => "IE=Edge,chrome=1",
        "content-length"  => "113",
        "connection"      => "Close"
      }
    end

    let(:not_found_response_body) { "{\n  \"message\": \"Resource not found!\"\n}\n" }
    let(:not_found_response_headers) do
      {
        "cache-control"   => "no-cache, no-cache=\"set-cookie\"",
        "content-type"    => "application/vnd.snap-ci.com.v1+json; charset=utf-8",
        "date"            => "Tue, 11 Aug 2015 09:46:59 GMT",
        "server"          => "nginx/1.9.3",
        "set-cookie"      => "AWSELB=2569850D0469DB490959909294C16AEE2FBF268FFA1B7AACB306795D17F2DD07572038B59C49B973FFBA27C9A69FF9A70481C9104CE07BE82F9DCD966253D5D564470F35E2;PATH=/;MAX-AGE=300",
        "x-rack-cache"    => "invalidate, pass",
        "x-request-id"    => "9db698c36d3be14d3da28a67c925c17a",
        "x-runtime"       => "0.010510",
        "x-ua-compatible" => "IE=Edge,chrome=1",
        "content-length"  => "39",
        "connection"      => "keep-alive"
      }
    end

    describe '#new_pipeline' do
      let(:path) { new_pipeline_path }

      context 'with correct data' do

        let(:response_headers) { new_pipeline_ok_response_headers }

        let(:response_body) { new_pipeline_ok_response_body }

        before :each do
          connection_stubs.post(path, body, headers) do |_env|
            [201, response_headers, response_body]
          end
        end

        it 'performs POST /project/:owner/:repository/branch/:branch_name/trigger and returns the new Pipeline ID' do
          expect(subject.new_pipeline).to eq new_pipeline_id
          connection_stubs.verify_stubbed_calls
        end
      end

      context 'with incorrect user-api_key pair' do
        let(:response_body) { unauthorized_response_body }
        let(:response_headers) { unauthorized_response_headers }

        before :each do
          connection_stubs.post(path, body, headers) do |_env|
            [401, response_headers, response_body]
          end
        end

        it do
          expect { subject.new_pipeline }.to raise_error(SnapCiManualTrigger::InvalidCredentialsError)
        end

      end
    end


    describe '#manual_stage' do
      let(:path) { manual_stage_path }

      context 'with incorrect user-api_key pair' do
        let(:response_body) { unauthorized_response_body }
        let(:response_headers) { unauthorized_response_headers }

        before :each do
          connection_stubs.post(path, body, headers) do |_env|
            [401, response_headers, response_body]
          end
        end

        it do
          expect { subject.manual_stage pipeline: pipeline_id, stage: stage }.to raise_error(SnapCiManualTrigger::InvalidCredentialsError)
        end

      end

      context 'with incorrect resource (bad pipeline id)' do
        let(:response_body) { not_found_response_body }
        let(:response_headers) { not_found_response_headers }

        before :each do
          connection_stubs.post(path, body, headers) do |_env|
            [404, response_headers, response_body]
          end
        end

        it do
          expect { subject.manual_stage pipeline: pipeline_id, stage: stage }.to raise_error(SnapCiManualTrigger::InvalidResourceError)
        end
      end

      context 'with correct data' do

        let(:response_headers) { manual_stage_ok_response_headers }

        let(:response_body) { manual_stage_ok_response_body }

        before :each do
          connection_stubs.post(path, body, headers) do |_env|
            [201, response_headers, response_body]
          end
        end

        it 'performs POST /project/:owner/:repository/branch/:branch_name/trigger/:pipeline_id/:stage and returns the pipeline URL in Snap-CI' do
          expect(subject.manual_stage pipeline: pipeline_id, stage: stage).to eq pipeline_url
          connection_stubs.verify_stubbed_calls
        end
      end
    end

    describe '#manual_stage_on_new_pipeline' do
      context 'with incorrect user-api_key pair' do
        let(:response_body) { unauthorized_response_body }
        let(:response_headers) { unauthorized_response_headers }

        before :each do
          connection_stubs.post(new_pipeline_path, body, headers) do |_env|
            [401, response_headers, response_body]
          end
        end

        it do
          expect { subject.manual_stage_on_new_pipeline stage }.to raise_error(SnapCiManualTrigger::InvalidCredentialsError)
        end

      end

      context 'with incorrect resource' do
        let(:response_body) { not_found_response_body }
        let(:response_headers) { not_found_response_headers }

        context 'bad project' do
          before :each do
            connection_stubs.post(new_pipeline_path, body, headers) do |_env|
              [404, response_headers, response_body]
            end
          end

          it do
            expect { subject.manual_stage_on_new_pipeline stage }.to raise_error(SnapCiManualTrigger::InvalidResourceError)
          end
        end

        context 'bad stage' do
          before :each do
            connection_stubs.post(new_pipeline_path, body, headers) do |_env|
              [201, new_pipeline_ok_response_headers, new_pipeline_ok_response_body]
            end

            connection_stubs.post(manual_stage_path, body, headers) do |_env|
              [404, response_headers, response_body]
            end
          end

          it do
            expect { subject.manual_stage_on_new_pipeline stage }.to raise_error(SnapCiManualTrigger::InvalidResourceError)
          end
        end
      end

      context 'with correct data' do
        before :each do
          connection_stubs.post(new_pipeline_path, body, headers) do |_env|
            [201, new_pipeline_ok_response_headers, new_pipeline_ok_response_body]
          end

          connection_stubs.post(manual_stage_path, body, headers) do |_env|
            [201, manual_stage_ok_response_headers, manual_stage_ok_response_body]
          end
        end

        it 'creates new pipeline and then calls for a manual stage on that one, returning pipeline URL in Snap-CI' do
          expect(subject.manual_stage_on_new_pipeline stage).to eq pipeline_url
          connection_stubs.verify_stubbed_calls
        end
      end
    end
  end
end