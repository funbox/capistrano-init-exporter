module InitExporter
  module Helpers
    module Init
      class BaseBackend
        def initialize(ssh)
          @ssh = ssh
        end

        def install(app_name, procfile_path)
          run_init_exporter(app_name, '-p', procfile_path)
        end

        def dry_run(app_name, procfile_path)
          run_init_exporter(app_name, '-p', procfile_path, '--dry-start')
        end

        def uninstall(app_name)
          run_init_exporter(app_name, '-c')
        end

        def init_type
          raise NotImplementedError
        end

        private

        def run_init_exporter(app_name, *args)
          @ssh.execute :sudo, 'init-exporter', '-n', app_name, '-f', init_type, *args
        end
      end
    end
  end
end
