require 'active_support/all'
require 'faraday'
require 'oj'
require 'oj_mimic_json'

require 'snap_ci_manual_trigger/version'
require 'snap_ci_manual_trigger/invalid_credentials_error'
require 'snap_ci_manual_trigger/invalid_resource_error'
require 'snap_ci_manual_trigger/service'

module SnapCiManualTrigger
  DEFAULT_BRANCH_NAME = 'master'.freeze

  def self.for(user:, api_key:, owner:, repository:, branch_name: DEFAULT_BRANCH_NAME, connection: nil)
    raise InvalidCredentialsError, 'it needs both user and api_key' unless user.present? && api_key.present?
    raise InvalidResourceError, 'it needs an owner' unless owner.present?
    raise InvalidResourceError, 'it needs an repository' unless repository.present?

    Service.new user: user,
                api_key: api_key,
                owner: owner,
                repository: repository,
                branch_name: branch_name,
                connection: connection
  end
end
