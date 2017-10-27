require 'init_exporter/helpers/init'

include InitExporter::Helpers::Init

namespace :init do
  desc 'Ensure all procfiles are correct'
  task :ensure_correct_procfiles do
    current_procfiles = procfiles_for(fetch(:stage))

    ambiguous_procfiles = current_procfiles.group_by { |p| p[:role] }
    ambiguous_procfiles.each do |role, procfiles|
      next if procfiles.size == 1

      paths = procfiles.map { |p| p[:path] }

      warn "Several procfiles for role '#{role}' and stage '#{fetch(:stage)}' have been detected:"
      paths.each do |path|
        warn "  #{path}"
      end
      warn "Don't know which to use. You must solve this disambiguation prior to deploy."

      raise 'Ambiguous procfiles'
    end

    on release_roles(init_roles.first || []) do
      within release_path do
        empty_procfiles = current_procfiles.map { |p| p[:path] }.select do |path|
          contents = capture(:cat, path).gsub(/\s/, '')
          contents.empty?
        end

        unless empty_procfiles.empty?
          warn 'Empty procfiles have been detected:'
          empty_procfiles.each do |path|
            warn " - #{path}"
          end
          warn 'Empty procfiles are not allowed.'

          raise 'Empty procfiles'
        end
      end
    end
  end

  desc 'Stop init jobs'
  task :stop do
    init_roles.each do |role|
      next unless procfile_exists?(fetch(:stage), role)
      on release_roles(role) do
        backend = detect_backend(self)
        job_name = init_job_name(fetch(:application), role)
        backend.stop(job_name) if backend.running?(job_name)
      end
    end
  end

  desc 'Start init jobs'
  task :start do
    init_roles.each do |role|
      next unless procfile_exists?(fetch(:stage), role)
      on release_roles(role) do
        backend = detect_backend(self)
        job_name = init_job_name(fetch(:application), role)
        backend.start(job_name) unless backend.running?(job_name)
      end
    end
  end

  desc 'Install init jobs'
  task :install do
    procfiles_for(fetch(:stage)).each do |procfile|
      on release_roles(procfile[:role]) do
        backend = detect_backend(self)

        procfile_path = release_path.join(procfile[:path])
        if test "[ -f #{procfile_path} ]"
          app_name = application_init_name(fetch(:application), procfile[:role])
          backend.install(app_name, procfile_path)
        end
      end
    end
  end

  desc 'Uninstall init jobs'
  task :uninstall => :stop do
    init_roles.each do |role|
      on release_roles role do
        backend = detect_backend(self)

        app_name = application_init_name(fetch(:application), role)
        backend.uninstall(app_name)
      end
    end
  end

  desc 'Dry run init-exporter'
  task :dry_run do
    procfiles_for(fetch(:stage)).each do |procfile|
      on release_roles(procfile[:role]) do
        backend = detect_backend(self)

        procfile_path = release_path.join(procfile[:path])
        if test "[ -f #{procfile_path} ]"
          app_name = application_init_name(fetch(:application), procfile[:role])
          backend.dry_run(app_name, procfile_path)
        end
      end
    end
  end

  desc 'Publish init jobs (install && run)'
  task :publish do
    invoke 'init:ensure_correct_procfiles'
    invoke 'init:install'
    invoke 'init:start'
  end
end

before 'deploy:publishing', 'init:dry_run'
before 'deploy:publishing', 'init:stop'
before 'deploy:published',  'init:publish'
