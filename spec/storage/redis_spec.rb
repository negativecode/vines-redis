require 'spec_helper'

describe Vines::Storage::Redis do
  include StorageSpecs

  MOCK_REDIS = MockRedis.new

  before do
    fibered do
      db = MOCK_REDIS
      db.set('user:empty@wonderland.lit', {}.to_json)
      db.set('user:no_password@wonderland.lit', {'foo' => 'bar'}.to_json)
      db.set('user:clear_password@wonderland.lit', {'password' => 'secret'}.to_json)
      db.set('user:bcrypt_password@wonderland.lit', {'password' => BCrypt::Password.create('secret')}.to_json)
      db.set('user:full@wonderland.lit', {
        'password' => BCrypt::Password.create('secret'),
        'name' => 'Tester'
      }.to_json)
      db.hmset('roster:full@wonderland.lit',
        'contact1@wonderland.lit',
        {'name' => 'Contact1', 'groups' => %w[Group1 Group2]}.to_json,
        'contact2@wonderland.lit',
        {'name' => 'Contact2', 'groups' => %w[Group3 Group4]}.to_json)
      db.set('vcard:full@wonderland.lit', {'card' => VCARD.to_xml}.to_json)
      db.hset('fragments:full@wonderland.lit', FRAGMENT_ID, {'xml' => FRAGMENT.to_xml}.to_json)
    end
  end

  after do
    MOCK_REDIS.flushdb
  end

  def storage
    storage = Vines::Storage::Redis.new { host 'localhost'; port 6397 }
    def storage.redis; RedisTest::MOCK_REDIS; end
    storage
  end

  describe 'creating a new instance' do
    it 'does not raise with no arguments' do
      fibered do
        obj = Vines::Storage::Redis.new {}
        obj.wont_be_nil
      end
    end

    it 'does not raise when port is missing' do
      fibered do
        obj = Vines::Storage::Redis.new { host 'localhost' }
        obj.wont_be_nil
      end
    end

    it 'does not raise with host and port' do
      fibered do
        obj = Vines::Storage::Redis.new { host'localhost'; port '6379' }
        obj.wont_be_nil
      end
    end
  end
end
