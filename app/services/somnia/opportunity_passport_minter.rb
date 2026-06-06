# frozen_string_literal: true

require 'json'
require 'open3'

module Somnia
  class OpportunityPassportMinter
    CONTRACTS_PATH = Rails.root.join('contracts')

    attr_reader :opportunity

    def initialize(opportunity)
      @opportunity = opportunity
    end

    def mint!
      result = run_mint_script(passport_payload)

      update_opportunity!(result)

      result
    end

    private

    def passport_payload
      @passport_payload ||= Somnia::OpportunityPassportPayload.new(opportunity)
    end

    def run_mint_script(payload)
      stdout, stderr, status = Open3.capture3(
        {
          'PASSPORT_METADATA_HASH' => payload.metadata_hash,
          'PASSPORT_METADATA_URI' => payload.metadata_uri
        },
        'npx',
        'hardhat',
        'run',
        'scripts/mint_passport.js',
        '--network',
        'somniaShannon',
        chdir: CONTRACTS_PATH.to_s
      )

      raise "Mint failed: #{stderr.presence || stdout}" unless status.success?

      JSON.parse(stdout.lines.last)
    end

    def update_opportunity!(result)
      opportunity.update!(
        passport_id: result.fetch('passport_id'),
        passport_tx_hash: result.fetch('tx_hash'),
        passport_metadata_hash: result.fetch('metadata_hash'),
        passport_metadata_uri: result.fetch('metadata_uri')
      )
    end
  end
end
