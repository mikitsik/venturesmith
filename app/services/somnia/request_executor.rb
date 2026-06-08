# frozen_string_literal: true

require 'json'
require 'open3'
require 'timeout'

module Somnia
  class RequestExecutor
    TIMEOUT_SECONDS = 600

    attr_reader :somnia_request

    def initialize(somnia_request)
      @somnia_request = somnia_request
    end

    def call
      validate_request!

      stdout, stderr, status = run_script

      raise "Somnia request failed: #{stderr.presence || stdout}" unless status.success?

      result = parse_result(stdout)

      somnia_request.update!(
        status: 'completed',
        request_id: result.fetch('request_id'),
        request_tx_hash: result.fetch('tx_hash'),
        response: {
          result: result.fetch('result'),
          callback_sender: result.fetch('callback_sender'),
          callback_data_hash: result.fetch('callback_data_hash')
        }
      )

      result
    end

    private

    def validate_request!
      unless somnia_request.agent_kind == 'json_api_request'
        raise ArgumentError,
              'Only JSON API Request Agent is supported now'
      end
      raise ArgumentError, 'SomniaRequest must be draft' unless somnia_request.status == 'draft'
      raise ArgumentError, 'GitHub discovery URL is missing' if request_url.blank?
      raise ArgumentError, 'Callback receiver address is missing' if callback_address.blank?
    end

    def run_script
      Timeout.timeout(TIMEOUT_SECONDS) do
        Open3.capture3(
          script_env,
          'npx',
          'hardhat',
          'run',
          'scripts/request_github_login.js',
          '--network',
          'somniaShannon',
          chdir: contracts_path.to_s
        )
      end
    end

    def script_env
      {
        'GITHUB_TEST_URL' => request_url,
        'JSON_SELECTOR' => json_selector,
        'CALLBACK_ADDRESS' => callback_address,
        'CALLBACK_SELECTOR' => '0x00000000'
      }
    end

    def parse_result(stdout)
      json_line = stdout.lines.reverse.find { |line| line.strip.start_with?('{') }

      raise "Somnia script did not return JSON:\n#{stdout}" if json_line.blank?

      JSON.parse(json_line)
    end

    def request_url
      somnia_request.payload.dig('requests', 0, 'url') ||
        somnia_request.payload['url']
    end

    def json_selector
      somnia_request.payload['selector'].presence || 'login'
    end

    def callback_address
      ENV.fetch('SOMNIA_RAW_CALLBACK_RECEIVER_ADDRESS', nil)
    end

    def contracts_path
      Rails.root.join('contracts')
    end
  end
end
