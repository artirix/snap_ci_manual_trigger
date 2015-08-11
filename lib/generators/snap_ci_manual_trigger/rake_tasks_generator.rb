require 'rails/generators/base'

module SnapCiManualTrigger
  module Generators
    class RakeTasksGenerator < Rails::Generators::Base
      source_root File.expand_path('../templates', __FILE__)

      desc <<-DESC.strip_heredoc
        Creates rake tasks for the given owner/repository pair (will generate file in "lib/tasks/snap_ci/OWNER_REPOSITORY.rake")

        For example:
          rails generate snap_ci_manual_trigger:rake_tasks my-org my-repo

      DESC

      argument :owner, required: true, desc: 'The owner in Snap-CI'
      argument :repository, required: true, desc: 'The repository in Snap-CI'

      def create_tasks
        template 'rake_tasks.rb.erb', "lib/tasks/snap_ci/#{owner}_#{repository}.rake"
      end
    end
  end
end
