# This file was auto-generated by lib/tasks/web.rake

require 'spec_helper'

RSpec.describe Slack::Web::Api::Endpoints::UsergroupsUsers do
  let(:client) { Slack::Web::Client.new }
  context 'usergroups.users_list' do
    it 'requires usergroup' do
      expect { client.usergroups_users_list }.to raise_error ArgumentError, /Required arguments :usergroup missing/
    end
  end
  context 'usergroups.users_update' do
    it 'requires usergroup' do
      expect { client.usergroups_users_update(users: 'U060R4BJ4,U060RNRCZ') }.to raise_error ArgumentError, /Required arguments :usergroup missing/
    end
    it 'requires users' do
      expect { client.usergroups_users_update(usergroup: 'S0604QSJC') }.to raise_error ArgumentError, /Required arguments :users missing/
    end
  end
end
