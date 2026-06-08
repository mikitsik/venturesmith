# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Somnia::RequestExecutor do
  subject(:executor) { described_class.new(somnia_request) }

  let(:callback_receiver_address) do
    '0x7a560B917DAf06ddc9b1aAeB4A6512F3007D4220'
  end

  let(:tx_hash) do
    '0xbe7c8017e43331c8c48eeacd7e0b6ca969924aefc872d083eee6db5d6e3ee512'
  end

  let(:callback_data_hash) do
    '0x3c6724d1665ffc9f0386c0ef068964330ed110b3459cf61a16def3f70427d4ba'
  end

  let(:callback_sender) do
    '0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776'
  end

  let(:script_result) do
    {
      tx_hash:,
      request_id: '5667765',
      callback_count: '3',
      callback_sender:,
      callback_data_hash:,
      result: 'https://github.com/mikitsik'
    }
  end

  let(:stdout) do
    <<~OUTPUT
      Wallet: 0xd572246e63F3B61B4D35da9B7BD710d73C050998
      Platform: 0x037Bb9C718F3f7fe5eCBDB0b600D607b52706776
      #{script_result.to_json}
    OUTPUT
  end

  let(:status) do
    instance_double(Process::Status, success?: true)
  end

  let(:user_profile) do
    UserProfile.create!(
      name: 'Aliaksei',
      background: 'Ruby on Rails developer',
      available_days: 30,
      github_url: 'https://github.com/mikitsik'
    )
  end

  let(:somnia_request) do
    SomniaRequest.create!(
      user_profile:,
      agent_kind: 'json_api_request',
      stage: 'github_discovery',
      status: 'draft',
      payload: request_payload,
      response: { 'data' => [] }
    )
  end

  let(:request_payload) do
    {
      'requests' => [
        {
          'name' => 'user',
          'url' => 'https://api.github.com/users/mikitsik'
        }
      ],
      'selector' => 'html_url'
    }
  end

  around do |example|
    old_value = ENV.fetch('SOMNIA_RAW_CALLBACK_RECEIVER_ADDRESS', nil)
    ENV['SOMNIA_RAW_CALLBACK_RECEIVER_ADDRESS'] = callback_receiver_address

    example.run
  ensure
    ENV['SOMNIA_RAW_CALLBACK_RECEIVER_ADDRESS'] = old_value
  end

  before do
    allow(Open3).to receive(:capture3).and_return([stdout, '', status])
  end

  it 'calls the Hardhat JSON API agent script' do
    executor.call

    expect(Open3).to have_received(:capture3).with(
      expected_env,
      'npx',
      'hardhat',
      'run',
      'scripts/request_github_login.js',
      '--network',
      'somniaShannon',
      chdir: Rails.root.join('contracts').to_s
    )
  end

  it 'returns parsed script result' do
    result = executor.call

    expect(result['result']).to eq('https://github.com/mikitsik')
  end

  it 'marks request as completed' do
    executor.call

    expect(somnia_request.reload.status).to eq('completed')
  end

  it 'stores request id' do
    executor.call

    expect(somnia_request.reload.request_id).to eq('5667765')
  end

  it 'stores request transaction hash' do
    executor.call

    expect(somnia_request.reload.request_tx_hash).to eq(tx_hash)
  end

  it 'stores decoded result' do
    executor.call

    expect(somnia_request.reload.response['result']).to eq(
      'https://github.com/mikitsik'
    )
  end

  it 'stores callback sender' do
    executor.call

    expect(somnia_request.reload.response['callback_sender']).to eq(
      callback_sender
    )
  end

  it 'stores callback data hash' do
    executor.call

    expect(somnia_request.reload.response['callback_data_hash']).to eq(
      callback_data_hash
    )
  end

  it 'does not store raw callback data' do
    executor.call

    expect(somnia_request.reload.response).not_to have_key('callback_data')
  end

  it 'rejects non-draft requests' do
    somnia_request.update!(status: 'completed')

    expect { executor.call }.to raise_error(
      ArgumentError,
      'SomniaRequest must be draft'
    )
  end

  it 'rejects unsupported agent kind' do
    set_unsupported_agent_kind

    expect { executor.call }.to raise_error(
      ArgumentError,
      'Only JSON API Request Agent is supported now'
    )
  end

  def expected_env
    hash_including(
      'GITHUB_TEST_URL' => 'https://api.github.com/users/mikitsik',
      'JSON_SELECTOR' => 'html_url',
      'CALLBACK_ADDRESS' => callback_receiver_address,
      'CALLBACK_SELECTOR' => '0x00000000'
    )
  end

  def set_unsupported_agent_kind
    somnia_request.update!(
      agent_kind: 'llm_inference',
      stage: 'founder_profile_inference'
    )
  end
end
