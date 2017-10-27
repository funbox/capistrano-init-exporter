require 'init_exporter/helpers/init/base_backend'

module InitExporter
  module Helpers
    module Init
      class UpstartBackend < BaseBackend
        def initialize(ssh)
          @ssh = ssh
        end

        def init_type
          'upstart'
        end

        def install(app_name, procfile_path)
          init_exporter_installed? ? super : run_upstart_exporter(app_name, '-p', procfile_path)
        end

        def dry_run(app_name, procfile_path)
          init_exporter_installed? ? super : true
        end

        def uninstall(app_name, procfile_path)
          init_exporter_installed? ? super : run_upstart_exporter(app_name, '-c')
        end

        def start(job_name)
          @ssh.execute :sudo, 'start', job_name
        end

        def stop(job_name)
          @ssh.execute :sudo, 'stop', job_name
        end

        def running?(job_name)
          @ssh.test :sudo, "/sbin/initctl status #{job_name} | grep start"
        end

        private

        def init_exporter_installed?
          @ssh.test 'which', 'init-exporter'
        end

        def run_upstart_exporter(app_name, *args)
          @ssh.execute :sudo, 'upstart-export', '-n', app_name, *args
        end
      end
    end
  end
end
