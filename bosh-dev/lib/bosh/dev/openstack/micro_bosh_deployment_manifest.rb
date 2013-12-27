require 'bosh/dev/openstack'
require 'bosh/dev/writable_manifest'

module Bosh::Dev::Openstack
  class MicroBoshDeploymentManifest
    include Bosh::Dev::WritableManifest

    attr_reader :filename

    def initialize(env, net_type)
      @env = env
      @net_type = net_type
      @filename = 'micro_bosh.yml'
    end

    def to_h
      result = {
        'name' => "microbosh-openstack-#{net_type}",
        'logging' => {
          'level' => 'DEBUG'
        },
        'network' => {
          'type' => net_type,
          'vip' => env['BOSH_OPENSTACK_VIP_DIRECTOR_IP'],
          'cloud_properties' => {
            'net_id' => env['BOSH_OPENSTACK_NET_ID']
          }
        },
        'resources' => {
          'persistent_disk' => 4096,
          'cloud_properties' => {
            'instance_type' => 'm1.small'
          }
        },
        'cloud' => {
          'plugin' => 'openstack',
          'properties' => {
            'openstack' => {
              'auth_url' => env['BOSH_OPENSTACK_AUTH_URL'],
              'username' => env['BOSH_OPENSTACK_USERNAME'],
              'api_key' => env['BOSH_OPENSTACK_API_KEY'],
              'tenant' => env['BOSH_OPENSTACK_TENANT'],
              'region' => env['BOSH_OPENSTACK_REGION'],
              'endpoint_type' => 'publicURL',
              'default_key_name' => 'jenkins',
              'default_security_groups' => ['default'],
              'private_key' => env['BOSH_OPENSTACK_PRIVATE_KEY'],
              'state_timeout' => state_timeout,
            }
          }
        },
        'apply_spec' => {
          'agent' => {
            'blobstore' => {
              'address' => env['BOSH_OPENSTACK_VIP_DIRECTOR_IP']
            },
            'nats' => {
              'address' => env['BOSH_OPENSTACK_VIP_DIRECTOR_IP']
            }
          },
          'properties' => {}
        }
      }

      result['network']['ip'] = env['BOSH_OPENSTACK_MANUAL_IP'] if net_type == 'manual'

      result
    end

    private

    attr_reader :env, :net_type

    def state_timeout
      timeout = env['BOSH_OPENSTACK_STATE_TIMEOUT']
      timeout.to_s.empty? ? 300.0 : timeout.to_f
    end
  end
end
