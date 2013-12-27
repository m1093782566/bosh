require 'spec_helper'
require 'bosh/dev/openstack/micro_bosh_deployment_manifest'
require 'yaml'

module Bosh::Dev::Openstack
  describe MicroBoshDeploymentManifest do
    subject { MicroBoshDeploymentManifest.new(env, net_type) }
    let(:env) { {} }
    let(:net_type) { 'dynamic' }

    its(:filename) { should eq('micro_bosh.yml') }

    it 'is writable' do
      expect(subject).to be_a(Bosh::Dev::WritableManifest)
    end

    describe '#to_h' do
      before do
        env.merge!(
          'BOSH_OPENSTACK_VIP_DIRECTOR_IP' => 'vip',
          'BOSH_OPENSTACK_MANUAL_IP' => 'ip',
          'BOSH_OPENSTACK_NET_ID' => 'net_id',
          'BOSH_OPENSTACK_AUTH_URL' => 'auth_url',
          'BOSH_OPENSTACK_USERNAME' => 'username',
          'BOSH_OPENSTACK_API_KEY' => 'api_key',
          'BOSH_OPENSTACK_TENANT' => 'tenant',
          'BOSH_OPENSTACK_REGION' => 'region',
          'BOSH_OPENSTACK_PRIVATE_KEY' => 'private_key_path',
        )
      end

      context 'when net_type is "manual"' do
        let(:net_type) { 'manual' }
        let(:expected_yml) { <<YAML }
---
name: microbosh-openstack-manual
logging:
  level: DEBUG
network:
  type: manual
  vip: vip
  ip: ip
  cloud_properties:
    net_id: net_id
resources:
  persistent_disk: 4096
  cloud_properties:
    instance_type: m1.small
cloud:
  plugin: openstack
  properties:
    openstack:
      auth_url: auth_url
      username: username
      api_key: api_key
      tenant: tenant
      region: region
      endpoint_type: publicURL
      default_key_name: jenkins
      default_security_groups:
      - default
      private_key: private_key_path
      state_timeout: 300
apply_spec:
  agent:
    blobstore:
      address: vip
    nats:
      address: vip
  properties: {}
YAML

        it 'generates the correct YAML' do
          expect(subject.to_h).to eq(Psych.load(expected_yml))
        end
      end

      context 'when net_type is "dynamic"' do
        let(:net_type) { 'dynamic' }
        let(:expected_yml) { <<YAML }
---
name: microbosh-openstack-dynamic
logging:
  level: DEBUG
network:
  type: dynamic
  vip: vip
  cloud_properties:
    net_id: net_id
resources:
  persistent_disk: 4096
  cloud_properties:
    instance_type: m1.small
cloud:
  plugin: openstack
  properties:
    openstack:
      auth_url: auth_url
      username: username
      api_key: api_key
      tenant: tenant
      region: region
      endpoint_type: publicURL
      default_key_name: jenkins
      default_security_groups:
      - default
      private_key: private_key_path
      state_timeout: 300
apply_spec:
  agent:
    blobstore:
      address: vip
    nats:
      address: vip
  properties: {}
YAML

        it 'generates the correct YAML' do
          expect(subject.to_h).to eq(Psych.load(expected_yml))
        end
      end

      context 'when BOSH_OPENSTACK_STATE_TIMEOUT is specified' do
        it 'uses given env variable value (converted to a float) as a state_timeout' do
          value = double('state_timeout', to_f: 'state_timeout_as_float')
          env.merge!('BOSH_OPENSTACK_STATE_TIMEOUT' => value)
          expect(subject.to_h['cloud']['properties']['openstack']['state_timeout']).to eq('state_timeout_as_float')
        end
      end

      context 'when BOSH_OPENSTACK_STATE_TIMEOUT is an empty string' do
        it 'uses 300 (number) as a state_timeout' do
          env.merge!('BOSH_OPENSTACK_STATE_TIMEOUT' => '')
          expect(subject.to_h['cloud']['properties']['openstack']['state_timeout']).to eq(300)
        end
      end

      context 'when BOSH_OPENSTACK_STATE_TIMEOUT is not specified' do
        it 'uses 300 (number) as a state_timeout' do
          env.merge!('BOSH_OPENSTACK_STATE_TIMEOUT' => nil)
          expect(subject.to_h['cloud']['properties']['openstack']['state_timeout']).to eq(300)
        end
      end
    end
  end
end
