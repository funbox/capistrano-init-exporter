require 'init_exporter/helpers/init/base_backend'

module InitExporter
  module Helpers
    module Init
      class SystemdBackend < BaseBackend
        def initialize(ssh)
          @ssh = ssh
        end

        def init_type
          'systemd'
        end

        def start(job_name)
          @ssh.execute :sudo, 'systemctl', 'start', job_name
        end

        def stop(job_name)
          @ssh.execute :sudo, 'systemctl', 'stop', job_name
        end

        def running?(job_name)
          @ssh.test :sudo, 'systemctl', 'status', job_name
        end
      end
    end
  end
end
