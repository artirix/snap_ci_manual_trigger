require 'spec_helper'
require 'rails/generators/test_case'
require 'generator_spec'

describe SnapCiManualTrigger::Generators::RakeTasksGenerator, type: :generator do
  destination File.expand_path('../../tmp', __FILE__)
  arguments %w(my_owner my_repo)

  let(:task_name) { 'snap_ci:my_owner_my_repo' }

  before(:all) do
    prepare_destination
    run_generator
  end

  describe 'generator' do
    it 'creates a rake task for fast manual_' do
      assert_file "#{test_case.destination_root}/lib/tasks/snap_ci/my_owner_my_repo.rake" do |task_file|
        task_file.include?('namespace :snap_ci ')
        task_file.include?('task :my_owner_my_repo, [:stage, :branch_name]')
      end
    end
  end

  describe 'generated task' do

    before(:all) do
      load "#{test_case.destination_root}/lib/tasks/snap_ci/my_owner_my_repo.rake"
    end

    before(:each) do
      stub_env 'SNAP_CI_USER', user
      stub_env 'SNAP_CI_API_KEY', api_key
      Rake::Task[task_name].reenable
    end

    let(:owner) { 'my_owner' }
    let(:repository) { 'my_repo' }
    let(:user) { 'my-user' }
    let(:api_key) { 'abcdef' }
    let(:stage) { 'Deploy' }
    let(:branch_name) { 'my_branch' }

    let(:expected_params) do
      {
        user:        user,
        api_key:     api_key,
        owner:       owner,
        repository:  repository,
        branch_name: branch_name
      }
    end


    context 'without arguments' do
      it do
        expect(SnapCiManualTrigger).not_to receive(:for)

        expect { Rake::Task[task_name].invoke }.to raise_error SnapCiManualTrigger::MissingRakeArgumentsError
      end
    end

    context 'with empty stage' do
      it do
        expect(SnapCiManualTrigger).not_to receive(:for)

        expect { Rake::Task[task_name].invoke('') }.to raise_error SnapCiManualTrigger::MissingRakeArgumentsError
      end
    end

    context 'without ENV for user' do
      before(:each) do
        stub_env 'SNAP_CI_USER', ''
      end

      it do
        expect(SnapCiManualTrigger).not_to receive(:for)

        expect { Rake::Task[task_name].invoke(stage) }.to raise_error SnapCiManualTrigger::MissingRakeAuthError
      end
    end

    context 'without ENV for api key' do
      before(:each) do
        stub_env 'SNAP_CI_API_KEY', ''
      end

      it do
        expect(SnapCiManualTrigger).not_to receive(:for)

        expect { Rake::Task[task_name].invoke(stage) }.to raise_error SnapCiManualTrigger::MissingRakeAuthError
      end
    end

    context 'valid params' do

      before(:each) do
        expect(SnapCiManualTrigger).to receive(:for).with(expected_params) do
          double.tap do |service|
            expect(service).to receive(:manual_stage_on_new_pipeline).with(stage) { 'NEW-PIPELINE-URL-IN-SNAP-CI' }
          end
        end
      end

      context 'without branch name' do
        let(:branch_name) { 'master' }

        it 'uses master as branch_name' do
          Rake::Task[task_name].invoke(stage)
        end
      end

      context 'passing branch_name as second argument' do
        it 'uses master as branch_name' do
          Rake::Task[task_name].invoke(stage, branch_name)
        end
      end
    end
  end

end
